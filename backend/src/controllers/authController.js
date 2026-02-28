import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'

const MAX_INTENTOS = 5
const BLOQUEO_MINUTOS = 15

function generarAccessToken(payload) {
  return jwt.sign(payload, process.env.ACCESS_TOKEN_SECRET, {
    expiresIn: process.env.ACCESS_TOKEN_EXPIRY || '15m',
  })
}

function generarRefreshToken(sub) {
  return jwt.sign(
    { sub, type: 'refresh' },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY || '7d' }
  )
}

function cookieOpciones() {
  return {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 días en ms
    path: '/api/auth',
  }
}

/**
 * POST /api/auth/login
 * Body: { identificador: string, password: string }
 * identificador puede ser email o CURP
 */
export async function login(req, res) {
  const { identificador, password } = req.body
  const ip = getClientIp(req)
  const userAgent = req.headers['user-agent'] || null

  if (!identificador || !password) {
    return res.status(400).json({ error: 'Identificador y contraseña son requeridos' })
  }

  // Buscar usuario por email (insensible a mayúsculas) o CURP
  const id = identificador.trim()
  const { rows } = await pool.query(
    `SELECT
       u.id, u.curp, u.email, u.password_hash, u.activo,
       u.intentos_fallidos, u.bloqueado_hasta,
       r.id AS rol_id, r.clave AS rol_clave, r.nombre AS rol_nombre
     FROM adm_usuarios u
     LEFT JOIN cat_roles r ON u.rol_id = r.id
     WHERE LOWER(u.email) = LOWER($1) OR UPPER(u.curp) = UPPER($1)
     LIMIT 1`,
    [id]
  )

  // Mismo mensaje si no existe el usuario (evita enumeración)
  if (rows.length === 0) {
    return res.status(401).json({ error: 'Credenciales incorrectas' })
  }

  const usuario = rows[0]

  // Usuario inactivo
  if (!usuario.activo) {
    return res.status(401).json({ error: 'Cuenta desactivada. Contacte al administrador.' })
  }

  // Verificar si está bloqueado por intentos fallidos
  if (usuario.bloqueado_hasta && new Date(usuario.bloqueado_hasta) > new Date()) {
    const minutosRestantes = Math.ceil(
      (new Date(usuario.bloqueado_hasta) - new Date()) / 60000
    )
    return res.status(429).json({
      error: `Cuenta bloqueada por intentos fallidos. Intente de nuevo en ${minutosRestantes} minuto(s).`,
      bloqueado_hasta: usuario.bloqueado_hasta,
    })
  }

  // Verificar contraseña
  const passwordValida = await bcrypt.compare(password, usuario.password_hash)

  if (!passwordValida) {
    const nuevosIntentos = (usuario.intentos_fallidos || 0) + 1
    const debeBloquear = nuevosIntentos >= MAX_INTENTOS

    await pool.query(
      `UPDATE adm_usuarios
       SET intentos_fallidos = $1,
           bloqueado_hasta = $2
       WHERE id = $3`,
      [
        nuevosIntentos,
        debeBloquear
          ? new Date(Date.now() + BLOQUEO_MINUTOS * 60 * 1000)
          : null,
        usuario.id,
      ]
    )

    // Registrar intento fallido en bitácora
    await auditLog({
      usuario_id: usuario.id,
      accion: 'LOGIN',
      tabla_afectada: 'adm_usuarios',
      registro_id: usuario.id,
      datos_nuevos: { exito: false, intentos: nuevosIntentos, bloqueado: debeBloquear },
      ip,
      user_agent: userAgent,
    })

    if (debeBloquear) {
      return res.status(429).json({
        error: `Demasiados intentos fallidos. Cuenta bloqueada por ${BLOQUEO_MINUTOS} minutos.`,
      })
    }

    return res.status(401).json({
      error: 'Credenciales incorrectas',
      intentos_restantes: MAX_INTENTOS - nuevosIntentos,
    })
  }

  // Credenciales válidas — buscar datos de personal de salud
  const { rows: personalRows } = await pool.query(
    `SELECT id, nombre_completo, unidad_medica_id, tipo_personal_id, cedula_profesional
     FROM adm_personal_salud
     WHERE usuario_id = $1
     LIMIT 1`,
    [usuario.id]
  )
  const personal = personalRows[0] || null

  // Resetear intentos fallidos y actualizar último acceso
  await pool.query(
    `UPDATE adm_usuarios
     SET intentos_fallidos = 0,
         bloqueado_hasta = NULL,
         ultimo_acceso = NOW()
     WHERE id = $1`,
    [usuario.id]
  )

  // Payload del token
  const tokenPayload = {
    sub: usuario.id,
    email: usuario.email,
    curp: usuario.curp,
    rol: usuario.rol_clave,
    rol_id: usuario.rol_id,
    nombre: personal?.nombre_completo || usuario.email,
    personal_id: personal?.id || null,
    unidad_medica_id: personal?.unidad_medica_id || null,
  }

  const accessToken = generarAccessToken(tokenPayload)
  const refreshToken = generarRefreshToken(usuario.id)

  // Cookie HttpOnly con refresh token
  res.cookie('refreshToken', refreshToken, cookieOpciones())

  // Registrar login exitoso en bitácora
  await auditLog({
    usuario_id: usuario.id,
    accion: 'LOGIN',
    tabla_afectada: 'adm_usuarios',
    registro_id: usuario.id,
    datos_nuevos: { exito: true, rol: usuario.rol_clave },
    ip,
    user_agent: userAgent,
  })

  res.json({
    accessToken,
    usuario: {
      id: usuario.id,
      email: usuario.email,
      curp: usuario.curp,
      nombre: tokenPayload.nombre,
      rol: usuario.rol_clave,
      rol_nombre: usuario.rol_nombre,
      unidad_medica_id: tokenPayload.unidad_medica_id,
    },
  })
}

