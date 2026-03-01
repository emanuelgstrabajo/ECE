import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'

/**
 * GET /api/admin/giis
 * Lista normativas GIIS con conteo de adopción por unidad
 */
export async function listar(req, res) {
  const { rows } = await pool.query(`
    SELECT
      n.id, n.clave, n.nombre_documento, n.version,
      n.fecha_publicacion, n.url_pdf, n.estatus, n.fecha_registro,
      COUNT(DISTINCT a.unidad_medica_id) AS unidades_adoptaron,
      (SELECT COUNT(*) FROM adm_unidades_medicas WHERE activo = true) AS total_unidades_activas
    FROM sys_normatividad_giis n
    LEFT JOIN sys_adopcion_catalogos a ON a.catalogo_id = n.id
    GROUP BY n.id
    ORDER BY n.nombre_documento
  `)
  res.json({ data: rows })
}

/**
 * GET /api/admin/giis/:id
 */
export async function obtener(req, res) {
  const { rows } = await pool.query(
    `SELECT
       n.*,
       COUNT(DISTINCT a.unidad_medica_id) AS unidades_adoptaron
     FROM sys_normatividad_giis n
     LEFT JOIN sys_adopcion_catalogos a ON a.catalogo_id = n.id
     WHERE n.id = $1
     GROUP BY n.id`,
    [req.params.id]
  )
  if (!rows[0]) return res.status(404).json({ error: 'Normativa no encontrada' })
  res.json({ data: rows[0] })
}

/**
 * POST /api/admin/giis
 * Crear nueva normativa GIIS manualmente
 */
export async function crear(req, res) {
  const { clave, nombre_documento, version, fecha_publicacion, url_pdf, estatus } = req.body

  if (!clave || !nombre_documento) {
    return res.status(400).json({ error: 'Clave y nombre_documento son requeridos' })
  }

  const existe = await pool.query(
    'SELECT id FROM sys_normatividad_giis WHERE clave = $1',
    [clave.toUpperCase()]
  )
  if (existe.rows.length) {
    return res.status(409).json({ error: `Ya existe una normativa con clave "${clave}"` })
  }

  const { rows } = await pool.query(
    `INSERT INTO sys_normatividad_giis
       (clave, nombre_documento, version, fecha_publicacion, url_pdf, estatus)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [
      clave.toUpperCase(),
      nombre_documento,
      version || null,
      fecha_publicacion || null,
      url_pdf || null,
      estatus || 'ACTIVO',
    ]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'CREATE',
    tabla_afectada: 'sys_normatividad_giis',
    registro_id: rows[0].id,
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.status(201).json({ data: rows[0], mensaje: 'Normativa GIIS creada exitosamente' })
}

/**
 * PUT /api/admin/giis/:id
 * Actualizar normativa GIIS
 */
export async function actualizar(req, res) {
  const { id } = req.params
  const { nombre_documento, version, fecha_publicacion, url_pdf, estatus } = req.body

  const anterior = await pool.query('SELECT * FROM sys_normatividad_giis WHERE id = $1', [id])
  if (!anterior.rows[0]) return res.status(404).json({ error: 'Normativa no encontrada' })

  const { rows } = await pool.query(
    `UPDATE sys_normatividad_giis
     SET nombre_documento  = COALESCE($1, nombre_documento),
         version           = COALESCE($2, version),
         fecha_publicacion = COALESCE($3, fecha_publicacion),
         url_pdf           = COALESCE($4, url_pdf),
         estatus           = COALESCE($5, estatus)
     WHERE id = $6
     RETURNING *`,
    [nombre_documento, version, fecha_publicacion, url_pdf, estatus, id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'sys_normatividad_giis',
    registro_id: id,
    datos_anteriores: anterior.rows[0],
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ data: rows[0], mensaje: 'Normativa GIIS actualizada exitosamente' })
}

/**
 * PATCH /api/admin/giis/:id/estatus
 * Cambiar estatus de una normativa (ACTIVO / INACTIVO)
 */
export async function cambiarEstatus(req, res) {
  const { id } = req.params
  const { estatus } = req.body

  if (!['ACTIVO', 'INACTIVO'].includes(estatus)) {
    return res.status(400).json({ error: 'Estatus debe ser ACTIVO o INACTIVO' })
  }

  const anterior = await pool.query('SELECT * FROM sys_normatividad_giis WHERE id = $1', [id])
  if (!anterior.rows[0]) return res.status(404).json({ error: 'Normativa no encontrada' })

  const { rows } = await pool.query(
    'UPDATE sys_normatividad_giis SET estatus = $1 WHERE id = $2 RETURNING *',
    [estatus, id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'sys_normatividad_giis',
    registro_id: id,
    datos_anteriores: { estatus: anterior.rows[0].estatus },
    datos_nuevos: { estatus },
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ data: rows[0], mensaje: `Normativa ${estatus === 'ACTIVO' ? 'activada' : 'desactivada'} exitosamente` })
}

/**
 * GET /api/admin/giis/:id/campos
 * Campos dinámicos de una normativa GIIS
 */
export async function listarCampos(req, res) {
  const { rows } = await pool.query(
    `SELECT * FROM sys_giis_campos WHERE normativa_id = $1 ORDER BY orden, id`,
    [req.params.id]
  )
  res.json({ data: rows })
}
