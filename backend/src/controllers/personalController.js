import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'

// ============================================================================
// PERFIL PROFESIONAL — adm_personal_salud
// (sin unidad_medica_id — las asignaciones a unidades viven en adm_usuario_unidad_rol)
// ============================================================================

/**
 * GET /api/admin/personal
 * Lista perfiles profesionales con sus asignaciones activas agregadas.
 */
export async function listar(req, res) {
  const page    = Math.max(1, parseInt(req.query.page) || 1)
  const limit   = Math.min(100, parseInt(req.query.limit) || 20)
  const offset  = (page - 1) * limit
  const search  = req.query.search?.trim() || ''
  const unidad_id = req.query.unidad_id ? parseInt(req.query.unidad_id) : null

  const { rows } = await pool.query(
    `SELECT
       p.id, p.nombre_completo, p.cedula_profesional,
       p.usuario_id, p.tipo_personal_id,
       u.email, u.curp, u.activo AS usuario_activo,
       tp.descripcion AS tipo_personal,
       -- Asignaciones activas como array JSON
       COALESCE(
         json_agg(
           json_build_object(
             'asignacion_id',    a.id,
             'unidad_medica_id', a.unidad_medica_id,
             'unidad_nombre',    um.nombre,
             'clues',            um.clues,
             'rol_clave',        r.clave,
             'rol_nombre',       r.nombre,
             'fecha_inicio',     a.fecha_inicio
           )
         ) FILTER (WHERE a.id IS NOT NULL),
         '[]'
       ) AS asignaciones,
       COUNT(*) OVER() AS total
     FROM adm_personal_salud p
     LEFT JOIN adm_usuarios u             ON p.usuario_id = u.id
     LEFT JOIN cat_tipos_personal tp      ON p.tipo_personal_id = tp.id
     LEFT JOIN adm_usuario_unidad_rol a   ON a.usuario_id = p.usuario_id AND a.activo = TRUE
     LEFT JOIN adm_unidades_medicas um    ON a.unidad_medica_id = um.id
     LEFT JOIN cat_roles r                ON a.rol_id = r.id
     WHERE ($1 = '' OR p.nombre_completo ILIKE $2 OR u.email ILIKE $2)
       AND ($3::int IS NULL OR a.unidad_medica_id = $3)
     GROUP BY p.id, p.nombre_completo, p.cedula_profesional, p.usuario_id,
              p.tipo_personal_id, u.email, u.curp, u.activo, tp.descripcion
     ORDER BY p.nombre_completo
     LIMIT $4 OFFSET $5`,
    [search, `%${search}%`, unidad_id, limit, offset]
  )

  const total = rows[0]?.total ? parseInt(rows[0].total) : 0
  res.json({
    data: rows,
    pagination: { total, page, limit, pages: Math.ceil(total / limit) },
  })
}

/**
 * GET /api/admin/personal/:id
 */
export async function obtener(req, res) {
  const { rows } = await pool.query(
    `SELECT
       p.id, p.nombre_completo, p.cedula_profesional,
       p.usuario_id, p.tipo_personal_id,
       u.email, u.curp, u.activo AS usuario_activo, u.rol_id,
       tp.descripcion AS tipo_personal,
       COALESCE(
         json_agg(
           json_build_object(
             'asignacion_id',    a.id,
             'unidad_medica_id', a.unidad_medica_id,
             'unidad_nombre',    um.nombre,
             'clues',            um.clues,
             'rol_clave',        r.clave,
             'rol_nombre',       r.nombre,
             'fecha_inicio',     a.fecha_inicio,
             'activo',           a.activo
           )
         ) FILTER (WHERE a.id IS NOT NULL),
         '[]'
       ) AS asignaciones
     FROM adm_personal_salud p
     LEFT JOIN adm_usuarios u             ON p.usuario_id = u.id
     LEFT JOIN cat_tipos_personal tp      ON p.tipo_personal_id = tp.id
     LEFT JOIN adm_usuario_unidad_rol a   ON a.usuario_id = p.usuario_id AND a.activo = TRUE
     LEFT JOIN adm_unidades_medicas um    ON a.unidad_medica_id = um.id
     LEFT JOIN cat_roles r                ON a.rol_id = r.id
     WHERE p.id = $1
     GROUP BY p.id, p.nombre_completo, p.cedula_profesional, p.usuario_id,
              p.tipo_personal_id, u.email, u.curp, u.activo, u.rol_id, tp.descripcion`,
    [req.params.id]
  )
  if (!rows[0]) return res.status(404).json({ error: 'Registro de personal no encontrado' })
  res.json({ data: rows[0] })
}

