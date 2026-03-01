# ADR-003 — SUPERADMIN: Preguntas Adicionales (surgidas de ADR-002)

**Fecha:** 2026-02-28
**Estado:** ✅ APROBADO
**Autor:** Claude (SIRES Dev Agent)
**Contexto:** ADR-002 aprobado — decisiones sobre el alcance del SUPERADMIN

---

## Por qué este documento existe

Al definir el alcance del ADMIN_UNIDAD en ADR-002 surgieron decisiones que
afectan directamente al SUPERADMIN: ¿quién aprueba qué?, ¿qué ve el SUPERADMIN
que el admin no ve?, ¿cómo se manejan los conflictos entre niveles?

Este cuestionario cierra esas brechas antes de construir la Fase 2.

---

## Sección 1 — Supervisión sobre lo que crea el ADMIN_UNIDAD

### SA-P1. ¿Las cuentas creadas por un ADMIN_UNIDAD se activan de inmediato?

**Respuesta: B**

Las cuentas se activan inmediatamente, pero el SUPERADMIN recibe una
notificación/alerta en su panel de que se creó una cuenta nueva.

**Implicación técnica:**
- El endpoint de creación de usuario dispara una notificación en el panel del SA.
- Campo `notificaciones` en el dashboard con badge de conteo.

---

### SA-P2. ¿Cuántos ADMIN_UNIDAD puede haber por unidad?

**Respuesta: D (con default = 1)**

El SUPERADMIN define el límite de ADMIN_UNIDAD al configurar cada unidad.
Por defecto, el límite es **1** si no se especifica otro valor.

**Implicación técnica:**
- Campo `max_admin_unidad` (INT, default 1) en `adm_unidades_medicas`.
- Validación al asignar rol ADMIN_UNIDAD: contar activos y comparar con el límite.

---

### SA-P3. ¿Puede el SUPERADMIN suspender/eliminar usuarios creados por un ADMIN_UNIDAD?

**Respuesta: C (con auditoría completa)**

El SUPERADMIN solo puede **revocar asignaciones**, no eliminar la cuenta del
usuario. La cuenta queda inactiva pero el historial se preserva para auditoría
(cumplimiento NOM-024). Todo queda registrado en `sys_bitacora_auditoria`.

**Implicación técnica:**
- No existe endpoint DELETE sobre `adm_usuarios`.
- Solo se permite `activo = FALSE` en la tabla y cierre lógico en `adm_usuario_unidad_rol`.
- Bitácora obligatoria con motivo en cada revocación.

---

## Sección 2 — Catálogos Globales

### SA-P4. ¿Quién crea y mantiene los formularios GIIS del catálogo global?

**Respuesta: C**

El SUPERADMIN puede **crear formularios GIIS** directamente en la UI Y también
**importar** formularios desde archivos JSON/XML (estándar GIIS externo).

**Implicación técnica:**
- Formulario de creación manual en la UI.
- Endpoint de importación con validación de esquema JSON/XML.

---

### SA-P5. ¿Puede el SUPERADMIN marcar normativas GIIS como obligatorias para todas las unidades?

**Respuesta: B**

Sí. El SUPERADMIN puede marcar una normativa como `obligatoria = TRUE`.
El ADMIN_UNIDAD la ve activa pero el control está deshabilitado — no puede desactivarla.

**Implicación técnica:**
- Campo `obligatoria BOOLEAN DEFAULT FALSE` en `sys_normatividad_giis`.
- El frontend del ADMIN_UNIDAD deshabilita el toggle si `obligatoria = TRUE`.
- El backend rechaza cambios de estado en normativas obligatorias si el rol no es SUPERADMIN.

---

### SA-P6. ¿Puede el SUPERADMIN agregar nuevas especialidades/servicios al catálogo global?

**Respuesta: C**

Puede gestionar el catálogo, pero los cambios requieren **confirmación extra** en la UI
ya que afectan a todas las unidades del sistema.

**Implicación técnica:**
- Modal de confirmación con resumen del impacto antes de confirmar cambios.
- Bitácora obligatoria con campos afectados y actor.

---

## Sección 3 — Vista Global y Reportes

### SA-P7. ¿Qué datos clínicos puede ver el SUPERADMIN?

**Respuesta: C**

El SUPERADMIN tiene **acceso de lectura completo** a cualquier expediente de
cualquier unidad. Todo acceso queda auditado en `sys_bitacora_auditoria`.

**Implicación técnica:**
- El middleware de scope de unidad no aplica para SUPERADMIN.
- Cada lectura de expediente genera entrada en bitácora con `accion = 'LECTURA_EXPEDIENTE'`.

---

### SA-P8. ¿Qué ve el SUPERADMIN en su dashboard principal?

**Respuesta: A, B, C, D, E, F, G, H, I, J, K (todas)**

