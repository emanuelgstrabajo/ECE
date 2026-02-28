import express from 'express'
import cors from 'cors'
import cookieParser from 'cookie-parser'
import dotenv from 'dotenv'
import router from './routes/index.js'

dotenv.config()

const app = express()

// CORS — permite solo el frontend
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true,
}))

// Parsers
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

// Rutas
app.use('/api', router)

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', sistema: 'SIRES', version: '1.0.0' })
})

// 404
app.use((_req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' })
})

// Manejador global de errores (Express 5 lo captura automáticamente en async)
app.use((err, _req, res, _next) => {
  console.error('[ERROR]', err.message)
  const status = err.status || 500
  res.status(status).json({
    error: process.env.NODE_ENV === 'production'
      ? 'Error interno del servidor'
      : err.message,
  })
})

export default app
