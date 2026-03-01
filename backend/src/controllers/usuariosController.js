import bcrypt from 'bcrypt'
import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'

const SALT_ROUNDS = 12

/**
 * GET /api/admin/usuarios
 * Lista usuarios con sus asignaciones activas agregadas.
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
       -- Asignaciones activas como array JSON
       COALESCE(
         json_agg(
           json_build_object(
             'asignacion_id',    a.id,
             'unidad_medica_id', a.unidad_medica_id,
             'unidad_nombre',    um.nombre,
             'rol_clave',        ra.clave,
             'rol_nombre',       ra.nombre
           )
         ) FILTER (WHERE a.id IS NOT NULL),
         '[]'
       ) AS asignaciones,
       COUNT(*) OVER() AS total
     FROM adm_usuarios u
     LEFT JOIN cat_roles r                ON u.rol_id = r.id
     LEFT JOIN adm_personal_salud p       ON p.usuario_id = u.id
     LEFT JOIN adm_usuario_unidad_rol a   ON a.usuario_id = u.id AND a.activo = TRUE
     LEFT JOIN adm_unidades_medicas um    ON a.unidad_medica_id = um.id
     LEFT JOIN cat_roles ra               ON a.rol_id = ra.id
     WHERE ($1 = '' OR u.email ILIKE $2 OR UPPER(u.curp) ILIKE $2 OR p.nombre_completo ILIKE $2)
     GROUP BY u.id, u.curp, u.email, u.activo, u.ultimo_acceso,
              u.intentos_fallidos, u.bloqueado_hasta,
              r.id, r.clave, r.nombre,
              p.id, p.nombre_completo
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
       p.id AS personal_id, p.nombre_completo, p.cedula_profesional, p.tipo_personal_id,
       COALESCE(
         json_agg(
           json_build_object(
             'asignacion_id',    a.id,
             'unidad_medica_id', a.unidad_medica_id,
             'unidad_nombre',    um.nombre,
             'clues',            um.clues,
             'rol_id',           a.rol_id,
             'rol_clave',        ra.clave,
             'rol_nombre',       ra.nombre,
             'fecha_inicio',     a.fecha_inicio,
             'activo',           a.activo
           )
         ) FILTER (WHERE a.id IS NOT NULL),
         '[]'
       ) AS asignaciones
     FROM adm_usuarios u
     LEFT JOIN cat_roles r                ON u.rol_id = r.id
     LEFT JOIN adm_personal_salud p       ON p.usuario_id = u.id
     LEFT JOIN adm_usuario_unidad_rol a   ON a.usuario_id = u.id AND a.activo = TRUE
     LEFT JOIN adm_unidades_medicas um    ON a.unidad_medica_id = um.id
     LEFT JOIN cat_roles ra               ON a.rol_id = ra.id
     WHERE u.id = $1
     GROUP BY u.id, u.curp, u.email, u.activo, u.ultimo_acceso,
              u.intentos_fallidos, u.bloqueado_hasta,
              r.id, r.clave, r.nombre,
              p.id, p.nombre_completo, p.cedula_profesional, p.tipo_personal_id`,
    [req.params.id]
  )
  if (!rows[0]) return res.status(404).json({ error: 'Usuario no encontrado' })
  res.json({ data: rows[0] })
}

/**
 * POST /api/admin/usuarios
 * Crea usuario y, opcionalmente, su perfil de personal de salud.
 * Las asignaciones a unidades se crean por separado.
 */
export async function crear(req, res) {
  const {
    curp, email, password, rol_id,
    // Datos de perfil profesional — campos desglosados (Fase 2+)
    primer_nombre, segundo_nombre, apellido_paterno, apellido_materno,
    tipo_personal_id, cedula_profesional,
    // Compatibilidad legacy: si se manda nombre_completo directamente
    nombre_completo: nombre_completo_directo,
  } = req.body

  if (!curp || !email || !password || !rol_id) {
    return res.status(400).json({ error: 'CURP, email, contraseña y rol son requeridos' })
  }

  if (password.length < 8) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 8 caracteres' })
  }

  const dup = await pool.query(
    'SELECT id FROM adm_usuarios WHERE LOWER(email) = LOWER($1) OR UPPER(curp) = UPPER($2)',
    [email, curp]
  )
  if (dup.rows.length) {
    return res.status(409).json({ error: 'Ya existe un usuario con ese email o CURP' })
  }

  // Calcular nombre_completo a partir de partes o usar el directo
  const partes = [apellido_paterno, apellido_materno, primer_nombre, segundo_nombre].filter(Boolean)
  const nombre_completo = partes.length > 0 ? partes.join(' ') : nombre_completo_directo || null

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

    // Crear perfil profesional si se proporcionan datos de nombre
    if (nombre_completo) {
      await client.query(
        `INSERT INTO adm_personal_salud
           (usuario_id, nombre_completo, primer_nombre, segundo_nombre,
            apellido_paterno, apellido_materno, tipo_personal_id, cedula_profesional)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [
          usuario.id, nombre_completo,
          primer_nombre || null, segundo_nombre || null,
          apellido_paterno || null, apellido_materno || null,
          tipo_personal_id || null, cedula_profesional || null,
        ]
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
