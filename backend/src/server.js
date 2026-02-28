import app from './app.js'
import pool from './db/index.js'
import dotenv from 'dotenv'

dotenv.config()

const PORT = parseInt(process.env.PORT) || 3001

async function start() {
  // Verificar conexión a la base de datos
  try {
    const client = await pool.connect()
    await client.query('SELECT 1')
    client.release()
    console.log('[DB] Conexión a PostgreSQL verificada ✓')
  } catch (err) {
    console.error('[DB] No se pudo conectar a PostgreSQL:', err.message)
    process.exit(1)
  }

  app.listen(PORT, () => {
    console.log(`[SIRES] Servidor corriendo en http://localhost:${PORT}`)
    console.log(`[SIRES] Health check: http://localhost:${PORT}/health`)
  })
}

start()
