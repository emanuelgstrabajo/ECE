import { Router } from 'express'
import authRoutes       from './auth.js'
import adminRoutes      from './admin.js'
import adminUnidadRoutes from './adminUnidad.js'
import catalogosRoutes  from './catalogos.js'

const router = Router()

router.use('/auth',         authRoutes)
router.use('/admin',        adminRoutes)
router.use('/admin-unidad', adminUnidadRoutes)
router.use('/catalogos',    catalogosRoutes)

// Fase 3 — Clínica
// router.use('/pacientes',  pacienteRoutes)
// router.use('/citas',      citasRoutes)
// router.use('/atenciones', atencionRoutes)

export default router
