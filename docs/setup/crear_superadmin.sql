-- ============================================================
-- Script de configuración inicial — Crear primer SUPERADMIN
-- Ejecutar UNA SOLA VEZ en pgAdmin o psql después de restaurar
-- la base de datos desde el backup.
--
-- ⚠ IMPORTANTE: Cambiar email, curp y password_hash antes de ejecutar.
-- Para generar un hash bcrypt usa:
--   node -e "const b=require('bcrypt'); b.hash('TuPasswordAqui',12).then(h=>console.log(h))"
-- ============================================================

-- 1. Verificar que el rol SUPERADMIN existe
SELECT id, clave, nombre FROM cat_roles WHERE clave = 'SUPERADMIN';

-- 2. Insertar el primer usuario SUPERADMIN
-- ⚠ Reemplaza el password_hash con el resultado del comando bcrypt de arriba
INSERT INTO adm_usuarios (curp, email, password_hash, activo, rol_id)
VALUES (
    'XXXX000000XXXXXXXX',                         -- ← Cambiar por tu CURP
    'admin@eceglobal.mx',                          -- ← Cambiar por tu email
    '$2b$12$REEMPLAZA.ESTE.HASH.CON.UNO.REAL',    -- ← Cambiar por hash bcrypt
    true,
    (SELECT id FROM cat_roles WHERE clave = 'SUPERADMIN')
)
ON CONFLICT (email) DO NOTHING
RETURNING id, email, curp;

-- 3. Verificar el resultado
SELECT u.id, u.email, u.curp, r.clave AS rol
FROM adm_usuarios u
JOIN cat_roles r ON u.rol_id = r.id
WHERE r.clave = 'SUPERADMIN';
