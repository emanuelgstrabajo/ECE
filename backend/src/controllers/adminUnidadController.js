/**
 * Controlador ADMIN_UNIDAD — Fase 2
 *
 * Scope: todas las operaciones están restringidas a req.unidad_id
 * (inyectado por el middleware requireUnidad).
 *
 * Rutas base: /api/admin-unidad/...
 */

import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'
import bcrypt from 'bcrypt'

// ============================================================================
// DASHBOARD
// ============================================================================

/**
 * GET /api/admin-unidad/dashboard
 * Estadísticas de la unidad: personal activo, servicios, citas pendientes.
 */
export async function dashboard(req, res) {
  const unidad_id = req.unidad_id

  const [unidadRes, personalRes, rolesRes] = await Promise.all([
    pool.query(
      `SELECT id, nombre, clues, activo
       FROM adm_unidades_medicas WHERE id = $1`,
      [unidad_id]
    ),
    pool.query(
      `SELECT COUNT(*) AS total
       FROM adm_usuario_unidad_rol
       WHERE unidad_medica_id = $1 AND activo = TRUE`,
      [unidad_id]
    ),
    pool.query(
      `SELECT r.clave, r.nombre, COUNT(a.id) AS total
       FROM adm_usuario_unidad_rol a
       JOIN cat_roles r ON a.rol_id = r.id
       WHERE a.unidad_medica_id = $1 AND a.activo = TRUE
       GROUP BY r.clave, r.nombre
       ORDER BY r.nombre`,
      [unidad_id]
    ),
  ])

  if (!unidadRes.rows[0]) {
    return res.status(404).json({ error: 'Unidad médica no encontrada' })
  }

  res.json({
    data: {
      unidad: unidadRes.rows[0],
      personal_activo: parseInt(personalRes.rows[0].total),
      personal_por_rol: rolesRes.rows,
    },
  })
}

// ============================================================================
// PERSONAL DE LA UNIDAD
// ============================================================================

/**
 * GET /api/admin-unidad/personal
 * Lista el personal activo asignado a la unidad del admin.
 */
export async function listarPersonal(req, res) {
  const unidad_id = req.unidad_id
  const page   = Math.max(1, parseInt(req.query.page) || 1)
  const limit  = Math.min(100, parseInt(req.query.limit) || 20)
  const offset = (page - 1) * limit
  const search = req.query.search?.trim() || ''

  const { rows } = await pool.query(
    `SELECT
       p.id, p.nombre_completo, p.cedula_profesional,
       p.usuario_id, p.tipo_personal_id,
       u.email, u.curp, u.activo AS usuario_activo,
       tp.descripcion AS tipo_personal,
       a.id            AS asignacion_id,
       a.rol_id,
       r.clave         AS rol_clave,
       r.nombre        AS rol_nombre,
       a.fecha_inicio,
       COUNT(*) OVER() AS total
     FROM adm_usuario_unidad_rol a
     JOIN adm_usuarios u           ON a.usuario_id = u.id
     LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
     LEFT JOIN cat_tipos_personal tp ON p.tipo_personal_id = tp.id
     JOIN cat_roles r               ON a.rol_id = r.id
     WHERE a.unidad_medica_id = $1
       AND a.activo = TRUE
       AND ($2 = '' OR p.nombre_completo ILIKE $3 OR u.email ILIKE $3)
     ORDER BY p.nombre_completo NULLS LAST, u.email
     LIMIT $4 OFFSET $5`,
    [unidad_id, search, `%${search}%`, limit, offset]
  )

  const total = rows[0]?.total ? parseInt(rows[0].total) : 0
  res.json({
    data: rows,
    pagination: { total, page, limit, pages: Math.ceil(total / limit) },
  })
}

/**
 * GET /api/admin-unidad/personal/:asignacion_id
 * Detalle de una asignación específica (solo de su unidad).
 */
