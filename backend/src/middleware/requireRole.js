/**
 * Middleware RBAC. Uso: requireRole('SUPERADMIN') o requireRole(['MEDICO', 'ENFERMERIA'])
 * Debe usarse después de verifyToken.
 */
export default function requireRole(...roles) {
  const allowed = roles.flat()
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'No autenticado' })
    }
    if (!allowed.includes(req.user.rol)) {
      return res.status(403).json({
        error: `Acceso denegado. Se requiere uno de: ${allowed.join(', ')}`,
      })
    }
    next()
  }
}
