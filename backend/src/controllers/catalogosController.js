import pool from '../db/index.js'

/**
 * GET /api/catalogos/roles
 */
export async function roles(req, res) {
  const { rows } = await pool.query(
    'SELECT id, clave, nombre, descripcion FROM cat_roles WHERE activo = true ORDER BY id'
  )
  res.json({ data: rows })
}

/**
 * GET /api/catalogos/tipos-personal
 */
export async function tiposPersonal(req, res) {
  const { rows } = await pool.query(
    'SELECT id, clave, descripcion FROM cat_tipos_personal ORDER BY id'
  )
  res.json({ data: rows })
}

/**
 * GET /api/catalogos/entidades
 */
export async function entidades(req, res) {
  const { rows } = await pool.query(
    'SELECT id, clave, nombre, abreviatura FROM cat_entidades ORDER BY nombre'
  )
  res.json({ data: rows })
}

/**
 * GET /api/catalogos/municipios?entidad_id=
 */
export async function municipios(req, res) {
  const { entidad_id } = req.query
  if (!entidad_id) return res.status(400).json({ error: 'entidad_id es requerido' })

  const { rows } = await pool.query(
    'SELECT id, clave, nombre FROM cat_municipios WHERE entidad_id = $1 ORDER BY nombre',
    [entidad_id]
  )
  res.json({ data: rows })
}

/**
 * GET /api/catalogos/asentamientos?municipio_id=&cp=
 */
export async function asentamientos(req, res) {
  const { municipio_id, cp } = req.query

  if (!municipio_id && !cp) {
    return res.status(400).json({ error: 'municipio_id o cp es requerido' })
  }

  const { rows } = await pool.query(
    `SELECT id, nombre_colonia, codigo_postal, tipo_asentamiento
     FROM cat_asentamientos_cp
     WHERE ($1::int IS NULL OR municipio_id = $1)
       AND ($2 = '' OR codigo_postal = $2)
     ORDER BY nombre_colonia
     LIMIT 200`,
    [municipio_id || null, cp || '']
  )
  res.json({ data: rows })
}

/**
 * GET /api/catalogos/cie10?q=&limit=
 */
export async function cie10(req, res) {
  const q     = req.query.q?.trim() || ''
  const limit = Math.min(50, parseInt(req.query.limit) || 20)

  if (q.length < 2) return res.json({ data: [] })

  const { rows } = await pool.query(
    `SELECT id, catalog_key, nombre
     FROM cat_cie10_diagnosticos
     WHERE activo = true
       AND (catalog_key ILIKE $1 OR nombre ILIKE $2)
     ORDER BY catalog_key
     LIMIT $3`,
    [`${q}%`, `%${q}%`, limit]
  )
  res.json({ data: rows })
}

/**
 * GET /api/catalogos/cie9?q=&limit=
 */
export async function cie9(req, res) {
  const q     = req.query.q?.trim() || ''
  const limit = Math.min(50, parseInt(req.query.limit) || 20)

  if (q.length < 2) return res.json({ data: [] })

  const { rows } = await pool.query(
    `SELECT id, catalog_key, nombre
     FROM cat_cie9_procedimientos
     WHERE activo = true
       AND (catalog_key ILIKE $1 OR nombre ILIKE $2)
     ORDER BY catalog_key
     LIMIT $3`,
    [`${q}%`, `%${q}%`, limit]
  )
  res.json({ data: rows })
}

/**
 * GET /api/catalogos/diccionario/:codigo
 * Opciones de un diccionario GUI por código
 */
export async function diccionario(req, res) {
  const { codigo } = req.params
  const parentId   = req.query.parent_id || null

  const dic = await pool.query(
    'SELECT id FROM gui_diccionarios WHERE codigo = $1',
    [codigo]
  )
  if (!dic.rows[0]) return res.status(404).json({ error: `Diccionario '${codigo}' no encontrado` })

  const { rows } = await pool.query(
    `SELECT id, clave, valor, parent_id, metadatos, orden
     FROM gui_diccionario_opciones
     WHERE diccionario_id = $1 AND activo = true
       AND ($2::int IS NULL OR parent_id = $2)
     ORDER BY orden, valor`,
    [dic.rows[0].id, parentId]
  )
  res.json({ data: rows })
}

/**
 * GET /api/catalogos/servicios
 */
export async function servicios(req, res) {
  const { rows } = await pool.query(
    'SELECT id, clave, descripcion FROM cat_servicios_atencion ORDER BY clave'
  )
  res.json({ data: rows })
}