export async function obtenerPersonal(req, res) {
  const unidad_id = req.unidad_id
  const { asignacion_id } = req.params

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
       r.clave  AS rol_clave,
       r.nombre AS rol_nombre,
       u.email, u.curp, u.activo AS usuario_activo,
       p.id AS personal_id,
       p.nombre_completo,
       p.cedula_profesional,
       tp.descripcion AS tipo_personal
     FROM adm_usuario_unidad_rol a
     JOIN cat_roles r               ON a.rol_id = r.id
     JOIN adm_usuarios u            ON a.usuario_id = u.id
     LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
     LEFT JOIN cat_tipos_personal tp ON p.tipo_personal_id = tp.id
     WHERE a.id = $1 AND a.unidad_medica_id = $2`,
    [asignacion_id, unidad_id]
  )

  if (!rows[0]) return res.status(404).json({ error: 'Asignación no encontrada en esta unidad' })
  res.json({ data: rows[0] })
}

/**
 * POST /api/admin-unidad/personal
 * Crea usuario + perfil profesional + asignación en la unidad del admin.
 *
 * Body: {
 *   email, curp, password,
 *   rol_id,
 *   nombre_completo, tipo_personal_id, cedula_profesional?,
 *   fecha_inicio?, motivo_cambio?
 * }
 */
export async function crearPersonal(req, res) {
  const unidad_id = req.unidad_id
  const {
    email, curp, password,
    rol_id,
    nombre_completo, tipo_personal_id, cedula_profesional,
    fecha_inicio, motivo_cambio,
  } = req.body

  if (!email || !curp || !password || !rol_id || !nombre_completo || !tipo_personal_id) {
    return res.status(400).json({
      error: 'email, curp, password, rol_id, nombre_completo y tipo_personal_id son requeridos',
    })
  }

  // Verificar que el rol es operativo (no SUPERADMIN ni ADMIN_UNIDAD desde aquí)
  const rolCheck = await pool.query(
    `SELECT id, clave FROM cat_roles WHERE id = $1`,
    [rol_id]
  )
  if (!rolCheck.rows[0]) return res.status(400).json({ error: 'Rol no encontrado' })
  if (['SUPERADMIN', 'ADMIN_UNIDAD'].includes(rolCheck.rows[0].clave)) {
    return res.status(403).json({
      error: 'No puede asignar este rol. Solo roles operativos: MEDICO, ENFERMERA, RECEPCIONISTA, PACIENTE',
    })
  }

  // Verificar unicidad de email/curp
  const dup = await pool.query(
    `SELECT id FROM adm_usuarios WHERE LOWER(email) = LOWER($1) OR UPPER(curp) = UPPER($2) LIMIT 1`,
    [email, curp]
  )
  if (dup.rows[0]) return res.status(409).json({ error: 'Ya existe un usuario con ese email o CURP' })

  // Determinar rol_id de sistema para el usuario
  // (para roles operativos, rol_id en adm_usuarios se fija al rol dado)
  const passwordHash = await bcrypt.hash(password, 12)

  const client = await pool.connect()
  try {
    await client.query('BEGIN')

    // 1. Crear usuario
    const { rows: uRows } = await client.query(
      `INSERT INTO adm_usuarios (email, curp, password_hash, rol_id, activo)
       VALUES (LOWER($1), UPPER($2), $3, $4, TRUE)
       RETURNING id, email, curp`,
      [email, curp, passwordHash, rol_id]
    )
    const usuario = uRows[0]

    // 2. Crear perfil profesional
    const { rows: pRows } = await client.query(
      `INSERT INTO adm_personal_salud (usuario_id, nombre_completo, tipo_personal_id, cedula_profesional)
       VALUES ($1, $2, $3, $4)
       RETURNING id`,
      [usuario.id, nombre_completo, tipo_personal_id, cedula_profesional || null]
    )
    const personal = pRows[0]

    // 3. Crear asignación a la unidad
    const { rows: aRows } = await client.query(
      `INSERT INTO adm_usuario_unidad_rol
         (usuario_id, unidad_medica_id, rol_id, fecha_inicio, motivo_cambio, created_by)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id AS asignacion_id`,
      [
        usuario.id,
        unidad_id,
        rol_id,
        fecha_inicio || new Date().toISOString().slice(0, 10),
        motivo_cambio || 'Alta de personal — Fase 2',
        req.user.sub,
      ]
    )

    await client.query('COMMIT')

    await auditLog({
      usuario_id: req.user.sub,
      accion: 'CREATE',
      tabla_afectada: 'adm_usuario_unidad_rol',
      registro_id: aRows[0].asignacion_id,
      datos_nuevos: { usuario_id: usuario.id, personal_id: personal.id, unidad_id, rol_id },
      ip: getClientIp(req),
      user_agent: req.headers['user-agent'],
    })

    res.status(201).json({
      data: {
        usuario_id: usuario.id,
        personal_id: personal.id,
        asignacion_id: aRows[0].asignacion_id,
      },
      mensaje: 'Personal creado y asignado a la unidad exitosamente',
    })
  } catch (err) {
    await client.query('ROLLBACK')
    throw err
  } finally {
    client.release()
  }
}

/**
 * DELETE /api/admin-unidad/personal/:asignacion_id
 * Revoca la asignación del personal en su unidad (cierre lógico).
 * Body: { motivo_cambio }
 */
export async function revocarPersonal(req, res) {
  const unidad_id     = req.unidad_id
  const { asignacion_id } = req.params
  const { motivo_cambio } = req.body

  const anterior = await pool.query(
    `SELECT * FROM adm_usuario_unidad_rol
     WHERE id = $1 AND unidad_medica_id = $2`,
    [asignacion_id, unidad_id]
  )
  if (!anterior.rows[0]) {
    return res.status(404).json({ error: 'Asignación no encontrada en esta unidad' })
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
    [motivo_cambio || null, asignacion_id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'UPDATE',
    tabla_afectada: 'adm_usuario_unidad_rol',
    registro_id: asignacion_id,
    datos_anteriores: anterior.rows[0],
    datos_nuevos: rows[0],
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ data: rows[0], mensaje: 'Asignación revocada exitosamente' })
}

// ============================================================================
// SERVICIOS Y NORMATIVAS DE LA UNIDAD
// ============================================================================

/**
 * GET /api/admin-unidad/servicios
 * Lista los servicios de atención disponibles, marcando cuáles adoptó la unidad.
 */
export async function listarServicios(req, res) {
  const unidad_id = req.unidad_id

  const { rows } = await pool.query(
    `SELECT
       s.id,
       s.nombre,
       s.descripcion,
       EXISTS(
         SELECT 1 FROM cat_matriz_personal_servicio ms
         WHERE ms.servicio_id = s.id
       ) AS tiene_personal,
       TRUE AS disponible
     FROM cat_servicios_atencion s
     ORDER BY s.nombre`,
    []
  )

  res.json({ data: rows })
}

/**
 * GET /api/admin-unidad/normativas
 * Lista las normativas y qué opciones adoptó la unidad.
 */
export async function listarNormativas(req, res) {
  const unidad_id = req.unidad_id

  const { rows } = await pool.query(
    `SELECT
       n.id,
       n.clave,
       n.nombre,
       n.version,
       n.activa,
       COUNT(ro.id) AS opciones_adoptadas
     FROM sys_normatividad_giis n
     LEFT JOIN rel_normatividad_opciones ro
       ON ro.normatividad_id = n.id
     WHERE n.activa = TRUE
     GROUP BY n.id, n.clave, n.nombre, n.version, n.activa
     ORDER BY n.clave`,
    []
  )

  res.json({ data: rows })
}

/**
 * GET /api/admin-unidad/bitacora
 * Bitácora filtrada a eventos de su unidad.
 */
export async function listarBitacora(req, res) {
  const unidad_id = req.unidad_id
  const page   = Math.max(1, parseInt(req.query.page) || 1)
  const limit  = Math.min(100, parseInt(req.query.limit) || 20)
  const offset = (page - 1) * limit

  const { rows } = await pool.query(
    `SELECT
       b.id, b.accion, b.tabla_afectada, b.registro_id,
       b.datos_anteriores, b.datos_nuevos,
       b.ip_origen, b.user_agent,
       b.created_at,
       u.email AS usuario_email,
       p.nombre_completo AS usuario_nombre
     FROM sys_bitacora_auditoria b
     LEFT JOIN adm_usuarios u ON b.usuario_id = u.id
     LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
     WHERE b.usuario_id IN (
       SELECT usuario_id FROM adm_usuario_unidad_rol
       WHERE unidad_medica_id = $1
     )
     ORDER BY b.created_at DESC
     LIMIT $2 OFFSET $3`,
    [unidad_id, limit, offset]
  )

  const countRes = await pool.query(
    `SELECT COUNT(*) AS total FROM sys_bitacora_auditoria
     WHERE usuario_id IN (
       SELECT usuario_id FROM adm_usuario_unidad_rol
       WHERE unidad_medica_id = $1
     )`,
    [unidad_id]
  )

  const total = parseInt(countRes.rows[0].total)
  res.json({
    data: rows,
    pagination: { total, page, limit, pages: Math.ceil(total / limit) },
  })
}
