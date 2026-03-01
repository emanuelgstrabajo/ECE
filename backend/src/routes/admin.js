import { Router } from 'express'
import verifyToken from '../middleware/verifyToken.js'
import requireRole from '../middleware/requireRole.js'

import * as dashboard from '../controllers/dashboardController.js'
import * as unidades  from '../controllers/unidadesController.js'
import * as usuarios  from '../controllers/usuariosController.js'
import * as personal  from '../controllers/personalController.js'
import * as bitacora  from '../controllers/bitacoraController.js'
import * as giis      from '../controllers/giisController.js'

const router = Router()
const soloSuperAdmin = [verifyToken, requireRole('SUPERADMIN')]

// ── Dashboard SUPERADMIN ──────────────────────────────────────────
router.get('/dashboard', ...soloSuperAdmin, dashboard.obtenerMetricas)

// ── Unidades Médicas ──────────────────────────────────────────────
// IMPORTANTE: rutas específicas ANTES de /:id para evitar colisiones
router.get('/unidades/mapa',        ...soloSuperAdmin, unidades.listarMapa)
router.get('/unidades/catalogo',    ...soloSuperAdmin, unidades.buscarCatalogo)
router.get('/unidades',             ...soloSuperAdmin, unidades.listar)
router.get('/unidades/:id',         ...soloSuperAdmin, unidades.obtener)
router.post('/unidades',            ...soloSuperAdmin, unidades.crear)
router.post('/unidades/:id/habilitar', ...soloSuperAdmin, unidades.habilitar)
router.put('/unidades/:id',         ...soloSuperAdmin, unidades.actualizar)
router.delete('/unidades/:id',      ...soloSuperAdmin, unidades.desactivar)

// ── Usuarios del Sistema ──────────────────────────────────────────
router.get('/usuarios',                      ...soloSuperAdmin, usuarios.listar)
router.get('/usuarios/:id',                  ...soloSuperAdmin, usuarios.obtener)
router.post('/usuarios',                     ...soloSuperAdmin, usuarios.crear)
router.put('/usuarios/:id',                  ...soloSuperAdmin, usuarios.actualizar)
router.post('/usuarios/:id/reset-password',  ...soloSuperAdmin, usuarios.resetPassword)
router.post('/usuarios/:id/desbloquear',     ...soloSuperAdmin, usuarios.desbloquear)

// ── Asignaciones usuario ↔ unidad ↔ rol ──────────────────────────
// Historial completo, cierre lógico — nunca DELETE físico (NOM-024)
router.get('/usuarios/:id/asignaciones',              ...soloSuperAdmin, personal.listarAsignaciones)
router.post('/usuarios/:id/asignaciones',             ...soloSuperAdmin, personal.crearAsignacion)
router.delete('/usuarios/:id/asignaciones/:asig_id',  ...soloSuperAdmin, personal.revocarAsignacion)

// ── Perfiles de Personal de Salud ────────────────────────────────
router.get('/personal',        ...soloSuperAdmin, personal.listar)
router.get('/personal/:id',    ...soloSuperAdmin, personal.obtener)
router.post('/personal',       ...soloSuperAdmin, personal.crear)
router.put('/personal/:id',    ...soloSuperAdmin, personal.actualizar)
router.delete('/personal/:id', ...soloSuperAdmin, personal.eliminar)

// ── Normativas GIIS ───────────────────────────────────────────────
router.get('/giis',                   ...soloSuperAdmin, giis.listar)
router.get('/giis/:id',               ...soloSuperAdmin, giis.obtener)
router.post('/giis',                  ...soloSuperAdmin, giis.crear)
router.put('/giis/:id',               ...soloSuperAdmin, giis.actualizar)
router.patch('/giis/:id/estatus',     ...soloSuperAdmin, giis.cambiarEstatus)
router.get('/giis/:id/campos',        ...soloSuperAdmin, giis.listarCampos)

// ── Bitácora NOM-024 ──────────────────────────────────────────────
router.get('/bitacora', ...soloSuperAdmin, bitacora.listar)

export default router
