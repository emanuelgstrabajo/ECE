# Cuestionario de Alcance — SuperAdministrador SIRES
## Respuestas definitivas (sesión 2026-02-28)

Estas decisiones son **vinculantes** para el desarrollo. Antes de cualquier cambio de esquema de BD, presentar pros/contras al usuario.

---

### P1 — Activación de Unidades Médicas
- Las unidades se activan **solo desde el catálogo oficial CLUES** (no se crean desde cero)
- El flujo de activación es: asignar ADMIN_UNIDAD → definir servicios → marcar como operativa
- Una unidad **desactivada**: no puede recibir nuevas atenciones, los usuarios no pueden seleccionarla, pero todo el historial clínico permanece intacto e inalterable

### P2 — Propiedad de los Expedientes
- Los expedientes **pertenecen al SISTEMA**, no a una unidad específica
- Un paciente tiene UN solo expediente global (MPI)
- No existen expedientes duplicados por unidad

### P3 — Datos al Desactivar una Unidad
- Todas las atenciones históricas se conservan sin cambios
- El historial sigue siendo consultable (según configuración de visibilidad)
- La unidad desaparece de los selectores activos

### P4 — Creación de Usuarios
- Opción **B**: SuperAdmin crea usuarios globalmente; cada ADMIN_UNIDAD asigna qué usuarios pueden operar en su unidad y con qué rol
- Un usuario puede tener asignaciones en múltiples unidades

### P5 — Múltiples Roles por Usuario
- **Sí**: un mismo usuario puede tener múltiples roles en la misma unidad
- La UI muestra únicamente las funcionalidades del rol activo en la unidad activa

### P6 — Atención Fuera de Horario
- No se bloquea (se permite atender fuera del horario asignado)
- Se **registra y notifica** en bitácora con flag especial
- Requiere almacenar horarios por asignación usuario-unidad-rol

### P7 — Datos Profesionales del Personal
- Datos globales (cédula, especialidad base): se gestionan una vez por persona
- Especialización por unidad: se configura a nivel de asignación en cada unidad

### P8 — Selección de Unidad al Iniciar Sesión
- Después del login, el usuario ve un **selector de unidad activa**
- Si solo tiene una unidad asignada, entra directo

### P9 — Cambio de Unidad en Sesión Activa
- **Sí**: el usuario puede cambiar de unidad activa sin cerrar sesión
- Al cambiar, los datos del contexto se actualizan automáticamente
- Se emite un nuevo access token con `unidad_activa_id` y `rol_activo` actualizados

### P10 — Visibilidad de Pacientes Propios
- Un usuario puede ver todos los pacientes que ha atendido previamente
- Las nuevas acciones siempre se registran bajo la **unidad activa actual**

### P11 — Expediente Global del Paciente
- El expediente es **GLOBAL** (MPI único por CURP)
- No hay expedientes duplicados entre unidades
- Un paciente puede ser atendido en múltiples unidades con el mismo expediente

### P12 — Visibilidad Cruzada de Atenciones
- **Configurable por unidad**: cada unidad define si puede ver atenciones de otras unidades para el mismo paciente
- Ejemplo: unidad de 1er nivel solo ve sus atenciones; hospital de 3er nivel ve todo el historial

### P13 — Transferencia de Expedientes
- Los expedientes no se "transfieren" porque son globales
- La visibilidad cruzada se controla por configuración (ver P12)

### P14 — Gestión de Catálogos
**SuperAdmin gestiona globalmente:**
- CIE-10 y CIE-9 (adoptables por unidad)
- Logos y avisos del sistema
- Normativas GIIS activas

**ADMIN_UNIDAD gestiona en su unidad:**
- Personal asignado y roles
- Agendas y horarios
- Salas, quirófanos y consultorios
- Servicios adoptados

### P15 — Restricción de Guías GIIS por Tipo de Unidad
- **Sí**: SuperAdmin puede configurar qué guías GIIS puede usar cada unidad según su tipo/nivel
- (Ej: unidades de salud bucal solo ven GIIS-B016)

### P16 — Acceso de SuperAdmin a Datos Clínicos
- SuperAdmin tiene **acceso completo** a todos los datos clínicos de todas las unidades

### P17 — Dashboard del SuperAdmin
- Requiere: unidades activas, usuarios por rol, atenciones por unidad/periodo, alertas de seguridad desde bitácora, y métricas adicionales según se defina

### P18 — Suplantación de Identidad
- **No**: no hay impersonación. Cada usuario tiene identidad única para integridad de la auditoría NOM-024

### P19 — Políticas de Seguridad
- **Sí a todo**: expiración de token, bloqueo por intentos fallidos, caducidad de contraseña, 2FA (futuro)
- Políticas de contraseña **globales** (gestionadas por SuperAdmin)

### P20 — Jerarquía de SuperAdministradores
- Solo el SuperAdmin raíz puede crear otros SuperAdmins
- Los sub-SuperAdmins tienen **más permisos que ADMIN_UNIDAD pero menos que el SuperAdmin raíz**
- Se requiere un nuevo nivel de rol (ej: `ADMIN_SISTEMA`) con permisos globales acotados

---

## Cambios de Esquema Pendientes (requieren aprobación antes de ejecutar DDL)

### CRÍTICO: Modelo Multi-Unidad de Usuarios
**Problema:** `adm_personal_salud` actual es 1-a-1 (un usuario, una unidad, un rol).
**Necesidad:** Un usuario puede trabajar en múltiples unidades con diferentes roles.
**Propuesta pendiente:** Nueva tabla `adm_usuario_unidad_rol` (muchos-a-muchos) con campos:
- `usuario_id` (FK adm_usuarios)
- `unidad_medica_id` (FK adm_unidades_medicas)
- `rol_id` (FK cat_roles)
- `horario` JSONB (turnos/horarios por asignación)
- `especialidad_en_unidad` VARCHAR
- `activo` BOOLEAN
- `fecha_asignacion` TIMESTAMP

**IMPORTANTE:** Presentar pros/contras al usuario ANTES de ejecutar.

### Configuración de Visibilidad Cruzada
Nueva columna o tabla para controlar si una unidad puede ver atenciones de otras unidades para el mismo paciente.

### Nuevo Rol ADMIN_SISTEMA
Agregar a `cat_roles` un rol entre SUPERADMIN y ADMIN_UNIDAD para sub-superadmins.
