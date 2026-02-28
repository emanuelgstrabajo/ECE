import { Router } from 'express'
import { login, seleccionarUnidad, refresh, logout, me } from '../controllers/authController.js'
import verifyToken from '../middleware/verifyToken.js'

const router = Router()

// POST /api/auth/login — credenciales → token o selector de unidad
router.post('/login', login)

// POST /api/auth/seleccionar-unidad — pre_token + asignacion_id → access token completo
router.post('/seleccionar-unidad', seleccionarUnidad)

// POST /api/auth/refresh — renueva el access token con el mismo contexto de unidad
router.post('/refresh', refresh)

// POST /api/auth/logout
router.post('/logout', verifyToken, logout)

// GET /api/auth/me — datos del usuario autenticado
router.get('/me', verifyToken, me)

export default router
