import { Router } from 'express'
import verifyToken from '../middleware/verifyToken.js'
import requireRole from '../middleware/requireRole.js'

import * as unidades from '../controllers/unidadesController.js'
import * as usuarios from '../controllers/usuariosController.js'
import * as personal from '../controllers/personalController.js'
import * as bitacora from '../controllers/bitacoraController.js'

const router = Router()
const soloSuperAdmin = [verifyToken, requireRole('SUPERADMIN')]

// ── Unidades Médicas ──────────────────────────────────────────────
router.get('/unidades',            ...soloSuperAdmin, unidades.listar)
router.get('/unidades/mapa',       ...soloSuperAdmin, unidades.listarMapa)
router.get('/unidades/:id',        ...soloSuperAdmin, unidades.obtener)
router.post('/unidades',           ...soloSuperAdmin, unidades.crear)
router.put('/unidades/:id',        ...soloSuperAdmin, unidades.actualizar)
router.delete('/unidades/:id',     ...soloSuperAdmin, unidades.desactivar)

// ── Usuarios del Sistema ──────────────────────────────────────────
router.get('/usuarios',                    ...soloSuperAdmin, usuarios.listar)
router.get('/usuarios/:id',                ...soloSuperAdmin, usuarios.obtener)
router.post('/usuarios',                   ...soloSuperAdmin, usuarios.crear)
router.put('/usuarios/:id',                ...soloSuperAdmin, usuarios.actualizar)
router.post('/usuarios/:id/reset-password',...soloSuperAdmin, usuarios.resetPassword)
router.post('/usuarios/:id/desbloquear',   ...soloSuperAdmin, usuarios.desbloquear)

// ── Personal de Salud ─────────────────────────────────────────────
router.get('/personal',        ...soloSuperAdmin, personal.listar)
router.get('/personal/:id',    ...soloSuperAdmin, personal.obtener)
router.post('/personal',       ...soloSuperAdmin, personal.crear)
router.put('/personal/:id',    ...soloSuperAdmin, personal.actualizar)
router.delete('/personal/:id', ...soloSuperAdmin, personal.eliminar)

// ── Bitácora NOM-024 ──────────────────────────────────────────────
router.get('/bitacora', ...soloSuperAdmin, bitacora.listar)

export default router
