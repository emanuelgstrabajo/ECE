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

/**
 * Genera refresh token. Incluye asignacion_id para que el refresh
 * restaure el mismo contexto de unidad/rol que la sesión activa.
 */
function generarRefreshToken(sub, asignacion_id = null) {
  return jwt.sign(
    { sub, asignacion_id, type: 'refresh' },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: process.env.REFRESH_TOKEN_EXPIRY || '7d' }
  )
}

/**
 * Token temporal de corta duración emitido cuando el usuario tiene
 * múltiples asignaciones activas y debe seleccionar una unidad.
 * Contiene solo sub y type — sin datos de rol ni unidad.
 */
function generarPreToken(sub) {
  return jwt.sign(
    { sub, type: 'unit_selection' },
    process.env.ACCESS_TOKEN_SECRET,
    { expiresIn: '5m' }
  )
}

function cookieOpciones() {
  return {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000,
    path: '/api/auth',
  }
}

/**
 * Carga las asignaciones activas de un usuario desde adm_usuario_unidad_rol.
 * Retorna array de asignaciones con datos de unidad y rol.
 */
async function cargarAsignaciones(usuario_id) {
  const { rows } = await pool.query(
    `SELECT
       a.id            AS asignacion_id,
       a.unidad_medica_id,
       a.rol_id,
       a.fecha_inicio,
       r.clave         AS rol_clave,
       r.nombre        AS rol_nombre,
       um.nombre       AS unidad_nombre,
       um.clues
     FROM adm_usuario_unidad_rol a
     JOIN cat_roles r            ON a.rol_id = r.id
     JOIN adm_unidades_medicas um ON a.unidad_medica_id = um.id
     WHERE a.usuario_id = $1
       AND a.activo = TRUE
     ORDER BY um.nombre, r.clave`,
    [usuario_id]
  )
  return rows
}

/**
 * Construye el payload completo del access token para un usuario con
 * una asignación de unidad/rol específica.
 */
async function construirPayload(usuario, asignacion) {
  const { rows: personalRows } = await pool.query(
    `SELECT id, nombre_completo FROM adm_personal_salud WHERE usuario_id = $1`,
    [usuario.id]
  )
  const personal = personalRows[0] || null

  return {
    sub: usuario.id,
    email: usuario.email,
    curp: usuario.curp,
    rol: asignacion.rol_clave,
    rol_id: asignacion.rol_id,
    unidad_medica_id: asignacion.unidad_medica_id,
    asignacion_id: asignacion.asignacion_id,
    nombre: personal?.nombre_completo || usuario.email,
    personal_id: personal?.id || null,
  }
}

/**
 * Construye el payload para SUPERADMIN (sin unidad).
 */
async function construirPayloadSuperAdmin(usuario) {
  const { rows: personalRows } = await pool.query(
    `SELECT id, nombre_completo FROM adm_personal_salud WHERE usuario_id = $1`,
    [usuario.id]
  )
  const personal = personalRows[0] || null

  return {
    sub: usuario.id,
    email: usuario.email,
    curp: usuario.curp,
    rol: usuario.rol_clave,
    rol_id: usuario.rol_id,
    unidad_medica_id: null,
    asignacion_id: null,
    nombre: personal?.nombre_completo || usuario.email,
    personal_id: personal?.id || null,
  }
}

// ---------------------------------------------------------------------------

/**
 * POST /api/auth/login
 * Body: { identificador: string, password: string }
 *
 * Flujo multi-unidad:
 *  - SUPERADMIN → token directo (sin unidad)
 *  - 1 asignación activa → token directo con esa unidad/rol
 *  - N asignaciones activas → pre_token + lista para selector de unidad
 *  - 0 asignaciones → 401
 */
