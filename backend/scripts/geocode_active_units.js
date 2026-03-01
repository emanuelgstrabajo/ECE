import 'dotenv/config'
import fetch from 'node-fetch'
import pg from 'pg'

const { Pool } = pg

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'ece_global',
  password: process.env.DB_PASSWORD || '12345',
  port: process.env.DB_PORT || 5432,
})

async function run() {
  try {
    const res = await pool.query(`
      SELECT
        u.id, u.nombre, m.nombre AS municipio, e.nombre AS entidad
      FROM adm_unidades_medicas u
      LEFT JOIN cat_asentamientos_cp a ON u.asentamiento_id = a.id
      LEFT JOIN cat_municipios m ON a.municipio_id = m.id
      LEFT JOIN cat_entidades e ON m.entidad_id = e.id
      WHERE u.activo = true AND u.geom IS NULL
    `)

    const units = res.rows
    console.log(`Found ${units.length} active units without geometry.`)

    for (const unit of units) {
      const query = `${unit.nombre}, ${unit.municipio || ''}, ${unit.entidad || ''}, Mexico`
        .replace(/  +/g, ' ')
        .replace(/^, /, '')

      console.log(`Geocoding ID ${unit.id}: ${query}`)

      try {
        const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=1`
        const geoRes = await fetch(url)
        const geoData = await geoRes.json()

        if (geoData && geoData.length > 0) {
          const lat = parseFloat(geoData[0].lat)
          const lng = parseFloat(geoData[0].lon)

          await pool.query(
            "UPDATE adm_unidades_medicas SET geom = ST_SetSRID(ST_MakePoint($1, $2), 4326) WHERE id = $3",
            [lng, lat, unit.id]
          )
          console.log(`  -> SUCCESS: ${lat}, ${lng}`)
        } else {
          console.log(`  -> FAILED: No results`)
        }

        // Polite delay for Nominatim
        await new Promise(resolve => setTimeout(resolve, 1500))
      } catch (err) {
        console.error(`  -> ERROR:`, err.message)
      }
    }
  } catch (err) {
    console.error(err)
  } finally {
    await pool.end()
  }
}

run()
