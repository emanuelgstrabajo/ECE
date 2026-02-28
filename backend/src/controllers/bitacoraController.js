import pool from '../db/index.js'

/**
 * GET /api/admin/bitacora
 * Query params: page, limit, usuario_id, accion, tabla, desde, hasta
 */
export async function listar(req, res) {
  const page   = Math.max(1, parseInt(req.query.page) || 1)
  const limit  = Math.min(200, parseInt(req.query.limit) || 50)
  const offset = (page - 1) * limit

  const { usuario_id, accion, tabla, desde, hasta } = req.query

  const { rows } = await pool.query(
    `SELECT
       b.id, b.accion, b.tabla_afectada, b.registro_id,
       b.datos_anteriores, b.datos_nuevos,
       b.fecha_accion, b.direccion_ip, b.user_agent,
       u.email AS usuario_email, u.curp AS usuario_curp,
       COUNT(*) OVER() AS total
     FROM sys_bitacora_auditoria b
     LEFT JOIN adm_usuarios u ON b.usuario_id = u.id
     WHERE ($1::uuid IS NULL OR b.usuario_id = $1)
       AND ($2 = '' OR b.accion = $2)
       AND ($3 = '' OR b.tabla_afectada = $3)
       AND ($4::date IS NULL OR b.fecha_accion::date >= $4)
       AND ($5::date IS NULL OR b.fecha_accion::date <= $5)
     ORDER BY b.fecha_accion DESC
     LIMIT $6 OFFSET $7`,
    [
      usuario_id || null,
      accion || '',
      tabla || '',
      desde || null,
      hasta || null,
      limit,
      offset,
    ]
  )

  const total = rows[0]?.total ? parseInt(rows[0].total) : 0
  res.json({
    data: rows,
    pagination: { total, page, limit, pages: Math.ceil(total / limit) },
  })
}
