# SIRES — Sistema de Registro de Salud
## Contexto del Proyecto

Sistema de Expediente Clínico Electrónico (ECE) para ECE Global.
Cumplimiento: **NOM-024-SSA3-2010**.
Base de datos: **PostgreSQL 14** · Base: `ece_global`.

---

## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| Backend | Node.js 20 LTS + Express 5 |
| Base de datos | PostgreSQL 14 (Docker local) |
| ORM | `pg` (node-postgres) — sin ORM pesado |
| Autenticación | JWT Access Token (15 min) + Refresh Token (7 días, HttpOnly cookie) |
| Passwords | bcrypt |
| Frontend | React 18 + Vite + TailwindCSS + React Query + React Hook Form |
| Enrutamiento | React Router v6 |
| Mapas | Leaflet.js (unidades médicas con PostGIS) |
| PDFs | pdfkit |
| Control de versiones | Git con tags de checkpoint por fase |

---

## Estructura de Directorios (objetivo)

```
C:\ECE Global\
├── backend/
│   ├── src/
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── middleware/
│   │   └── db/
│   ├── .env
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── pages/
│   │   ├── components/
│   │   ├── hooks/
│   │   └── api/
│   └── package.json
├── docker-compose.yml
├── CLAUDE.md
└── docs/
    ├── postman/
    └── backups/
```

---

## Base de Datos — Resumen de Tablas

### Prefijos por dominio
- `adm_` → Administración (usuarios, unidades, personal)
- `cat_` → Catálogos maestros (CIE-10, CIE-9, roles, municipios, etc.)
- `clin_` → Clínica (pacientes, citas, atenciones)
- `sys_` → Sistema (normativas GIIS, bitácora, campos dinámicos)
- `gui_` → Interfaz (diccionarios y opciones para formularios)
- `doc_` → Documentos (expediente digital)
- `rel_` → Relaciones (normatividad-opciones)

### Tablas clave

```sql
-- ADMINISTRACIÓN
adm_usuarios          -- Login: CURP, email, password_hash, rol_id, bloqueo
adm_unidades_medicas  -- Unidades con geom PostGIS (Point 4326), CLUES
adm_personal_salud    -- Personal médico vinculado a usuario y unidad

-- CATÁLOGOS
cat_roles             -- RBAC: SUPERADMIN, ADMIN_UNIDAD, MEDICO, ENFERMERA, RECEPCIONISTA, PACIENTE
cat_tipos_personal    -- Tipos de personal de salud
cat_servicios_atencion
cat_cie10_diagnosticos
cat_cie9_procedimientos
cat_entidades, cat_municipios, cat_asentamientos_cp  -- Geografía SEPOMEX

-- CLÍNICA
clin_pacientes        -- MPI: CURP, expediente global, datos_clinicos JSONB
clin_citas            -- Agenda: estatus PROGRAMADA/EN_ESPERA/ATENDIDA/CANCELADA
clin_atenciones       -- Tabla particionada por año (fecha_atencion RANGE)
clin_atenciones_2026  -- Partición activa 2026

-- SISTEMA
sys_normatividad_giis      -- Normativas (NOM-024, etc.)
sys_giis_campos            -- Campos de formularios dinámicos
sys_giis_restricciones     -- Motor de reglas JSONB (validaciones clínicas)
sys_bitacora_auditoria     -- Log INMUTABLE con trigger anti-borrado
sys_adopcion_catalogos
sys_registro_catalogos

-- GUI / DOCUMENTOS
gui_diccionarios, gui_diccionario_opciones  -- Catálogos de UI con jerarquía
doc_expediente_digital      -- PDFs con hash_integridad SHA-256 (NOM-024)
rel_normatividad_opciones   -- Qué opciones adopta cada unidad
cat_matriz_personal_servicio
```

### Extensiones PostgreSQL activas
- `uuid-ossp` → UUIDs como PKs en tablas clínicas
- `pgcrypto` → Funciones criptográficas
- `postgis` → Geometría espacial para unidades médicas

