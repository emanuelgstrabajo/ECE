import { Router } from 'express'
import { login, refresh, logout, me } from '../controllers/authController.js'
import verifyToken from '../middleware/verifyToken.js'

const router = Router()

// POST /api/auth/login
router.post('/login', login)

// POST /api/auth/refresh  — renueva el access token usando la cookie
router.post('/refresh', refresh)

// POST /api/auth/logout  — requiere estar autenticado para registrar en bitácora
router.post('/logout', verifyToken, logout)

// GET /api/auth/me  — datos del usuario actual
router.get('/me', verifyToken, me)

export default router
