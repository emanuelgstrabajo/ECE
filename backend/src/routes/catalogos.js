import { Router } from 'express'
import verifyToken from '../middleware/verifyToken.js'
import * as cat from '../controllers/catalogosController.js'

const router = Router()

// Todos los catálogos requieren autenticación (cualquier rol)
router.use(verifyToken)

router.get('/roles',             cat.roles)
router.get('/tipos-personal',    cat.tiposPersonal)
router.get('/entidades',         cat.entidades)
router.get('/municipios',        cat.municipios)
router.get('/asentamientos',     cat.asentamientos)
router.get('/cie10',             cat.cie10)
router.get('/cie9',              cat.cie9)
router.get('/servicios',         cat.servicios)
router.get('/diccionario/:codigo', cat.diccionario)

export default router
