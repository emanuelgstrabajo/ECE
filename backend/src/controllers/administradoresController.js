import { randomBytes } from 'crypto'
import bcrypt from 'bcrypt'
import pool from '../db/index.js'
import { auditLog, getClientIp } from '../middleware/auditLogger.js'
import { sendEmail } from '../services/emailService.js'

const SALT_ROUNDS = 12

// ── GET /api/admin/unidades/:id/administradores ───────────────────────────────
/**
 * Lista todos los administradores activos (ADMIN_UNIDAD) de una unidad.
 */
export async function listar(req, res) {
  const { id } = req.params

  const { rows } = await pool.query(
    `SELECT
       a.id            AS asignacion_id,
       u.id            AS usuario_id,
       u.email,
       u.curp,
       u.activo        AS usuario_activo,
       p.primer_nombre,
       p.segundo_nombre,
       p.apellido_paterno,
       p.apellido_materno,
       p.nombre_completo,
       p.cedula_profesional,
       a.fecha_inicio,
       a.created_at
     FROM adm_usuario_unidad_rol a
     JOIN adm_usuarios u          ON a.usuario_id = u.id
     JOIN cat_roles cr            ON a.rol_id = cr.id AND cr.clave = 'ADMIN_UNIDAD'
     LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id
     WHERE a.unidad_medica_id = $1
       AND a.activo = TRUE
     ORDER BY COALESCE(p.apellido_paterno, u.email), p.primer_nombre`,
    [id]
  )

  res.json({ data: rows })
}

// ── POST /api/admin/unidades/:id/administradores ──────────────────────────────
/**
 * Crea un usuario nuevo o asigna uno existente como ADMIN_UNIDAD de la unidad.
 *
 * Body para usuario nuevo:
 *   { tipo: 'nuevo', primer_nombre, apellido_paterno, segundo_nombre?, apellido_materno?, curp, email, cedula_profesional? }
 *
 * Body para usuario existente:
 *   { tipo: 'existente', usuario_id }
 */