/**
 * POST /api/admin/personal
 * Crea perfil profesional puro. Las asignaciones a unidades se crean
 * por separado en POST /api/admin/usuarios/:id/asignaciones.
 */
export async function crear(req, res) {
  const { usuario_id, nombre_completo, tipo_personal_id, cedula_profesional } = req.body

  if (!nombre_completo || !tipo_personal_id) {
    return res.status(400).json({ error: 'Nombre completo y tipo de personal son requeridos' })
  }

  if (usuario_id) {
    const u = await pool.query('SELECT id FROM adm_usuarios WHERE id = $1', [usuario_id])
    if (!u.rows[0]) return res.status(400).json({ error: 'Usuario no encontrado' })
    const dup = await pool.query('SELECT id FROM adm_personal_salud WHERE usuario_id = $1', [usuario_id])
    if (dup.rows[0]) return res.status(409).json({ error: 'Este usuario ya tiene un registro de personal de salud' })
  }

  const { rows } = await pool.query(
    `INSERT INTO adm_personal_salud (usuario_id, nombre_completo, tipo_personal_id, cedula_profesional)
     VALUES ($1, $2, $3, $4)
     RETURNING id, nombre_completo, usuario_id, tipo_personal_id`,
    [usuario_id || null, nombre_completo, tipo_personal_id, cedula_profesional || null]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'CREATE',
    tabla_afectada: 'adm_personal_salud',
    registro_id: rows[0].id,
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.status(201).json({ data: rows[0], mensaje: 'Personal registrado exitosamente' })
}

/**
 * PUT /api/admin/personal/:id
 */
export async function actualizar(req, res) {
  const { id } = req.params
  const { nombre_completo, tipo_personal_id, cedula_profesional } = req.body

  const anterior = await pool.query('SELECT * FROM adm_personal_salud WHERE id = $1', [id])
  if (!anterior.rows[0]) return res.status(404).json({ error: 'Registro no encontrado' })

  const { rows } = await pool.query(
    `UPDATE adm_personal_salud
     SET nombre_completo    = COALESCE($1, nombre_completo),
         tipo_personal_id   = COALESCE($2, tipo_personal_id),
         cedula_profesional = COALESCE($3, cedula_profesional)
     WHERE id = $4
     RETURNING id, nombre_completo, tipo_personal_id, cedula_profesional`,
    [nombre_completo, tipo_personal_id, cedula_profesional, id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'adm_personal_salud',
    registro_id: id,
    datos_anteriores: anterior.rows[0],
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ data: rows[0], mensaje: 'Personal actualizado exitosamente' })
}

/**
 * DELETE /api/admin/personal/:id
 */
export async function eliminar(req, res) {
  const { id } = req.params

  const anterior = await pool.query('SELECT * FROM adm_personal_salud WHERE id = $1', [id])
  if (!anterior.rows[0]) return res.status(404).json({ error: 'Registro no encontrado' })

  await pool.query('DELETE FROM adm_personal_salud WHERE id = $1', [id])

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'DELETE',
    tabla_afectada: 'adm_personal_salud',
    registro_id: id,
    datos_anteriores: anterior.rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ mensaje: 'Registro eliminado exitosamente' })
}

// ============================================================================
// ASIGNACIONES — adm_usuario_unidad_rol
// Rutas: /api/admin/usuarios/:id/asignaciones
// ============================================================================

/**
 * GET /api/admin/usuarios/:id/asignaciones
 * Lista todas las asignaciones de un usuario (activas + historial).
 * ?activo=true|false  para filtrar
 */
export async function listarAsignaciones(req, res) {
  const usuario_id = req.params.id
  const soloActivas = req.query.activo === 'true'
    ? true
    : req.query.activo === 'false'
      ? false
      : null  // null = todas

  const { rows } = await pool.query(
    `SELECT
       a.id AS asignacion_id,
       a.usuario_id,
       a.unidad_medica_id,
       a.rol_id,
       a.activo,
       a.fecha_inicio,
       a.fecha_fin,
       a.motivo_cambio,
       a.created_at,
       r.clave  AS rol_clave,
       r.nombre AS rol_nombre,
       um.nombre AS unidad_nombre,
       um.clues
     FROM adm_usuario_unidad_rol a
     JOIN cat_roles r            ON a.rol_id = r.id
     JOIN adm_unidades_medicas um ON a.unidad_medica_id = um.id
     WHERE a.usuario_id = $1
       AND ($2::boolean IS NULL OR a.activo = $2)
     ORDER BY a.activo DESC, a.fecha_inicio DESC`,
    [usuario_id, soloActivas]
  )

  res.json({ data: rows })
}

