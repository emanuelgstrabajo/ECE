import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'

/**
 * GET /api/admin/personal
 */
export async function listar(req, res) {
  const page   = Math.max(1, parseInt(req.query.page) || 1)
  const limit  = Math.min(100, parseInt(req.query.limit) || 20)
  const offset = (page - 1) * limit
  const search = req.query.search?.trim() || ''
  const unidad_id = req.query.unidad_id || null

  const { rows } = await pool.query(
    `SELECT
       p.id, p.nombre_completo, p.cedula_profesional,
       p.usuario_id, p.unidad_medica_id, p.tipo_personal_id,
       u.email, u.curp, u.activo AS usuario_activo,
       r.clave AS rol_clave, r.nombre AS rol_nombre,
       um.nombre AS unidad_nombre, um.clues,
       tp.descripcion AS tipo_personal,
       COUNT(*) OVER() AS total
     FROM adm_personal_salud p
     LEFT JOIN adm_usuarios u ON p.usuario_id = u.id
     LEFT JOIN cat_roles r ON u.rol_id = r.id
     LEFT JOIN adm_unidades_medicas um ON p.unidad_medica_id = um.id
     LEFT JOIN cat_tipos_personal tp ON p.tipo_personal_id = tp.id
     WHERE ($1 = '' OR p.nombre_completo ILIKE $2 OR u.email ILIKE $2)
       AND ($3::int IS NULL OR p.unidad_medica_id = $3)
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
       p.*,
       u.email, u.curp, u.activo AS usuario_activo, u.rol_id,
       r.clave AS rol_clave,
       um.nombre AS unidad_nombre, um.clues,
       tp.descripcion AS tipo_personal
     FROM adm_personal_salud p
     LEFT JOIN adm_usuarios u ON p.usuario_id = u.id
     LEFT JOIN cat_roles r ON u.rol_id = r.id
     LEFT JOIN adm_unidades_medicas um ON p.unidad_medica_id = um.id
     LEFT JOIN cat_tipos_personal tp ON p.tipo_personal_id = tp.id
     WHERE p.id = $1`,
    [req.params.id]
  )
  if (!rows[0]) return res.status(404).json({ error: 'Registro de personal no encontrado' })
  res.json({ data: rows[0] })
}

/**
 * POST /api/admin/personal
 */
export async function crear(req, res) {
  const { usuario_id, nombre_completo, unidad_medica_id, tipo_personal_id, cedula_profesional } = req.body

  if (!nombre_completo || !tipo_personal_id) {
    return res.status(400).json({ error: 'Nombre completo y tipo de personal son requeridos' })
  }

  // Validar que el usuario existe (si se provee)
  if (usuario_id) {
    const u = await pool.query('SELECT id FROM adm_usuarios WHERE id = $1', [usuario_id])
    if (!u.rows[0]) return res.status(400).json({ error: 'Usuario no encontrado' })
    // Verificar que no tenga ya un registro de personal
    const dup = await pool.query('SELECT id FROM adm_personal_salud WHERE usuario_id = $1', [usuario_id])
    if (dup.rows[0]) return res.status(409).json({ error: 'Este usuario ya tiene un registro de personal de salud' })
  }

  const { rows } = await pool.query(
    `INSERT INTO adm_personal_salud
       (usuario_id, nombre_completo, unidad_medica_id, tipo_personal_id, cedula_profesional)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, nombre_completo, usuario_id`,
    [usuario_id || null, nombre_completo, unidad_medica_id || null,
     tipo_personal_id, cedula_profesional || null]
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
  const { nombre_completo, unidad_medica_id, tipo_personal_id, cedula_profesional } = req.body

  const anterior = await pool.query('SELECT * FROM adm_personal_salud WHERE id = $1', [id])
  if (!anterior.rows[0]) return res.status(404).json({ error: 'Registro no encontrado' })

  const { rows } = await pool.query(
    `UPDATE adm_personal_salud
     SET nombre_completo   = COALESCE($1, nombre_completo),
         unidad_medica_id  = COALESCE($2, unidad_medica_id),
         tipo_personal_id  = COALESCE($3, tipo_personal_id),
         cedula_profesional = COALESCE($4, cedula_profesional)
     WHERE id = $5
     RETURNING id, nombre_completo, unidad_medica_id, tipo_personal_id`,
    [nombre_completo, unidad_medica_id, tipo_personal_id, cedula_profesional, id]
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
