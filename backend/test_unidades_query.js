import pool from './src/db/index.js';
async function run() {
    const q = 'hospital';
    const limit = 5;
    try {
        const { rows } = await pool.query(`
      SELECT
       u.id, u.clues, u.nombre, u.tipo_unidad, u.estatus_operacion, u.activo,
       ST_X(u.geom) AS lng, ST_Y(u.geom) AS lat,
       a.nombre_colonia, a.codigo_postal,
       m.nombre AS municipio, e.nombre AS entidad
     FROM adm_unidades_medicas u
     LEFT JOIN cat_asentamientos_cp a ON u.asentamiento_id = a.id
     LEFT JOIN cat_municipios m ON a.municipio_id = m.id
     LEFT JOIN cat_entidades e ON m.entidad_id = e.id
     WHERE u.activo = false
       AND ($1 = '' OR u.nombre ILIKE $2 OR u.clues ILIKE $2)
     ORDER BY u.nombre
     LIMIT $3`,
            [q, '%' + q + '%', limit]);
        console.log("Success! Found rows:", rows.length);
    } catch (e) { console.error("ERROR IN SQL:", e.message); }
    process.exit();
}
run();