export async function crearOAsignar(req, res) {
  const { id: unidadId } = req.params
  const { tipo } = req.body

  if (!tipo || !['nuevo', 'existente'].includes(tipo)) {
    return res.status(400).json({ error: 'tipo debe ser "nuevo" o "existente"' })
  }

  // Verificar que la unidad existe y está habilitada
  const unidadRes = await pool.query(
    'SELECT id, nombre, clues FROM adm_unidades_medicas WHERE id = $1 AND activo = TRUE',
    [unidadId]
  )
  if (!unidadRes.rows[0]) {
    return res.status(404).json({ error: 'Unidad no encontrada o no está habilitada' })
  }
  const unidad = unidadRes.rows[0]

  // Obtener id del rol ADMIN_UNIDAD
  const rolRes = await pool.query("SELECT id FROM cat_roles WHERE clave = 'ADMIN_UNIDAD'")
  if (!rolRes.rows[0]) {
    return res.status(500).json({ error: 'Rol ADMIN_UNIDAD no configurado en cat_roles' })
  }
  const rolId = rolRes.rows[0].id

  const client = await pool.connect()
  let passwordPlano = null
  let usuario = null

  try {
    await client.query('BEGIN')

    // ── Caso A: crear usuario nuevo ──────────────────────────────────────────
    if (tipo === 'nuevo') {
      const {
        primer_nombre, apellido_paterno,
        segundo_nombre, apellido_materno,
        curp, email, cedula_profesional,
      } = req.body

      if (!primer_nombre || !apellido_paterno || !curp || !email) {
        await client.query('ROLLBACK')
        return res.status(400).json({ error: 'primer_nombre, apellido_paterno, curp y email son requeridos' })
      }

      // Verificar duplicados por email o CURP
      const dup = await client.query(
        'SELECT id FROM adm_usuarios WHERE LOWER(email) = LOWER($1) OR UPPER(curp) = UPPER($2)',
        [email, curp]
      )
      if (dup.rows.length) {
        await client.query('ROLLBACK')
        return res.status(409).json({ error: 'Ya existe un usuario con ese email o CURP' })
      }

      passwordPlano = generarPassword()
      const passwordHash = await bcrypt.hash(passwordPlano, SALT_ROUNDS)

      const { rows: uRows } = await client.query(
        `INSERT INTO adm_usuarios (curp, email, password_hash, rol_id)
         VALUES ($1, $2, $3, $4)
         RETURNING id, curp, email`,
        [curp.toUpperCase(), email.toLowerCase(), passwordHash, rolId]
      )
      usuario = uRows[0]

      await client.query(
        `INSERT INTO adm_personal_salud
           (usuario_id, primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, cedula_profesional)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          usuario.id,
          primer_nombre.trim(), segundo_nombre?.trim() || null,
          apellido_paterno.trim(), apellido_materno?.trim() || null,
          cedula_profesional || null,
        ]
      )

    // ── Caso B: asignar usuario existente ────────────────────────────────────
    } else {
      const { usuario_id } = req.body
      if (!usuario_id) {
        await client.query('ROLLBACK')
        return res.status(400).json({ error: 'usuario_id es requerido' })
      }

      const { rows: uRows } = await client.query(
        `SELECT u.id, u.email, u.curp, r.clave AS rol_clave
         FROM adm_usuarios u
         LEFT JOIN cat_roles r ON u.rol_id = r.id
         WHERE u.id = $1 AND u.activo = TRUE`,
        [usuario_id]
      )
      if (!uRows[0]) {
        await client.query('ROLLBACK')
        return res.status(404).json({ error: 'Usuario no encontrado o está inactivo' })
      }
      usuario = uRows[0]

      if (usuario.rol_clave === 'SUPERADMIN') {
        await client.query('ROLLBACK')
        return res.status(400).json({ error: 'Un SUPERADMIN no puede ser asignado como ADMIN_UNIDAD' })
      }
    }

    // Verificar que no exista ya la asignación activa en esta unidad
    const asigExiste = await client.query(
      `SELECT id FROM adm_usuario_unidad_rol
       WHERE usuario_id = $1 AND unidad_medica_id = $2 AND rol_id = $3 AND activo = TRUE`,
      [usuario.id, unidadId, rolId]
    )
    if (asigExiste.rows.length) {
      await client.query('ROLLBACK')
      return res.status(409).json({ error: 'Este usuario ya es administrador de esta unidad' })
    }

    // Crear la asignación en adm_usuario_unidad_rol
    const { rows: asigRows } = await client.query(
      `INSERT INTO adm_usuario_unidad_rol
         (usuario_id, unidad_medica_id, rol_id, activo, fecha_inicio, motivo_cambio, created_by)
       VALUES ($1, $2, $3, TRUE, CURRENT_DATE, 'Asignación como administrador de unidad', $4)
       RETURNING id`,
      [usuario.id, unidadId, rolId, req.user.sub]
    )
    const asignacionId = asigRows[0].id

    await auditLog({
      usuario_id: req.user.sub,
      accion: 'CREATE',
      tabla_afectada: 'adm_usuario_unidad_rol',
      registro_id: asignacionId,
      datos_nuevos: {
        usuario_id: usuario.id,
        unidad_medica_id: unidadId,
        rol: 'ADMIN_UNIDAD',
        tipo,
      },
      ip: getClientIp(req),
      user_agent: req.headers['user-agent'],
      client,
    })

    await client.query('COMMIT')

    // Enviar correo (fuera de la transacción, no bloquea si falla)
    const emailPayload = tipo === 'nuevo'
      ? emailNuevoAdmin({ email: usuario.email, password: passwordPlano, unidad })
      : emailAsignacionAdmin({ email: usuario.email, unidad })

    const emailResult = await sendEmail(emailPayload).catch(err => {
      console.error('[EMAIL] Error al enviar:', err.message)
      return { enviado: false, error: err.message }
    })

    res.status(201).json({
      mensaje: tipo === 'nuevo'
        ? 'Usuario creado y asignado como administrador. Se envió correo de bienvenida.'
        : 'Usuario asignado como administrador. Se envió correo de notificación.',
      data: { usuario_id: usuario.id, asignacion_id: asignacionId },
      correo: emailResult,
    })

  } catch (err) {
    await client.query('ROLLBACK')
    throw err
  } finally {
    client.release()
  }
}

// ── DELETE /api/admin/unidades/:id/administradores/:asig_id ──────────────────
/**
 * Revoca (cierre lógico) la asignación de un administrador.
 * Nunca elimina la fila — preserva historial (NOM-024).
 */
export async function revocar(req, res) {
  const { id: unidadId, asig_id } = req.params
  const { motivo } = req.body

  const { rows } = await pool.query(
    `SELECT a.id, a.usuario_id, u.email
     FROM adm_usuario_unidad_rol a
     JOIN adm_usuarios u ON a.usuario_id = u.id
     JOIN cat_roles cr  ON a.rol_id = cr.id AND cr.clave = 'ADMIN_UNIDAD'
     WHERE a.id = $1 AND a.unidad_medica_id = $2 AND a.activo = TRUE`,
    [asig_id, unidadId]
  )
  if (!rows[0]) {
    return res.status(404).json({ error: 'Asignación activa no encontrada' })
  }

  await pool.query(
    `UPDATE adm_usuario_unidad_rol
     SET activo = FALSE,
         fecha_fin = CURRENT_DATE,
         motivo_cambio = $1,
         updated_at = NOW()
     WHERE id = $2`,
    [motivo || 'Revocación de rol de administrador de unidad', asig_id]
  )

  await auditLog({
    usuario_id: req.user.sub,
    accion: 'DELETE',
    tabla_afectada: 'adm_usuario_unidad_rol',
    registro_id: asig_id,
    datos_nuevos: { activo: false, motivo },
    ip: getClientIp(req),
    user_agent: req.headers['user-agent'],
  })

  res.json({ mensaje: 'Administrador revocado exitosamente' })
}

// ── Helpers ───────────────────────────────────────────────────────────────────
function generarPassword(len = 12) {
  // Usa crypto.randomBytes para mayor seguridad
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789@#$!'
  const bytes = randomBytes(len)
  return Array.from(bytes, b => chars[b % chars.length]).join('')
}

function emailNuevoAdmin({ email, password, unidad }) {
  return {
    to: email,
    subject: 'SIRES — Tu cuenta fue creada',
    text:
      `Se te ha creado una cuenta en el Sistema SIRES como Administrador de Unidad.\n\n` +
      `Unidad  : ${unidad.nombre}\n` +
      `CLUES   : ${unidad.clues}\n\n` +
      `Correo              : ${email}\n` +
      `Contraseña temporal : ${password}\n\n` +
      `Por favor cambia tu contraseña al iniciar sesión por primera vez.`,
    html: `
      <div style="font-family:sans-serif;max-width:520px">
        <h2 style="color:#1d4ed8">Bienvenido a SIRES</h2>
        <p>Se te ha asignado el rol de <strong>Administrador de Unidad</strong> en:</p>
        <table style="margin:12px 0;border-collapse:collapse">
          <tr><td style="padding:4px 12px 4px 0;color:#6b7280">Unidad</td><td><strong>${unidad.nombre}</strong></td></tr>
          <tr><td style="padding:4px 12px 4px 0;color:#6b7280">CLUES</td><td>${unidad.clues}</td></tr>
        </table>
        <p>Tus credenciales de acceso:</p>
        <table style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:12px;width:100%">
          <tr><td style="padding:4px 12px 4px 0;color:#6b7280">Correo</td><td><code>${email}</code></td></tr>
          <tr><td style="padding:4px 12px 4px 0;color:#6b7280">Contraseña temporal</td><td><code style="color:#dc2626">${password}</code></td></tr>
        </table>
        <p style="color:#dc2626;margin-top:12px"><em>Cambia tu contraseña al iniciar sesión por primera vez.</em></p>
      </div>`,
  }
}

function emailAsignacionAdmin({ email, unidad }) {
  return {
    to: email,
    subject: 'SIRES — Asignación como Administrador de Unidad',
    text:
      `Has sido asignado como Administrador de Unidad en el Sistema SIRES.\n\n` +
      `Unidad : ${unidad.nombre}\n` +
      `CLUES  : ${unidad.clues}\n\n` +
      `Accede con tus credenciales habituales.`,
    html: `
      <div style="font-family:sans-serif;max-width:520px">
        <h2 style="color:#1d4ed8">SIRES — Nueva asignación</h2>
        <p>Has sido asignado como <strong>Administrador de Unidad</strong> en:</p>
        <table style="margin:12px 0;border-collapse:collapse">
          <tr><td style="padding:4px 12px 4px 0;color:#6b7280">Unidad</td><td><strong>${unidad.nombre}</strong></td></tr>
          <tr><td style="padding:4px 12px 4px 0;color:#6b7280">CLUES</td><td>${unidad.clues}</td></tr>
        </table>
        <p>Accede con tus credenciales habituales.</p>
      </div>`,
  }
}
