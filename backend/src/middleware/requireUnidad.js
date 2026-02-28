/**
 * Middleware de scope de unidad — Fase 2 (ADMIN_UNIDAD y roles operativos).
 *
 * Garantiza que el usuario autenticado solo accede a recursos de su propia
 * unidad médica activa. Debe usarse DESPUÉS de verifyToken.
 *
 * Comportamiento:
 *  - SUPERADMIN → pasa sin restricción (ve todas las unidades)
 *  - Roles operativos → valida que unidad_medica_id del token coincida con
 *    el parámetro de unidad del request (si existe)
 *  - Sin unidad en token → rechaza con 403
 *
 * Uso:
 *   router.get('/mi-ruta', verifyToken, requireUnidad, miController)
 *
 *   // Para rutas con :unidad_id en el path:
 *   router.get('/unidades/:unidad_id/pacientes', verifyToken, requireUnidad, listarPacientes)
 *
 * En los controllers que usen este middleware, la unidad activa estará en:
 *   req.unidad_id  →  Number (unidad_medica_id del token)
 */
export default function requireUnidad(req, res, next) {
  if (!req.user) {
    return res.status(401).json({ error: 'No autenticado' })
  }

  // SUPERADMIN tiene acceso irrestricto a todas las unidades
  if (req.user.rol === 'SUPERADMIN') {
    req.unidad_id = req.user.unidad_medica_id ?? null
    return next()
  }

  // Roles operativos deben tener una unidad activa en el token
  if (!req.user.unidad_medica_id) {
    return res.status(403).json({
      error: 'Token sin unidad activa. Reinicie sesión y seleccione una unidad.',
      code: 'NO_UNIT_IN_TOKEN',
    })
  }

  // Si el request incluye un parámetro de unidad explícito, debe coincidir
  const unidadParam =
    req.params.unidad_id ??
    req.params.unidad_medica_id ??
    req.body?.unidad_medica_id ??
    req.query?.unidad_id

  if (unidadParam !== undefined && unidadParam !== null) {
    const unidadSolicitada = parseInt(unidadParam, 10)
    if (unidadSolicitada !== req.user.unidad_medica_id) {
      return res.status(403).json({
        error: 'No tiene acceso a esta unidad médica.',
        code: 'UNIT_SCOPE_VIOLATION',
      })
    }
  }

  // Inyectar en req para uso downstream (evita leer req.user.unidad_medica_id en cada controller)
  req.unidad_id = req.user.unidad_medica_id
  next()
}
