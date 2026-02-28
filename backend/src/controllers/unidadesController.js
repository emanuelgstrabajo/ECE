import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'

/**
 * GET /api/admin/unidades
 * Query params: page, limit, search, activo
 */
export async function listar(req, res) {
  const page  = Math.max(1, parseInt(req.query.page)  || 1)
  const limit = Math.min(100, parseInt(req.query.limit) || 20)
  const offset = (page - 1) * limit
  const search = req.query.search?.trim() || ''
  const activo = req.query.activo === 'false' ? false : true

  const { rows } = await pool.query(
    `SELECT
       u.id, u.clues, u.nombre, u.tipo_unidad, u.estatus_operacion,
       u.tiene_espirometro, u.es_servicio_amigable, u.activo,
       ST_X(u.geom) AS lng, ST_Y(u.geom) AS lat,
       u.asentamiento_id,
       a.nombre_colonia, a.codigo_postal,
       m.nombre AS municipio, e.nombre AS entidad,
       u.created_at, u.updated_at,
       COUNT(*) OVER() AS total
     FROM adm_unidades_medicas u
     LEFT JOIN cat_asentamientos_cp a ON u.asentamiento_id = a.id
     LEFT JOIN cat_municipios m ON a.municipio_id = m.id
     LEFT JOIN cat_entidades e ON m.entidad_id = e.id
     WHERE u.activo = $1
       AND ($2 = '' OR u.nombre ILIKE $3 OR u.clues ILIKE $3)
     ORDER BY u.nombre
     LIMIT $4 OFFSET $5`,
    [activo, search, `%${search}%`, limit, offset]
  )

  const total = rows[0]?.total ? parseInt(rows[0].total) : 0
  res.json({
    data: rows,
    pagination: { total, page, limit, pages: Math.ceil(total / limit) },
  })
}

/**
 * GET /api/admin/unidades/mapa
 * Todas las unidades activas con coordenadas (para mapa Leaflet)
 */
export async function listarMapa(req, res) {
  const { rows } = await pool.query(
    `SELECT id, clues, nombre, tipo_unidad, estatus_operacion,
            ST_X(geom) AS lng, ST_Y(geom) AS lat
     FROM adm_unidades_medicas
     WHERE activo = true AND geom IS NOT NULL`
  )
  res.json({ data: rows })
}

/**
 * GET /api/admin/unidades/:id
 */
export async function obtener(req, res) {
  const { rows } = await pool.query(
    `SELECT
       u.*,
       ST_X(u.geom) AS lng, ST_Y(u.geom) AS lat,
       a.nombre_colonia, a.codigo_postal,
       m.nombre AS municipio, m.id AS municipio_id,
       e.nombre AS entidad, e.id AS entidad_id
     FROM adm_unidades_medicas u
     LEFT JOIN cat_asentamientos_cp a ON u.asentamiento_id = a.id
     LEFT JOIN cat_municipios m ON a.municipio_id = m.id
     LEFT JOIN cat_entidades e ON m.entidad_id = e.id
     WHERE u.id = $1`,
    [req.params.id]
  )
  if (!rows[0]) return res.status(404).json({ error: 'Unidad no encontrada' })
  res.json({ data: rows[0] })
}

/**
 * POST /api/admin/unidades
 */
export async function crear(req, res) {
  const {
    clues, nombre, tipo_unidad, estatus_operacion,
    tiene_espirometro, es_servicio_amigable,
    asentamiento_id, lat, lng,
  } = req.body

  if (!clues || !nombre) {
    return res.status(400).json({ error: 'CLUES y nombre son requeridos' })
  }

  // CLUES única
  const existe = await pool.query('SELECT id FROM adm_unidades_medicas WHERE clues = $1', [clues])
  if (existe.rows.length) {
    return res.status(409).json({ error: `Ya existe una unidad con CLUES ${clues}` })
  }

  const geomExpr = lat != null && lng != null
    ? `ST_SetSRID(ST_MakePoint(${parseFloat(lng)}, ${parseFloat(lat)}), 4326)`
    : 'NULL'

  const { rows } = await pool.query(
    `INSERT INTO adm_unidades_medicas
       (clues, nombre, tipo_unidad, estatus_operacion, tiene_espirometro,
        es_servicio_amigable, asentamiento_id, geom)
     VALUES ($1, $2, $3, $4, $5, $6, $7, ${geomExpr})
     RETURNING id, clues, nombre`,
    [clues, nombre, tipo_unidad || null, estatus_operacion || null,
     tiene_espirometro ?? false, es_servicio_amigable ?? false,
     asentamiento_id || null]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'CREATE',
    tabla_afectada: 'adm_unidades_medicas',
    registro_id: rows[0].id,
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.status(201).json({ data: rows[0], mensaje: 'Unidad creada exitosamente' })
}

/**
 * PUT /api/admin/unidades/:id
 */
export async function actualizar(req, res) {
  const { id } = req.params
  const {
    nombre, tipo_unidad, estatus_operacion,
    tiene_espirometro, es_servicio_amigable,
    asentamiento_id, lat, lng, activo,
  } = req.body

  const anterior = await pool.query('SELECT * FROM adm_unidades_medicas WHERE id = $1', [id])
  if (!anterior.rows[0]) return res.status(404).json({ error: 'Unidad no encontrada' })

  const geomClause = lat != null && lng != null
    ? `, geom = ST_SetSRID(ST_MakePoint(${parseFloat(lng)}, ${parseFloat(lat)}), 4326)`
    : ''

  const { rows } = await pool.query(
    `UPDATE adm_unidades_medicas
     SET nombre = COALESCE($1, nombre),
         tipo_unidad = COALESCE($2, tipo_unidad),
         estatus_operacion = COALESCE($3, estatus_operacion),
         tiene_espirometro = COALESCE($4, tiene_espirometro),
         es_servicio_amigable = COALESCE($5, es_servicio_amigable),
         asentamiento_id = COALESCE($6, asentamiento_id),
         activo = COALESCE($7, activo),
         updated_at = NOW()
         ${geomClause}
     WHERE id = $8
     RETURNING id, clues, nombre, activo`,
    [nombre, tipo_unidad, estatus_operacion, tiene_espirometro,
     es_servicio_amigable, asentamiento_id, activo, id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'adm_unidades_medicas',
    registro_id: id,
    datos_anteriores: anterior.rows[0],
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ data: rows[0], mensaje: 'Unidad actualizada exitosamente' })
}

/**
 * DELETE /api/admin/unidades/:id  — soft delete
 */
export async function desactivar(req, res) {
  const { id } = req.params

  const anterior = await pool.query('SELECT id, activo FROM adm_unidades_medicas WHERE id = $1', [id])
  if (!anterior.rows[0]) return res.status(404).json({ error: 'Unidad no encontrada' })

  await pool.query('UPDATE adm_unidades_medicas SET activo = false, updated_at = NOW() WHERE id = $1', [id])

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'DELETE',
    tabla_afectada: 'adm_unidades_medicas',
    registro_id: id,
    datos_anteriores: anterior.rows[0],
    datos_nuevos: { activo: false },
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ mensaje: 'Unidad desactivada exitosamente' })
}
