# SIRES - Registro de Contexto y Cambios para Agentes de IA

Este documento sirve como un log de memoria y contexto técnico para asegurar la continuidad del proyecto SIRES (Sistema de Referencia y Contrarreferencia) entre diferentes sesiones de IA (Claude, Gemini, etc).

## 🏗️ Pila Tecnológica (Stack) Actual
- **Fullstack:** Node.js, Express, React, Vite
- **BD:** PostgreSQL (con PostGIS para entidades geográficas)
- **ORM/Query:** `pg` (consultas crudas SQL)
- **Autenticación:** JWT en cookies HTTP-only (Refesh/Access tokens)
- **Estilos:** TailwindCSS (Diseño minimalista, glassmorphism)

---

## 📝 Registro de Cambios

### [Fase 1B] - Dashboard Super Admin y Catálogo de Unidades
**Fecha:** 28 Feb 2026

#### 1. Arquitectura de Base de Datos
- **Se cambió el modelo:** `adm_unidades_medicas` ahora maneja una columna `activo` (BOOLEAN).
- **Catálogo base:** La tabla tiene ~63,000 registros inactivos provenientes del catálogo oficial CLUES de la Secretaría de Salud.

#### 2. Frontend (Super Admin)
- Se desarrolló el `SuperAdminLayout` que bloquea el acceso a otras rutas (aislando al superadmin).
- La vista principal (`EnableUnitPage.jsx`) cambió la estructura a un diseño **"Tabla Primero"**.
  - Muestra una tabla listando las unidades que ya tienen `activo = true` consumiendo el endpoint `GET /api/admin/unidades`.
- **SearchUnitModal.jsx:**
  - Modal flotante con autocompletado nativo.
  - Se eliminaron los mocks temporales (`superAdminApi.js`).
  - Llama a `adminApi.buscarCatalogoUnidades(q)`, ejecutando `GET /api/admin/unidades/catalogo?q=termino` para traer las clínicas inactivas.
- **ConfirmUnitModal.jsx:**
  - Muestra los datos (Nombre, tipo_unidad, entidad) e invoca `POST /api/admin/unidades/:id/habilitar` para cambiar `activo = true`.

#### 3. Resoluciones Clave
- En el backend, las sentencias SQL en `unidadesController.js` para buscar en el catálogo emplean validaciones `ILIKE` contra nombre o CLUES.
- Al confirmar una habilitación, automáticamente se recarga la tabla de `EnableUnitPage.jsx`.
- **Importante:** Cualquier nueva funcionalidad que implique a las unidades médicas debe corroborar el campo `activo` para evitar procesar clínicas aún no aprobadas por el Super Admin.

- **Gestión de Ciclo de Vida (Tabs):**
  - Implementado sistema de pestañas "Activas" e "Inactivas" para separar el directorio operativo del catálogo deshabilitado.
  - La acción "Deshabilitar" en la tabla ahora realiza un soft-delete (activo=false).
  - La acción "Restaurar/Habilitar" permite recuperar unidades desde la pestaña de Inactivas.
- **Vista Geográfica y Geocodificación:**
  - Integración de `UnitMap.jsx` con Leaflet.
  - Script `geocode_active_units.js` creado para poblar coordenadas faltantes en el catálogo.
  - Geocodificación automática integrada en el flujo de habilitación de nuevas unidades.
- **Estabilización de UI:**
  - Migración total a `react-hot-toast` para notificaciones feedback.
  - Corrección de bugs en el buscador local de la tabla (soporte para CLUES y prevención de crashes).

#### 5. Pendiente para Fase 2
- Delegación de credenciales a administradores locales.
- Implementación de lógica de visibilidad por unidad (multitenancy básico).

---

## 🚀 Instrucciones para Claude Code / Handover
> [!IMPORTANT]
> **Antes de empezar:** Ejecuta `git pull` para obtener los últimos cambios de la Fase 1B (Tabs, Mapas, Fixes de búsqueda).

- **Estado Actual:** El Super Administrador puede habilitar/deshabilitar unidades, ver el mapa nacional y asignar administradores.
- **Buscador de Tabla:** El filtrado es **local** sobre los datos ya cargados en el estado `units`. Si una unidad no aparece al deshabilitarla, verificar que el tab `activeTab` haya cambiado para disparar el nuevo `fetch`.
- **Base de Datos:** Se asume que el usuario tiene acceso a `psql` para verificar el estado de la columna `activo`.
- **Estructura:** Seguir patrones de `adminApi.js` para nuevos endpoints. Las vistas de SA están bajo `/superadmin`.

---

> **Nota para IAs Futuras:** Antes de proponer nuevas integraciones en frontend, siempre verifica los conectores existentes dentro de `src/api` (`adminApi.js`, `authApi.js`, etc) y el cliente configurado en `axiosClient.js` (que maneja intercepción automática del JWT expirado). Para el backend, las rutas base están montadas en `/api` y divididas en `src/routes`.

### ⚠️ REGLA ESTRICTA PARA CUALQUIER IA ⚠️
**CADA VEZ que agregues una funcionalidad nueva al sistema (Frontend o Backend), debes registrarla OBLIGATORIAMENTE en la sección "Registro de Cambios" de este documento (`AI_CONTEXT.md`). No requieres que el usuario te lo pida explícitamente. Mantén este archivo siempre actualizado.**