---

## Roles del Sistema (RBAC)

| Rol | Descripción |
|-----|-------------|
| `SUPERADMIN` | Control total del sistema. Activa unidades, gestiona catálogos globales |
| `ADMIN_UNIDAD` | Administra su unidad: personal, roles, catálogos adoptados |
| `MEDICO` | Atiende pacientes, registra consultas con formularios GIIS |
| `ENFERMERA` | Signos vitales, notas de enfermería |
| `RECEPCIONISTA` | Abre expedientes, agenda citas, lista de espera |
| `PACIENTE` | Solo lectura: su expediente, citas y documentos |

---

## Roadmap por Fases

### FASE 1 — Superadministrador & Cimientos (Sem 1–4)
**Checkpoint:** `checkpoint-fase-1`

Infraestructura completa + módulo SUPERADMIN:
- Docker Compose (PostgreSQL 14 + pgAdmin)
- Scaffold backend Express + frontend React/Vite
- Autenticación JWT con bcrypt
- CRUD unidades médicas con mapa Leaflet/PostGIS
- Gestión de todos los catálogos maestros (cat_*, gui_*, sys_*)
- Bitácora de auditoría en cada mutación
- Gestión de normativas GIIS y formularios dinámicos

### FASE 2 — Administrador de Unidad (Sem 5–8)
**Checkpoint:** `checkpoint-fase-2`

- Dashboard con scope de unidad (middleware de aislamiento)
- Alta/baja de personal (adm_personal_salud)
- Asignación de roles operativos
- Configuración de normativas y servicios adoptados por la unidad
- Middleware: ningún admin ve datos de otra unidad

### FASE 3 — Usuarios Operativos Clínicos (Sem 9–12)
**Checkpoint:** `checkpoint-fase-3`

- **Recepción:** apertura de expedientes (clin_pacientes), agenda de citas (clin_citas)
- **Médico:** formularios GIIS dinámicos (sys_giis_campos + sys_giis_restricciones), CIE-10/CIE-9, firma SHA-256 NOM-024
- **Enfermería:** signos vitales y notas
- **Documentos:** subida a doc_expediente_digital con hash de integridad

### FASE 4 — Portal del Paciente (Sem 13–16)
**Checkpoint:** `checkpoint-fase-4`

- Login del paciente (rol PACIENTE)
- Vista de su expediente (solo lectura)
- Historial de atenciones y documentos
- Gestión de sus citas (solicitar/cancelar)
- Row-level security lógico: paciente_id del JWT validado en cada endpoint

---

## Reglas de Desarrollo

1. **Cada endpoint que muta datos llama a `auditLogger()`** — inserta en `sys_bitacora_auditoria`
2. **Nunca usar `sudo npm`** — configurar permisos de npm correctamente
3. **Variables de entorno en `.env`** — nunca credenciales en código
4. **Scope de unidad en Fases 2-3** — middleware valida `unidad_medica_id` del token
5. **clin_atenciones está particionada** — insertar siempre especificando la partición del año activo
6. **Hash SHA-256 obligatorio** en `doc_expediente_digital.hash_integridad` (NOM-024)
7. **Checkpoint antes de iniciar fase nueva** — git tag + pg_dump + colección Postman

---

## Comandos Frecuentes

```bash
# Levantar entorno local
docker-compose up -d

# Backend
cd backend && npm run dev

# Frontend
cd frontend && npm run dev

# Restaurar backup de BD
psql -U postgres -d ece_global < docs/backups/SIRES_FULL_ESTRUCTURA_Y_CATALOGOS_2026.sql

# Crear checkpoint
git add . && git commit -m "feat: checkpoint fase N completo"
git tag checkpoint-fase-N
pg_dump -U postgres ece_global > docs/backups/backup_checkpoint_fase_N.sql
```

---

## Estado Actual

- [x] Base de datos diseñada y con catálogos cargados
- [x] Roadmap de 4 fases definido
- [ ] **EN PROGRESO: Fase 1 — Infraestructura y Superadministrador**
