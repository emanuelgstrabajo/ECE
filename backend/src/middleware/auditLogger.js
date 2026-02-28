import pool from '../db/index.js'

/**
 * Registra una acción en la bitácora de auditoría NOM-024.
 * La bitácora es INMUTABLE — nunca se pueden borrar o modificar registros.
 *
 * @param {object} params
 * @param {string|null} params.usuario_id - UUID del usuario que realizó la acción
 * @param {string} params.accion - 'LOGIN'|'LOGOUT'|'CREATE'|'UPDATE'|'DELETE'|'VIEW'
 * @param {string} params.tabla_afectada - Nombre de la tabla afectada
 * @param {string} params.registro_id - ID del registro afectado
 * @param {object|null} params.datos_anteriores - Estado previo del registro
 * @param {object|null} params.datos_nuevos - Estado nuevo del registro
 * @param {string|null} params.ip - Dirección IP del cliente
 * @param {string|null} params.user_agent - User-Agent del cliente
 * @param {import('pg').PoolClient|null} params.client - Cliente de BD (opcional, usa pool si null)
 */
export async function auditLog({
  usuario_id = null,
  accion,
  tabla_afectada,
  registro_id,
  datos_anteriores = null,
  datos_nuevos = null,
  ip = null,
  user_agent = null,
  client = null,
}) {
  const query = `
    INSERT INTO sys_bitacora_auditoria
      (usuario_id, accion, tabla_afectada, registro_id, datos_anteriores, datos_nuevos, direccion_ip, user_agent)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
  `
  const values = [
    usuario_id,
    accion,
    tabla_afectada,
    String(registro_id),
    datos_anteriores ? JSON.stringify(datos_anteriores) : null,
    datos_nuevos ? JSON.stringify(datos_nuevos) : null,
    ip,
    user_agent,
  ]

  try {
    if (client) {
      await client.query(query, values)
    } else {
      await pool.query(query, values)
    }
  } catch (err) {
    // La bitácora nunca debe interrumpir el flujo principal
    console.error('[AUDIT] Error al registrar en bitácora:', err.message)
  }
}

/**
 * Extrae la IP real del cliente considerando proxies.
 */
export function getClientIp(req) {
  return (
    req.headers['x-forwarded-for']?.split(',')[0]?.trim() ||
    req.socket?.remoteAddress ||
    null
  )
}
