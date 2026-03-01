import { Router } from 'express'
import verifyToken    from '../middleware/verifyToken.js'
import requireRole    from '../middleware/requireRole.js'
import requireUnidad  from '../middleware/requireUnidad.js'

import * as au from '../controllers/adminUnidadController.js'

const router = Router()

// Todas las rutas requieren autenticación + rol ADMIN_UNIDAD + scope de unidad
const guard = [verifyToken, requireRole('ADMIN_UNIDAD'), requireUnidad]

// Dashboard
router.get('/dashboard',  ...guard, au.dashboard)

// Personal de la unidad
router.get('/personal',                    ...guard, au.listarPersonal)
router.get('/personal/:asignacion_id',     ...guard, au.obtenerPersonal)
router.post('/personal',                   ...guard, au.crearPersonal)
router.delete('/personal/:asignacion_id',  ...guard, au.revocarPersonal)

// Servicios y normativas
router.get('/servicios',   ...guard, au.listarServicios)
router.get('/normativas',  ...guard, au.listarNormativas)

// Bitácora de la unidad
router.get('/bitacora', ...guard, au.listarBitacora)

export default router