export async function login(req, res) {
  const { identificador, password } = req.body
  const ip = getClientIp(req)
  const userAgent = req.headers['user-agent'] || null

  if (!identificador || !password) {
    return res.status(400).json({ error: 'Identificador y contraseña son requeridos' })
  }

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

  if (rows.length === 0) {
    return res.status(401).json({ error: 'Credenciales incorrectas' })
  }

  const usuario = rows[0]

  if (!usuario.activo) {
    return res.status(401).json({ error: 'Cuenta desactivada. Contacte al administrador.' })
  }

  if (usuario.bloqueado_hasta && new Date(usuario.bloqueado_hasta) > new Date()) {
    const minutosRestantes = Math.ceil(
      (new Date(usuario.bloqueado_hasta) - new Date()) / 60000
    )
    return res.status(429).json({
      error: `Cuenta bloqueada por intentos fallidos. Intente de nuevo en ${minutosRestantes} minuto(s).`,
      bloqueado_hasta: usuario.bloqueado_hasta,
    })
  }

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
        debeBloquear ? new Date(Date.now() + BLOQUEO_MINUTOS * 60 * 1000) : null,
        usuario.id,
      ]
    )

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

  // Credenciales válidas — resetear intentos y marcar último acceso
  await pool.query(
    `UPDATE adm_usuarios
     SET intentos_fallidos = 0,
         bloqueado_hasta = NULL,
         ultimo_acceso = NOW()
     WHERE id = $1`,
    [usuario.id]
  )

  // ── Lógica multi-unidad ────────────────────────────────────────────

  // SUPERADMIN: token directo, sin selección de unidad
  if (usuario.rol_clave === 'SUPERADMIN') {
    const tokenPayload = await construirPayloadSuperAdmin(usuario)
    const accessToken  = generarAccessToken(tokenPayload)
    const refreshToken = generarRefreshToken(usuario.id, null)

    res.cookie('refreshToken', refreshToken, cookieOpciones())

    await auditLog({
      usuario_id: usuario.id,
      accion: 'LOGIN',
      tabla_afectada: 'adm_usuarios',
      registro_id: usuario.id,
      datos_nuevos: { exito: true, rol: usuario.rol_clave },
      ip,
      user_agent: userAgent,
    })

    return res.json({
      accessToken,
      usuario: {
        id: usuario.id,
        email: usuario.email,
        curp: usuario.curp,
        nombre: tokenPayload.nombre,
        rol: usuario.rol_clave,
        rol_nombre: usuario.rol_nombre,
        unidad_medica_id: null,
      },
    })
  }

  // Roles operativos: cargar asignaciones activas
  const asignaciones = await cargarAsignaciones(usuario.id)

  if (asignaciones.length === 0) {
    await auditLog({
      usuario_id: usuario.id,
      accion: 'LOGIN',
      tabla_afectada: 'adm_usuarios',
      registro_id: usuario.id,
      datos_nuevos: { exito: false, motivo: 'sin_asignaciones' },
      ip,
      user_agent: userAgent,
    })
    return res.status(401).json({
      error: 'Su usuario no tiene asignaciones activas en ninguna unidad médica. Contacte al administrador.',
    })
  }

  // Una sola asignación → token directo
  if (asignaciones.length === 1) {
    const tokenPayload = await construirPayload(usuario, asignaciones[0])
    const accessToken  = generarAccessToken(tokenPayload)
    const refreshToken = generarRefreshToken(usuario.id, asignaciones[0].asignacion_id)

    res.cookie('refreshToken', refreshToken, cookieOpciones())

    await auditLog({
      usuario_id: usuario.id,
      accion: 'LOGIN',
      tabla_afectada: 'adm_usuarios',
      registro_id: usuario.id,
      datos_nuevos: {
        exito: true,
        rol: asignaciones[0].rol_clave,
        unidad_medica_id: asignaciones[0].unidad_medica_id,
      },
      ip,
      user_agent: userAgent,
    })

    return res.json({
      accessToken,
      usuario: {
        id: usuario.id,
        email: usuario.email,
        curp: usuario.curp,
        nombre: tokenPayload.nombre,
        rol: asignaciones[0].rol_clave,
        rol_nombre: asignaciones[0].rol_nombre,
        unidad_medica_id: asignaciones[0].unidad_medica_id,
        unidad_nombre: asignaciones[0].unidad_nombre,
      },
    })
  }

  // Múltiples asignaciones → pre_token + lista para selector
  const preToken = generarPreToken(usuario.id)

  await auditLog({
    usuario_id: usuario.id,
    accion: 'LOGIN',
    tabla_afectada: 'adm_usuarios',
    registro_id: usuario.id,
    datos_nuevos: { exito: true, requires_unit_selection: true, num_asignaciones: asignaciones.length },
    ip,
    user_agent: userAgent,
  })

  return res.json({
    requires_unit_selection: true,
    pre_token: preToken,
    unidades: asignaciones.map(a => ({
      asignacion_id:    a.asignacion_id,
      unidad_medica_id: a.unidad_medica_id,
      unidad_nombre:    a.unidad_nombre,
      clues:            a.clues,
      rol_clave:        a.rol_clave,
      rol_nombre:       a.rol_nombre,
    })),
  })
}

// ---------------------------------------------------------------------------

/**
 * POST /api/auth/seleccionar-unidad
 * Body: { asignacion_id: "uuid" }
 * Header: Authorization: Bearer <pre_token>
 *
 * Valida el pre_token, verifica que la asignación pertenece al usuario
 * y emite el access token completo con el contexto seleccionado.
 */
