# ADR-003 — SUPERADMIN: Preguntas Adicionales (surgidas de ADR-002)

**Fecha:** 2026-02-28
**Estado:** ⏳ EN REVISIÓN — Pendiente de respuestas
**Autor:** Claude (SIRES Dev Agent)
**Contexto:** ADR-002 aprobado — nuevas dudas sobre el alcance del SUPERADMIN

---

## Por qué este documento existe

Al definir el alcance del ADMIN_UNIDAD en ADR-002 surgieron decisiones que
afectan directamente al SUPERADMIN: ¿quién aprueba qué?, ¿qué ve el SUPERADMIN
que el admin no ve?, ¿cómo se manejan los conflictos entre niveles?

Este cuestionario cierra esas brechas antes de construir la Fase 2.

---

## Sección 1 — Supervisión sobre lo que crea el ADMIN_UNIDAD

El ADMIN_UNIDAD (ADR-002 P1=D) puede crear cuentas de usuario y designar
otros administradores en su unidad de forma autónoma.

### SA-P1. ¿Las cuentas creadas por un ADMIN_UNIDAD se activan de inmediato?

**Opciones:**

| # | Comportamiento | Implicación |
|---|---------------|-------------|
| A | Sí, se activan inmediatamente. El ADMIN_UNIDAD tiene plena autonomía. | Más ágil; el admin no depende del SUPERADMIN para el día a día. |
| B | Se activan inmediatamente, pero el SUPERADMIN recibe una notificación/alerta en su panel de que se creó una cuenta nueva. | Autonomía con visibilidad. |
| C | Quedan en estado "pendiente de aprobación". El SUPERADMIN debe aprobarlas antes de que el usuario pueda hacer login. | Control total; puede ser lento si el SUPERADMIN no está disponible. |

**Tu respuesta:** ___

---

### SA-P2. ¿Cuántos ADMIN_UNIDAD puede haber por unidad?

El ADMIN_UNIDAD puede designar otros admins en su unidad (ADR-002 P1=D).

**Opciones:**

| # | Límite |
|---|--------|
| A | Sin límite. Puede haber N administradores por unidad. |
| B | Máximo 2 por unidad (titular + suplente). |
| C | Solo 1. Si ya hay un ADMIN_UNIDAD activo, no puede designarse otro sin revocar al primero. |
| D | El SUPERADMIN define el límite por unidad al configurarla. |

**Tu respuesta:** ___

---

### SA-P3. ¿Puede el SUPERADMIN suspender/eliminar usuarios creados por un ADMIN_UNIDAD?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Sí, sin restricciones. El SUPERADMIN tiene autoridad sobre cualquier cuenta del sistema. |
| B | Sí, pero debe registrar motivo y se notifica al ADMIN_UNIDAD que creó la cuenta. |
| C | No puede eliminarlos directamente; solo puede revocar sus asignaciones. La cuenta queda inactiva pero el historial se preserva. |

**Tu respuesta:** ___

---

## Sección 2 — Catálogos Globales

### SA-P4. ¿Quién crea y mantiene los formularios GIIS del catálogo global?

El ADMIN_UNIDAD solo adopta formularios ya existentes (ADR-002 P4). Alguien
los tiene que crear primero.

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Solo el SUPERADMIN crea y modifica formularios GIIS del catálogo global. |
| B | El SUPERADMIN puede importar formularios desde un archivo JSON/XML (estándar GIIS externo). |
| C | Ambas: el SUPERADMIN crea los propios y puede importar externos. |

**Tu respuesta:** ___

---

### SA-P5. ¿Puede el SUPERADMIN marcar normativas GIIS como obligatorias para todas las unidades?

Si hay una normativa que toda unidad DEBE reportar (ej: NOM-024 base), ¿puede
forzarse para que el admin no la pueda desactivar?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | No. Todas las normativas son opcionales; cada unidad adopta las que quiera. |
| B | Sí. El SUPERADMIN puede marcar una normativa como `obligatoria = TRUE`. El admin la ve activa pero no puede desactivarla. |

**Tu respuesta:** ___

---

### SA-P6. ¿Puede el SUPERADMIN agregar nuevas especialidades/servicios al catálogo global?

La tabla `cat_servicios_atencion` contiene los servicios disponibles del sistema.

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | El catálogo de servicios es fijo (viene precargado con la BD). Nadie lo modifica en producción. |
| B | Solo el SUPERADMIN puede agregar, editar o desactivar servicios del catálogo global. |
| C | El SUPERADMIN puede gestionarlo, pero los cambios requieren una confirmación extra (porque afectan a todas las unidades). |

**Tu respuesta:** ___

---

## Sección 3 — Vista Global y Reportes

### SA-P7. ¿Qué datos clínicos puede ver el SUPERADMIN?

El SUPERADMIN tiene acceso global. ¿Hasta qué nivel llega ese acceso sobre
expedientes clínicos?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | El SUPERADMIN solo ve métricas agregadas por unidad. No puede abrir expedientes individuales. |
| B | El SUPERADMIN puede ver la lista de pacientes de cualquier unidad, pero no el expediente clínico. |
| C | El SUPERADMIN tiene acceso de lectura completo a cualquier expediente de cualquier unidad (igual que ADMIN_UNIDAD en su unidad). Todo queda auditado. |
| D | El SUPERADMIN no tiene acceso clínico; ese nivel es solo operativo (médicos). Separación estricta de responsabilidades. |

**Tu respuesta:** ___

---

### SA-P8. ¿Qué ve el SUPERADMIN en su dashboard principal?

**Opciones (puedes elegir varias):**

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

