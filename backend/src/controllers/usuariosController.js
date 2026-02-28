import bcrypt from 'bcrypt'
import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'

const SALT_ROUNDS = 12

/**
 * GET /api/admin/usuarios
 */
export async function listar(req, res) {
  const page   = Math.max(1, parseInt(req.query.page) || 1)
  const limit  = Math.min(100, parseInt(req.query.limit) || 20)
  const offset = (page - 1) * limit
  const search = req.query.search?.trim() || ''

  const { rows } = await pool.query(
    `SELECT
       u.id, u.curp, u.email, u.activo, u.ultimo_acceso,
       u.intentos_fallidos, u.bloqueado_hasta,
       r.id AS rol_id, r.clave AS rol_clave, r.nombre AS rol_nombre,
       p.id AS personal_id, p.nombre_completo,
       COUNT(*) OVER() AS total
     FROM adm_usuarios u
     LEFT JOIN cat_roles r ON u.rol_id = r.id
     LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
     WHERE ($1 = '' OR u.email ILIKE $2 OR UPPER(u.curp) ILIKE $2 OR p.nombre_completo ILIKE $2)
     ORDER BY u.email
     LIMIT $3 OFFSET $4`,
    [search, `%${search}%`, limit, offset]
  )

  const total = rows[0]?.total ? parseInt(rows[0].total) : 0
  res.json({
    data: rows,
    pagination: { total, page, limit, pages: Math.ceil(total / limit) },
  })
}

/**
 * GET /api/admin/usuarios/:id
 */
export async function obtener(req, res) {
  const { rows } = await pool.query(
    `SELECT
       u.id, u.curp, u.email, u.activo, u.ultimo_acceso,
       u.intentos_fallidos, u.bloqueado_hasta,
       r.id AS rol_id, r.clave AS rol_clave, r.nombre AS rol_nombre,
       p.id AS personal_id, p.nombre_completo, p.cedula_profesional,
       p.unidad_medica_id, p.tipo_personal_id,
       um.nombre AS unidad_nombre, um.clues
     FROM adm_usuarios u
     LEFT JOIN cat_roles r ON u.rol_id = r.id
     LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
     LEFT JOIN adm_unidades_medicas um ON p.unidad_medica_id = um.id
     WHERE u.id = $1`,
    [req.params.id]
  )
  if (!rows[0]) return res.status(404).json({ error: 'Usuario no encontrado' })
  res.json({ data: rows[0] })
}

/**
 * POST /api/admin/usuarios
 * Crea usuario y opcionalmente su registro de personal_salud.
 */
export async function crear(req, res) {
  const {
    curp, email, password, rol_id,
    // Datos de personal (solo para roles operativos)
    nombre_completo, unidad_medica_id, tipo_personal_id, cedula_profesional,
  } = req.body

  if (!curp || !email || !password || !rol_id) {
    return res.status(400).json({ error: 'CURP, email, contraseña y rol son requeridos' })
  }

  if (password.length < 8) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 8 caracteres' })
  }

  // Verificar unicidad
  const dup = await pool.query(
    'SELECT id FROM adm_usuarios WHERE LOWER(email) = LOWER($1) OR UPPER(curp) = UPPER($2)',
    [email, curp]
  )
  if (dup.rows.length) {
    return res.status(409).json({ error: 'Ya existe un usuario con ese email o CURP' })
  }

  const password_hash = await bcrypt.hash(password, SALT_ROUNDS)

  const client = await pool.connect()
  try {
    await client.query('BEGIN')

    const { rows } = await client.query(
      `INSERT INTO adm_usuarios (curp, email, password_hash, rol_id)
       VALUES ($1, $2, $3, $4)
       RETURNING id, curp, email, activo, rol_id`,
      [curp.toUpperCase(), email.toLowerCase(), password_hash, rol_id]
    )
    const usuario = rows[0]

    // Crear personal_salud si se proporcionan datos
    if (nombre_completo) {
      await client.query(
        `INSERT INTO adm_personal_salud
           (usuario_id, nombre_completo, unidad_medica_id, tipo_personal_id, cedula_profesional)
         VALUES ($1, $2, $3, $4, $5)`,
        [usuario.id, nombre_completo, unidad_medica_id || null,
         tipo_personal_id || null, cedula_profesional || null]
      )
    }

    await client.query('COMMIT')

    await auditLog({
      usuario_id: req.user.sub,
      accion: 'CREATE',
      tabla_afectada: 'adm_usuarios',
      registro_id: usuario.id,
      datos_nuevos: { email: usuario.email, curp: usuario.curp, rol_id },
      ip: getClientIp(req),
      user_agent: req.headers['user-agent'],
      client,
    })

    res.status(201).json({ data: usuario, mensaje: 'Usuario creado exitosamente' })
  } catch (err) {
    await client.query('ROLLBACK')
    throw err
  } finally {
    client.release()
  }
}

/**
 * PUT /api/admin/usuarios/:id
 */
export async function actualizar(req, res) {
  const { id } = req.params
  const { email, rol_id, activo } = req.body

  // No permitir auto-edición del propio rol/activo (protección básica)
  if (id === req.user.sub && activo === false) {
    return res.status(400).json({ error: 'No puede desactivar su propio usuario' })
  }

  const anterior = await pool.query('SELECT id, email, rol_id, activo FROM adm_usuarios WHERE id = $1', [id])
  if (!anterior.rows[0]) return res.status(404).json({ error: 'Usuario no encontrado' })

  const { rows } = await pool.query(
    `UPDATE adm_usuarios
     SET email  = COALESCE($1, email),
         rol_id = COALESCE($2, rol_id),
         activo = COALESCE($3, activo)
     WHERE id = $4
     RETURNING id, email, rol_id, activo`,
    [email ? email.toLowerCase() : null, rol_id, activo, id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'adm_usuarios',
    registro_id: id,
    datos_anteriores: anterior.rows[0],
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ data: rows[0], mensaje: 'Usuario actualizado exitosamente' })
}

/**
 * POST /api/admin/usuarios/:id/reset-password
 */
export async function resetPassword(req, res) {
  const { id } = req.params
  const { nueva_password } = req.body

  if (!nueva_password || nueva_password.length < 8) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 8 caracteres' })
  }

  const existe = await pool.query('SELECT id FROM adm_usuarios WHERE id = $1', [id])
  if (!existe.rows[0]) return res.status(404).json({ error: 'Usuario no encontrado' })

  const password_hash = await bcrypt.hash(nueva_password, SALT_ROUNDS)

  await pool.query(
    `UPDATE adm_usuarios
     SET password_hash = $1, intentos_fallidos = 0, bloqueado_hasta = NULL
     WHERE id = $2`,
    [password_hash, id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'adm_usuarios',
    registro_id: id,
    datos_nuevos: { accion: 'reset_password' },
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ mensaje: 'Contraseña actualizada exitosamente' })
}

/**
 * POST /api/admin/usuarios/:id/desbloquear
 */
export async function desbloquear(req, res) {
  const { id } = req.params

  await pool.query(
    'UPDATE adm_usuarios SET intentos_fallidos = 0, bloqueado_hasta = NULL WHERE id = $1',
    [id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'adm_usuarios',
    registro_id: id,
    datos_nuevos: { accion: 'desbloquear_cuenta' },
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ mensaje: 'Cuenta desbloqueada exitosamente' })
}