/**
 * POST /api/auth/refresh
 * Lee el refresh token de la cookie HttpOnly y emite un nuevo access token.
 */
export async function refresh(req, res) {
  const token = req.cookies?.refreshToken

  if (!token) {
    return res.status(401).json({ error: 'Refresh token no encontrado' })
  }

  let payload
  try {
    payload = jwt.verify(token, process.env.REFRESH_TOKEN_SECRET)
  } catch {
    return res.status(401).json({ error: 'Refresh token inválido o expirado' })
  }

  if (payload.type !== 'refresh') {
    return res.status(401).json({ error: 'Token de tipo incorrecto' })
  }

  // Verificar que el usuario sigue activo en BD
  const { rows } = await pool.query(
    `SELECT
       u.id, u.curp, u.email, u.activo,
       r.id AS rol_id, r.clave AS rol_clave, r.nombre AS rol_nombre
     FROM adm_usuarios u
     LEFT JOIN cat_roles r ON u.rol_id = r.id
     WHERE u.id = $1`,
    [payload.sub]
  )

  if (rows.length === 0 || !rows[0].activo) {
    res.clearCookie('refreshToken', { path: '/api/auth' })
    return res.status(401).json({ error: 'Usuario no encontrado o inactivo' })
  }

  const usuario = rows[0]

  const { rows: personalRows } = await pool.query(
    `SELECT id, nombre_completo, unidad_medica_id FROM adm_personal_salud WHERE usuario_id = $1 LIMIT 1`,
    [usuario.id]
  )
  const personal = personalRows[0] || null

  const tokenPayload = {
    sub: usuario.id,
    email: usuario.email,
    curp: usuario.curp,
    rol: usuario.rol_clave,
    rol_id: usuario.rol_id,
    nombre: personal?.nombre_completo || usuario.email,
    personal_id: personal?.id || null,
    unidad_medica_id: personal?.unidad_medica_id || null,
  }

  const accessToken = generarAccessToken(tokenPayload)
  res.json({ accessToken })
}

/**
 * POST /api/auth/logout
 */
export async function logout(req, res) {
  const ip = getClientIp(req)
  const userAgent = req.headers['user-agent'] || null

  if (req.user) {
    await auditLog({
      usuario_id: req.user.sub,
      accion: 'LOGOUT',
      tabla_afectada: 'adm_usuarios',
      registro_id: req.user.sub,
      datos_nuevos: { accion: 'cierre_sesion' },
      ip,
      user_agent: userAgent,
    })
  }

  res.clearCookie('refreshToken', { path: '/api/auth' })
  res.json({ mensaje: 'Sesión cerrada correctamente' })
}

/**
 * GET /api/auth/me
 * Retorna los datos del usuario autenticado (desde el JWT).
 */
export async function me(req, res) {
  res.json({ usuario: req.user })
}