**Tu respuesta (ej: A, B, H):** ___

---

## Sección 4 — Gestión de Unidades

### SA-P9. ¿Qué pasa cuando el SUPERADMIN desactiva una unidad?

Si una clínica cierra o se suspende temporalmente:

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Se desactiva la unidad y todos los usuarios de esa unidad pierden acceso inmediatamente. Sus sesiones activas se invalidan. |
| B | Se desactiva la unidad con un período de gracia configurable (ej: 24h) para que el admin de la unidad notifique al personal. |
| C | Solo se marca como inactiva. Los usuarios pueden seguir haciendo login pero aparece un aviso. El acceso se corta en una fecha programada. |

**Tu respuesta:** ___

---

### SA-P10. ¿Puede el SUPERADMIN transferir personal entre unidades?

Si un médico pasa de una clínica a otra, ¿el SUPERADMIN puede mover la asignación
o el ADMIN_UNIDAD de la unidad destino debe crear la nueva asignación?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | El SUPERADMIN puede revocar la asignación en la unidad origen y crear la nueva en destino directamente. |
| B | El proceso requiere dos acciones: el admin de la unidad origen revoca y el admin destino crea la nueva. El SUPERADMIN supervisa pero no actúa. |
| C | El SUPERADMIN hace la transferencia completa con un solo formulario. Se registra el movimiento en bitácora con motivo. |

**Tu respuesta:** ___

---

## Sección 5 — Permisos Especiales y Delegación

### SA-P11. ¿Puede el SUPERADMIN "impersonar" a un usuario para depuración?

Si un médico reporta un bug o un problema de acceso, ¿puede el SUPERADMIN
ver el sistema desde su perspectiva?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | No. No existe impersonación. El SUPERADMIN debe reproducir el problema con una cuenta de prueba. |
| B | Sí. El SUPERADMIN puede activar modo "ver como [usuario]" con acceso de solo lectura. Queda registrado en bitácora con `accion = 'IMPERSONACION'`. |

**Tu respuesta:** ___

---

### SA-P12. ¿Cómo funciona la "vista cruzada" que el SUPERADMIN puede delegar? (ADR-002 P12=B)

Si el SUPERADMIN le otorga a un ADMIN_UNIDAD permiso para ver datos de otra unidad:

**Opciones:**

| # | Alcance de la vista cruzada |
|---|---------------------------|
| A | Solo métricas agregadas de la otra unidad (sin datos personales ni expedientes). |
| B | Lista de pacientes de la otra unidad (sin expediente clínico). |
| C | Acceso de lectura igual al que tiene en su propia unidad (incluyendo expedientes). |
| D | El SUPERADMIN define caso por caso qué puede ver: elige entre métricas / lista pacientes / expedientes. |

**Tu respuesta:** ___

---

## Sección 6 — Ciclo de Vida del Sistema

### SA-P13. ¿Cómo se gestionan las cuentas del propio SUPERADMIN?

Si hay múltiples superadmins o si uno se va de la organización:

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Solo puede haber 1 SUPERADMIN activo. El sistema lo valida. |
| B | Puede haber N SUPERADMINs. Cualquiera de ellos puede gestionar a los demás (incluyendo revocar acceso). |
| C | Puede haber N, pero la primera cuenta SUPERADMIN creada (la "raíz") no puede ser revocada por otros SUPERADMINs, solo desde la BD directamente. |

**Tu respuesta:** ___

---

### SA-P14. ¿El SUPERADMIN puede exportar/respaldar datos desde la UI?

Para cumplimiento NOM-024 y auditorías:

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | No. Los respaldos se hacen solo a nivel de BD (pg_dump). La UI no exporta datos. |
| B | Sí, puede exportar reportes en PDF o CSV (bitácora, lista de pacientes por unidad, personal, etc.). |
| C | Sí, exporta reportes Y puede generar un dump de la BD desde la UI (zip con SQL). |

**Tu respuesta:** ___

---

## Resumen de Preguntas

| # | Tema | Respondida |
|---|------|-----------|
| SA-P1 | ¿Cuentas de ADMIN_UNIDAD se activan sin aprobación? | ⬜ |
| SA-P2 | ¿Cuántos ADMIN_UNIDAD por unidad? | ⬜ |
| SA-P3 | ¿SUPERADMIN puede suspender cuentas creadas por admin? | ⬜ |
| SA-P4 | ¿Quién crea los formularios GIIS globales? | ⬜ |
| SA-P5 | ¿Puede marcar normativas como obligatorias? | ⬜ |
| SA-P6 | ¿Puede gestionar catálogo de servicios global? | ⬜ |
| SA-P7 | ¿Qué acceso clínico tiene el SUPERADMIN? | ⬜ |
| SA-P8 | ¿Qué métricas en el dashboard del SUPERADMIN? | ⬜ |
| SA-P9 | ¿Qué pasa al desactivar una unidad? | ⬜ |
| SA-P10 | ¿Puede transferir personal entre unidades? | ⬜ |
| SA-P11 | ¿Puede impersonar usuarios para depuración? | ⬜ |
| SA-P12 | ¿Alcance de la vista cruzada delegada? | ⬜ |
| SA-P13 | ¿Cómo se gestiona la propia cuenta SUPERADMIN? | ⬜ |
| SA-P14 | ¿Puede exportar datos desde la UI? | ⬜ |

---

## Próximos pasos

Una vez respondidas, este documento pasa a **✅ APROBADO** y se actualiza
el módulo de SUPERADMIN (Fase 1) con los ajustes pendientes antes de
iniciar Fase 2.