/**
 * POST /api/admin/usuarios/:id/asignaciones
 * Crea una nueva asignación usuario → unidad → rol.
 * Body: { unidad_medica_id, rol_id, fecha_inicio?, motivo_cambio? }
 */
export async function crearAsignacion(req, res) {
  const usuario_id = req.params.id
  const { unidad_medica_id, rol_id, fecha_inicio, motivo_cambio } = req.body

  if (!unidad_medica_id || !rol_id) {
    return res.status(400).json({ error: 'unidad_medica_id y rol_id son requeridos' })
  }

  // Verificar que el usuario existe
  const uCheck = await pool.query('SELECT id FROM adm_usuarios WHERE id = $1', [usuario_id])
  if (!uCheck.rows[0]) return res.status(404).json({ error: 'Usuario no encontrado' })

  // Verificar que la unidad existe y está activa
  const umCheck = await pool.query(
    'SELECT id FROM adm_unidades_medicas WHERE id = $1 AND activo = TRUE',
    [unidad_medica_id]
  )
  if (!umCheck.rows[0]) return res.status(400).json({ error: 'Unidad médica no encontrada o inactiva' })

  // Verificar que no existe ya una asignación activa para (usuario, unidad, rol)
  const dup = await pool.query(
    `SELECT id FROM adm_usuario_unidad_rol
     WHERE usuario_id = $1 AND unidad_medica_id = $2 AND rol_id = $3 AND activo = TRUE`,
    [usuario_id, unidad_medica_id, rol_id]
  )
  if (dup.rows[0]) {
    return res.status(409).json({ error: 'Ya existe una asignación activa para este usuario, unidad y rol' })
  }

  const { rows } = await pool.query(
    `INSERT INTO adm_usuario_unidad_rol
       (usuario_id, unidad_medica_id, rol_id, fecha_inicio, motivo_cambio, created_by)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id AS asignacion_id, usuario_id, unidad_medica_id, rol_id, activo, fecha_inicio, motivo_cambio`,
    [
      usuario_id,
      unidad_medica_id,
      rol_id,
      fecha_inicio || new Date().toISOString().slice(0, 10),
      motivo_cambio || null,
      req.user.sub,
    ]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'CREATE',
    tabla_afectada: 'adm_usuario_unidad_rol',
    registro_id: rows[0].asignacion_id,
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.status(201).json({ data: rows[0], mensaje: 'Asignación creada exitosamente' })
}

/**
 * DELETE /api/admin/usuarios/:id/asignaciones/:asig_id
 * Revoca una asignación: cierre lógico con fecha_fin y activo = FALSE.
 * Body: { motivo_cambio? }
 *
 * Nunca se borran filas — el historial es inmutable (NOM-024).
 */
export async function revocarAsignacion(req, res) {
  const { id: usuario_id, asig_id } = req.params
  const { motivo_cambio } = req.body

  const anterior = await pool.query(
    `SELECT * FROM adm_usuario_unidad_rol WHERE id = $1 AND usuario_id = $2`,
    [asig_id, usuario_id]
  )
  if (!anterior.rows[0]) {
    return res.status(404).json({ error: 'Asignación no encontrada' })
  }
  if (!anterior.rows[0].activo) {
    return res.status(409).json({ error: 'La asignación ya está inactiva' })
  }

  const { rows } = await pool.query(
    `UPDATE adm_usuario_unidad_rol
     SET activo        = FALSE,
         fecha_fin     = CURRENT_DATE,
         motivo_cambio = COALESCE($1, motivo_cambio),
         updated_at    = CURRENT_TIMESTAMP
     WHERE id = $2
     RETURNING id AS asignacion_id, activo, fecha_fin, motivo_cambio`,
    [motivo_cambio || null, asig_id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'adm_usuario_unidad_rol',
    registro_id: asig_id,
    datos_anteriores: anterior.rows[0],
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ data: rows[0], mensaje: 'Asignación revocada exitosamente' })
}