| # | Métrica |
|---|---------|
| A | Total de unidades activas / inactivas en el sistema |
| B | Total de usuarios por rol (global) |
| C | Citas del día en todo el sistema (suma) |
| D | Citas del día por unidad (tabla comparativa) |
| E | Pacientes registrados (total global) |
| F | Alertas críticas: usuarios bloqueados en cualquier unidad |
| G | Alertas de seguridad: intentos de login fallidos, tokens sospechosos |
| H | Mapa con marcadores de unidades (Leaflet) con indicador de actividad |
| I | Bitácora global: últimas 20 acciones en todo el sistema |
| J | Comparativa mensual por unidad (tabla o gráfica) |
| K | Estado de normativas GIIS: cuántas unidades han adoptado cada normativa |

---

## Sección 4 — Gestión de Unidades

### SA-P9. ¿Qué pasa cuando el SUPERADMIN desactiva una unidad?

**Respuesta: B**

Se desactiva con un **período de gracia configurable** (default: 24h) para que
el ADMIN_UNIDAD notifique al personal. El sistema envía la alerta automáticamente.
Al vencer el período, las sesiones activas se invalidan.

**Implicación técnica:**
- Campo `fecha_desactivacion_programada TIMESTAMPTZ` en `adm_unidades_medicas`.
- Job/cron que invalida tokens cuando `NOW() >= fecha_desactivacion_programada`.
- El período de gracia lo ingresa el SUPERADMIN al desactivar (default 24h).

---

### SA-P10. ¿Puede el SUPERADMIN transferir personal entre unidades?

**Respuesta: C (con matiz)**

El SUPERADMIN puede hacer la transferencia completa con un solo formulario
(revoca origen + crea destino + registra motivo en bitácora).

**Matiz aprobado:** Cualquier ADMIN_UNIDAD también puede asignar a un usuario
existente a su propia unidad si así lo requiere, sin necesidad del SUPERADMIN.

**Implicación técnica:**
- Formulario de transferencia del SUPERADMIN con selector origen/destino.
- El ADMIN_UNIDAD solo gestiona asignaciones en su unidad (no ve las de otras).

---

## Sección 5 — Permisos Especiales y Delegación

### SA-P11. ¿Puede el SUPERADMIN "impersonar" a un usuario para depuración?

**Respuesta: A**

No existe impersonación. El SUPERADMIN debe usar **cuentas de prueba** para
reproducir problemas. No se implementa esta función.

---

### SA-P12. ¿Cómo funciona la "vista cruzada" que el SUPERADMIN puede delegar?

**Respuesta: D**

El SUPERADMIN define **caso por caso** qué puede ver el ADMIN_UNIDAD al que
se le otorga vista cruzada: métricas / lista de pacientes / expedientes completos.

**Implicación técnica:**
- Tabla o columna JSONB en `adm_usuario_unidad_rol` para permisos de vista cruzada.
- El middleware lee esos permisos al resolver requests entre unidades.

---

## Sección 6 — Ciclo de Vida del Sistema

### SA-P13. ¿Cómo se gestionan las cuentas del propio SUPERADMIN?

**Respuesta: A (con extensión)**

Solo puede haber **1 SUPERADMIN activo** en el sistema. El sistema lo valida.

**Extensión aprobada:** Si se requiere que otros usuarios vean información global
sin ser ADMIN_UNIDAD, se podrán crear roles especiales de solo lectura global,
pero sin los poderes de administración del SUPERADMIN.

**Implicación técnica:**
- Validación en backend: al crear/activar SUPERADMIN, verificar que no existe otro activo.
- Posible rol futuro `AUDITOR_GLOBAL` con acceso de lectura sin capacidad de mutación.

---

### SA-P14. ¿Puede el SUPERADMIN exportar/respaldar datos desde la UI?

**Respuesta: C**

Sí. El SUPERADMIN puede:
1. Exportar reportes en **PDF o CSV** (bitácora, lista de pacientes, personal, etc.)
2. Generar un **dump de la BD** desde la UI (zip con SQL vía pg_dump).

**Implicación técnica:**
- Endpoint que ejecuta `pg_dump` y sirve el archivo como descarga.
- Reportes PDF con pdfkit / CSV directo desde queries de la BD.
- Acceso estrictamente restringido a SUPERADMIN.

---

## Sección 7 — UI y Navegación del SUPERADMIN (definición adicional)

### Estructura de navegación fija (4 secciones principales)

El panel del SUPERADMIN tiene **4 secciones fijas en el sidebar principal**,
siempre visibles. Las demás opciones derivadas del cuestionario se listan
debajo de estas 4.

