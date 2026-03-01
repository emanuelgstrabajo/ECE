import pool from '../db/index.js'

/**
 * GET /api/admin/dashboard
 * Métricas completas para el panel del SUPERADMIN (SA-P8: A–K)
 */
export async function obtenerMetricas(req, res) {
  const client = await pool.connect()
  try {
    const [
      unidadesRes,
      usuariosPorRolRes,
      citasHoyRes,
      citasPorUnidadRes,
      pacientesRes,
      usuariosBloqueadosRes,
      alertasLoginRes,
      bitacoraRes,
      comparativaMensualRes,
      giisAdopcionRes,
    ] = await Promise.all([
      // A: Total unidades activas / inactivas
      client.query(`
        SELECT
          COUNT(*) FILTER (WHERE activo = true)  AS activas,
          COUNT(*) FILTER (WHERE activo = false) AS inactivas,
          COUNT(*) AS total
        FROM adm_unidades_medicas
      `),

      // B: Total de usuarios por rol
      client.query(`
        SELECT r.clave, r.nombre, COUNT(u.id) AS total
        FROM cat_roles r
        LEFT JOIN adm_usuarios u ON u.rol_id = r.id AND u.activo = true
        GROUP BY r.id, r.clave, r.nombre
        ORDER BY r.nombre
      `),

      // C: Citas del día en todo el sistema
      client.query(`
        SELECT COUNT(*) AS total
        FROM clin_citas
        WHERE DATE(fecha_cita) = CURRENT_DATE
      `).catch(() => ({ rows: [{ total: 0 }] })),

      // D: Citas del día por unidad (tabla comparativa)
      client.query(`
        SELECT um.nombre, um.clues, COUNT(cc.id) AS citas
        FROM adm_unidades_medicas um
        LEFT JOIN clin_citas cc
          ON cc.unidad_medica_id = um.id AND DATE(cc.fecha_cita) = CURRENT_DATE
        WHERE um.activo = true
        GROUP BY um.id, um.nombre, um.clues
        ORDER BY citas DESC
        LIMIT 15
      `).catch(() => ({ rows: [] })),

      // E: Pacientes registrados total global
      client.query(`
        SELECT COUNT(*) AS total FROM clin_pacientes
      `).catch(() => ({ rows: [{ total: 0 }] })),

      // F: Alertas críticas — usuarios bloqueados actualmente
      client.query(`
        SELECT
          u.email,
          p.nombre_completo,
          u.bloqueado_hasta,
          um.nombre AS ultima_unidad
        FROM adm_usuarios u
        LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
        LEFT JOIN adm_usuario_unidad_rol uur ON uur.usuario_id = u.id AND uur.activo = true
        LEFT JOIN adm_unidades_medicas um ON um.id = uur.unidad_medica_id
        WHERE u.bloqueado_hasta > NOW()
        ORDER BY u.bloqueado_hasta DESC
        LIMIT 20
      `).catch(() => ({ rows: [] })),

      // G: Alertas de seguridad — intentos de login fallidos recientes (≥ 2)
      client.query(`
        SELECT
          u.email,
          p.nombre_completo,
          u.intentos_fallidos,
          u.ultimo_acceso
        FROM adm_usuarios u
        LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
        WHERE u.intentos_fallidos >= 2
        ORDER BY u.intentos_fallidos DESC
        LIMIT 10
      `).catch(() => ({ rows: [] })),

      // I: Bitácora global — últimas 20 acciones
      client.query(`
        SELECT
          b.id, b.accion, b.tabla_afectada, b.registro_id,
          b.fecha_accion, b.ip, b.user_agent,
          u.email AS usuario_email,
          p.nombre_completo AS usuario_nombre
        FROM sys_bitacora_auditoria b
        LEFT JOIN adm_usuarios u ON u.id = b.usuario_id
        LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
        ORDER BY b.fecha_accion DESC
        LIMIT 20
      `).catch(() => ({ rows: [] })),

      // J: Comparativa mensual por unidad (citas/atenciones)
      client.query(`
        SELECT
          um.nombre, um.clues,
          COUNT(cc.id) AS citas_mes
        FROM adm_unidades_medicas um
        LEFT JOIN clin_citas cc
          ON cc.unidad_medica_id = um.id
          AND DATE_TRUNC('month', cc.fecha_cita) = DATE_TRUNC('month', CURRENT_DATE)
        WHERE um.activo = true
        GROUP BY um.id, um.nombre, um.clues
        ORDER BY citas_mes DESC
      `).catch(() => ({ rows: [] })),

      // K: Estado de normativas GIIS — cuántas unidades adoptaron cada una
      client.query(`
        SELECT
          n.id, n.clave, n.nombre_documento, n.version, n.estatus,
          COUNT(DISTINCT a.unidad_medica_id) AS unidades_adoptaron,
          (SELECT COUNT(*) FROM adm_unidades_medicas WHERE activo = true) AS total_unidades
        FROM sys_normatividad_giis n
        LEFT JOIN sys_adopcion_catalogos a ON a.catalogo_id = n.id
        GROUP BY n.id, n.clave, n.nombre_documento, n.version, n.estatus
        ORDER BY n.nombre_documento
      `).catch(() => ({ rows: [] })),
    ])

    res.json({
      data: {
        unidades: {
          activas:   parseInt(unidadesRes.rows[0]?.activas  ?? 0),
          inactivas: parseInt(unidadesRes.rows[0]?.inactivas ?? 0),
          total:     parseInt(unidadesRes.rows[0]?.total    ?? 0),
        },
        usuarios_por_rol:    usuariosPorRolRes.rows,
        citas_hoy_total:     parseInt(citasHoyRes.rows[0]?.total ?? 0),
        citas_hoy_por_unidad: citasPorUnidadRes.rows,
        pacientes_total:     parseInt(pacientesRes.rows[0]?.total ?? 0),
        usuarios_bloqueados: usuariosBloqueadosRes.rows,
        alertas_login:       alertasLoginRes.rows,
        bitacora_reciente:   bitacoraRes.rows,
        comparativa_mensual: comparativaMensualRes.rows,
        giis_adopcion:       giisAdopcionRes.rows,
      },
    })
  } finally {
    client.release()
  }
}