export async function seleccionarUnidad(req, res) {
  const authHeader = req.headers['authorization']
  const preToken = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null
  const ip = getClientIp(req)
  const userAgent = req.headers['user-agent'] || null

  if (!preToken) {
    return res.status(401).json({ error: 'Pre-token requerido' })
  }

  let payload
  try {
    payload = jwt.verify(preToken, process.env.ACCESS_TOKEN_SECRET)
  } catch {
    return res.status(401).json({ error: 'Pre-token inválido o expirado' })
  }

  if (payload.type !== 'unit_selection') {
    return res.status(401).json({ error: 'Token de tipo incorrecto' })
  }

  const { asignacion_id } = req.body
  if (!asignacion_id) {
    return res.status(400).json({ error: 'asignacion_id es requerido' })
  }

  // Verificar que la asignación pertenece al usuario y está activa
  const { rows } = await pool.query(
    `SELECT
       a.id AS asignacion_id,
       a.usuario_id,
       a.unidad_medica_id,
       a.rol_id,
       r.clave  AS rol_clave,
       r.nombre AS rol_nombre,
       um.nombre AS unidad_nombre,
       um.clues
     FROM adm_usuario_unidad_rol a
     JOIN cat_roles r            ON a.rol_id = r.id
     JOIN adm_unidades_medicas um ON a.unidad_medica_id = um.id
     WHERE a.id = $1
       AND a.usuario_id = $2
       AND a.activo = TRUE`,
    [asignacion_id, payload.sub]
  )

  if (!rows[0]) {
    return res.status(403).json({ error: 'Asignación no válida o no pertenece a este usuario' })
  }

  const asignacion = rows[0]

  // Verificar usuario aún activo en BD
  const { rows: uRows } = await pool.query(
    `SELECT u.id, u.curp, u.email, u.activo
     FROM adm_usuarios u
     WHERE u.id = $1`,
    [payload.sub]
  )
  if (!uRows[0] || !uRows[0].activo) {
    return res.status(401).json({ error: 'Usuario no encontrado o inactivo' })
  }

  const usuario = uRows[0]
  const tokenPayload = await construirPayload(usuario, asignacion)

  const accessToken  = generarAccessToken(tokenPayload)
  const refreshToken = generarRefreshToken(usuario.id, asignacion_id)

  res.cookie('refreshToken', refreshToken, cookieOpciones())

  await auditLog({
    usuario_id: usuario.id,
    accion: 'LOGIN',
    tabla_afectada: 'adm_usuario_unidad_rol',
    registro_id: asignacion_id,
    datos_nuevos: {
      exito: true,
      unidad_seleccionada: asignacion.unidad_medica_id,
      rol: asignacion.rol_clave,
    },
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
      rol: asignacion.rol_clave,
      rol_nombre: asignacion.rol_nombre,
      unidad_medica_id: asignacion.unidad_medica_id,
      unidad_nombre: asignacion.unidad_nombre,
    },
  })
}

// ---------------------------------------------------------------------------

/**
 * POST /api/auth/refresh
 * Lee el refresh token de la cookie HttpOnly y emite un nuevo access token
 * restaurando el mismo contexto de unidad/rol de la sesión anterior.
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

  // Verificar usuario activo
  const { rows } = await pool.query(
    `SELECT
       u.id, u.curp, u.email, u.activo,
       r.id AS rol_id, r.clave AS rol_clave
     FROM adm_usuarios u
     LEFT JOIN cat_roles r ON u.rol_id = r.id
     WHERE u.id = $1`,
    [payload.sub]
  )

  if (!rows[0] || !rows[0].activo) {
    res.clearCookie('refreshToken', { path: '/api/auth' })
    return res.status(401).json({ error: 'Usuario no encontrado o inactivo' })
  }

  const usuario = rows[0]

  // SUPERADMIN
  if (usuario.rol_clave === 'SUPERADMIN') {
    const tokenPayload = await construirPayloadSuperAdmin(usuario)
    const accessToken  = generarAccessToken(tokenPayload)
    return res.json({ accessToken })
  }

  // Roles operativos: restaurar el contexto de unidad del refresh token
  const asignacion_id = payload.asignacion_id
  if (!asignacion_id) {
    res.clearCookie('refreshToken', { path: '/api/auth' })
    return res.status(401).json({ error: 'Sesión sin unidad seleccionada. Inicie sesión nuevamente.' })
  }

  const { rows: aRows } = await pool.query(
    `SELECT
       a.id AS asignacion_id,
       a.unidad_medica_id,
       a.rol_id,
       r.clave  AS rol_clave,
       r.nombre AS rol_nombre,
       um.nombre AS unidad_nombre,
       um.clues
     FROM adm_usuario_unidad_rol a
     JOIN cat_roles r            ON a.rol_id = r.id
     JOIN adm_unidades_medicas um ON a.unidad_medica_id = um.id
     WHERE a.id = $1
       AND a.usuario_id = $2
       AND a.activo = TRUE`,
    [asignacion_id, usuario.id]
  )

  if (!aRows[0]) {
    // La asignación fue revocada mientras la sesión estaba activa
    res.clearCookie('refreshToken', { path: '/api/auth' })
    return res.status(401).json({
      error: 'Su asignación a esta unidad fue revocada. Inicie sesión nuevamente.',
      code: 'ASSIGNMENT_REVOKED',
    })
  }

  const tokenPayload = await construirPayload(usuario, aRows[0])
  const accessToken  = generarAccessToken(tokenPayload)

  res.json({ accessToken })
}

// ---------------------------------------------------------------------------

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
      datos_nuevos: { accion: 'cierre_sesion', asignacion_id: req.user.asignacion_id || null },
      ip,
      user_agent: userAgent,
    })
  }

  res.clearCookie('refreshToken', { path: '/api/auth' })
  res.json({ mensaje: 'Sesión cerrada correctamente' })
}

/**
 * GET /api/auth/me
 */
export async function me(req, res) {
  res.json({ usuario: req.user })
}