| # | Sección | Descripción |
|---|---------|-------------|
| 1 | **Dashboard General** | Todas las métricas de SA-P8 (A–K). Mapa Leaflet central. |
| 2 | **Unidades Médicas** | Alta y desactivación de unidades. |
| 3 | **Usuarios** | Alta de usuarios y asignación de roles/unidades. |
| 4 | **Catálogos & GIIS** | Gestión de catálogos globales y formularios GIIS. |

---

### Detalle: Sección 2 — Unidades Médicas

- **Lista:** Solo muestra unidades que **ya han sido habilitadas** (activas).
- **Botón "Habilitar unidad":** Abre un catálogo con búsqueda por CLUES o nombre.
  - Muestra info de la unidad (nombre, CLUES, municipio, tipo) antes de confirmar.
  - Modal de confirmación con resumen antes de habilitar.
- **Botón "Desactivar":** Configura período de gracia + confirmación con motivo.
- **Detalle de unidad:** Al hacer clic en una unidad activa, acceso a su configuración
  (límite de ADMIN_UNIDAD, normativas, servicios adoptados, personal asignado).

---

### Detalle: Sección 3 — Usuarios

- **Lista de usuarios:** Filtros por rol, unidad, estado (activo/inactivo).
- **Alta de usuario:** Sigue las reglas NOM-024 para prestadores de salud:
  - CURP obligatorio y validado.
  - RFC opcional.
  - Cédula profesional (para roles MEDICO, ENFERMERA).
  - Email institucional.
  - Contraseña temporal que el usuario debe cambiar en primer login.
- **Asignación de roles:** Se puede asignar el usuario a **una o más unidades**
  habilitadas, con un rol diferente en cada una.
- **Solo unidades habilitadas** aparecen en el selector de asignación.

---

### Detalle: Sección 4 — Catálogos & GIIS

- **Sub-sección GIIS:**
  - Lista de normativas GIIS activas del sistema con indicador de adopción por unidad.
  - Botón "Nueva GIIS": formulario de creación manual.
  - Botón "Importar GIIS": carga de JSON/XML con validación de esquema.
  - Toggle de `obligatoria` por normativa.
- **Sub-sección Catálogos:**
  - Lista de catálogos maestros activos (cat_*, gui_*).
  - Catálogos que NO dependen de GIIS ni de Excel externo son editables en UI.
  - Catálogos que SÍ dependen de importación (CIE-10, SEPOMEX) muestran
    la fecha de última carga y botón de reimportación.
  - Gestión de `cat_servicios_atencion` con modal de confirmación extra.

---

### Secciones adicionales (derivadas del cuestionario, listadas bajo las 4 fijas)

| Sección | Origen |
|---------|--------|
| Transferencia de personal entre unidades | SA-P10 |
| Vista cruzada delegada a ADMIN_UNIDAD | SA-P12 |
| Exportación y respaldos | SA-P14 |
| Bitácora global de auditoría | SA-P8-I |
| Alertas de seguridad | SA-P8-G |

---

## Resumen de Decisiones

| # | Tema | Decisión |
|---|------|----------|
| SA-P1 | Activación de cuentas por ADMIN_UNIDAD | B — Activa inmediata + notificación al SA |
| SA-P2 | Límite de ADMIN_UNIDAD por unidad | D — SA lo define; default = 1 |
| SA-P3 | SA suspende cuentas del admin | C — Solo revoca asignaciones; historial preservado |
| SA-P4 | Creación de formularios GIIS | C — Crea propios e importa externos |
| SA-P5 | Normativas obligatorias | B — SA puede marcar `obligatoria = TRUE` |
| SA-P6 | Catálogo de servicios global | C — Sí, con confirmación extra |
| SA-P7 | Acceso clínico del SA | C — Lectura completa, todo auditado |
| SA-P8 | Dashboard del SA | A,B,C,D,E,F,G,H,I,J,K — Todas las métricas |
| SA-P9 | Desactivación de unidad | B — Período de gracia configurable (default 24h) |
| SA-P10 | Transferencia de personal | C — Un formulario + cualquier admin puede asignar en su unidad |
| SA-P11 | Impersonación | A — No existe |
| SA-P12 | Alcance de vista cruzada delegada | D — SA define caso por caso |
| SA-P13 | Gestión de cuentas SUPERADMIN | A — Solo 1 activo; posible rol AUDITOR_GLOBAL futuro |
| SA-P14 | Exportación desde UI | C — Reportes PDF/CSV + dump de BD |

---

## Próximos pasos

- [x] ADR-003 aprobado y documentado
- [ ] Migrar cambios de esquema derivados (campos nuevos en tablas)
- [ ] Implementar navegación fija de 4 secciones en frontend
- [ ] Implementar módulo Unidades con CLUES lookup
- [ ] Implementar módulo Usuarios con validación NOM-024
- [ ] Implementar módulo Catálogos & GIIS
