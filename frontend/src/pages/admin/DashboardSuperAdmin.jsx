import { useQuery } from '@tanstack/react-query'
import { adminApi } from '../../api/adminApi.js'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'
import markerIconPng from 'leaflet/dist/images/marker-icon.png'
import markerShadowPng from 'leaflet/dist/images/marker-shadow.png'

const markerIcon = new L.Icon({
  iconUrl: markerIconPng,
  shadowUrl: markerShadowPng,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
})

const ROL_COLORES = {
  SUPERADMIN:    'bg-red-100 text-red-800',
  ADMIN_UNIDAD:  'bg-amber-100 text-amber-800',
  MEDICO:        'bg-blue-100 text-blue-800',
  ENFERMERA:     'bg-green-100 text-green-800',
  RECEPCIONISTA: 'bg-purple-100 text-purple-800',
  PACIENTE:      'bg-gray-100 text-gray-700',
}

const ACCION_COLORES = {
  LOGIN:  'bg-purple-100 text-purple-700',
  LOGOUT: 'bg-gray-100 text-gray-600',
  CREATE: 'bg-green-100 text-green-700',
  UPDATE: 'bg-blue-100 text-blue-700',
  DELETE: 'bg-red-100 text-red-700',
  VIEW:   'bg-sky-100 text-sky-700',
}

function StatCard({ label, value, sub, color = 'primary' }) {
  const colors = {
    primary: 'border-primary-200 bg-primary-50',
    green:   'border-green-200 bg-green-50',
    red:     'border-red-200 bg-red-50',
    amber:   'border-amber-200 bg-amber-50',
    blue:    'border-blue-200 bg-blue-50',
  }
  return (
    <div className={`border rounded-xl p-5 ${colors[color]}`}>
      <p className="text-sm text-gray-500 mb-1">{label}</p>
      <p className="text-3xl font-bold text-gray-900">{value ?? '—'}</p>
      {sub && <p className="text-xs text-gray-400 mt-1">{sub}</p>}
    </div>
  )
}

function SeccionTitulo({ children }) {
  return (
    <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-3 mt-6">
      {children}
    </h2>
  )
}

export default function DashboardSuperAdmin() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['dashboard-superadmin'],
    queryFn: adminApi.getDashboard,
    refetchInterval: 60_000, // refresca cada minuto
  })

  const { data: mapaData } = useQuery({
    queryKey: ['unidades-mapa'],
    queryFn: adminApi.getUnidadesMapa,
  })

  const d = data?.data

  if (isLoading) {
    return (
      <div className="p-6 flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }

  if (isError) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl px-5 py-4">
          Error al cargar el dashboard. Verifica la conexión con el servidor.
        </div>
      </div>
    )
  }

  const usuariosBloqueados = d?.usuarios_bloqueados ?? []
  const alertasLogin       = d?.alertas_login ?? []
  const hayAlertas         = usuariosBloqueados.length > 0 || alertasLogin.length > 0

  return (
    <div className="p-6 space-y-2">
      <div className="mb-4">
        <h1 className="text-xl font-bold text-gray-900">Dashboard General</h1>
        <p className="text-sm text-gray-400">
          {new Date().toLocaleDateString('es-MX', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
        </p>
      </div>

      {/* ── Alertas críticas (F, G) ─────────────────────────────── */}
      {hayAlertas && (
        <div className="space-y-2">
          {usuariosBloqueados.length > 0 && (
            <div className="border border-orange-200 bg-orange-50 rounded-xl px-4 py-3 flex items-start gap-3">
              <span className="text-orange-500 text-lg mt-0.5">⚠</span>
              <div>
                <p className="text-sm font-semibold text-orange-800">
                  {usuariosBloqueados.length} usuario{usuariosBloqueados.length > 1 ? 's' : ''} bloqueado{usuariosBloqueados.length > 1 ? 's' : ''}
                </p>
                <p className="text-xs text-orange-600">
                  {usuariosBloqueados.map(u => u.nombre_completo || u.email).join(', ')}
                </p>
              </div>
            </div>
          )}
          {alertasLogin.filter(u => u.intentos_fallidos >= 3).length > 0 && (
            <div className="border border-red-200 bg-red-50 rounded-xl px-4 py-3 flex items-start gap-3">
              <span className="text-red-500 text-lg mt-0.5">⚠</span>
              <div>
                <p className="text-sm font-semibold text-red-800">Alertas de seguridad: intentos de login fallidos</p>
                <p className="text-xs text-red-600">
                  {alertasLogin.filter(u => u.intentos_fallidos >= 3).map(u => `${u.email} (${u.intentos_fallidos} intentos)`).join(' · ')}
                </p>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ── Métricas principales (A, B, C, E) ────────────────────── */}
      <SeccionTitulo>Resumen del sistema</SeccionTitulo>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          label="Unidades habilitadas"
          value={d?.unidades?.activas}
          sub={d?.unidades?.inactivas > 0 ? `${d.unidades.inactivas} en catálogo` : 'Sin unidades inactivas'}
          color="green"
        />
        <StatCard
          label="Pacientes registrados"
          value={d?.pacientes_total}
          color="blue"
        />
        <StatCard
          label="Citas hoy (total)"
          value={d?.citas_hoy_total}
          sub="En todo el sistema"
          color="primary"
        />
        <StatCard
          label="Usuarios bloqueados"
          value={usuariosBloqueados.length}
          sub={usuariosBloqueados.length > 0 ? 'Requieren atención' : 'Sin bloqueos activos'}
          color={usuariosBloqueados.length > 0 ? 'red' : 'green'}
        />
      </div>

      {/* ── Usuarios por rol (B) ──────────────────────────────────── */}
      <SeccionTitulo>Usuarios por rol</SeccionTitulo>
      <div className="flex flex-wrap gap-2">
        {(d?.usuarios_por_rol ?? []).map(r => (
          <div key={r.clave} className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-sm font-medium ${ROL_COLORES[r.clave] ?? 'bg-gray-100 text-gray-700'}`}>
            <span>{r.nombre}</span>
            <span className="font-bold">{r.total}</span>
          </div>
        ))}
      </div>

      {/* ── Mapa de unidades (H) ──────────────────────────────────── */}
      <SeccionTitulo>Mapa de unidades médicas</SeccionTitulo>
      <div className="rounded-xl overflow-hidden border border-gray-200 h-72">
        <MapContainer center={[23.6345, -102.5528]} zoom={5} style={{ height: '100%', width: '100%' }}>
          <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
          {(mapaData?.data ?? []).map((u) => (
            <Marker key={u.id} position={[parseFloat(u.lat), parseFloat(u.lng)]} icon={markerIcon}>
              <Popup>
                <strong>{u.nombre}</strong><br />
                CLUES: {u.clues}<br />
                {u.tipo_unidad}
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>

      {/* ── Dos columnas: citas por unidad (D) + bitácora (I) ──────── */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mt-2">
        {/* D: Citas del día por unidad */}
        <div>
          <SeccionTitulo>Citas hoy por unidad</SeccionTitulo>
          <div className="border border-gray-200 rounded-xl overflow-hidden">
            {(d?.citas_hoy_por_unidad ?? []).length === 0 ? (
              <div className="px-4 py-6 text-center text-sm text-gray-400">Sin citas registradas hoy</div>
            ) : (
              <table className="w-full text-sm">
                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">Unidad</th>
                    <th className="px-4 py-2 text-right text-xs font-medium text-gray-500">Citas</th>
                  </tr>
                </thead>
                <tbody>
                  {(d?.citas_hoy_por_unidad ?? []).map((u, i) => (
                    <tr key={i} className="border-b border-gray-100 last:border-0 hover:bg-gray-50">
                      <td className="px-4 py-2">
                        <p className="font-medium text-gray-900 text-sm">{u.nombre}</p>
                        <p className="text-xs text-gray-400">{u.clues}</p>
                      </td>
                      <td className="px-4 py-2 text-right">
                        <span className="font-bold text-primary-700">{u.citas}</span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>

        {/* I: Bitácora reciente */}
        <div>
          <SeccionTitulo>Actividad reciente (bitácora)</SeccionTitulo>
          <div className="border border-gray-200 rounded-xl overflow-hidden">
            {(d?.bitacora_reciente ?? []).length === 0 ? (
              <div className="px-4 py-6 text-center text-sm text-gray-400">Sin actividad registrada</div>
            ) : (
              <div className="divide-y divide-gray-100 max-h-72 overflow-y-auto">
                {(d?.bitacora_reciente ?? []).map((b) => (
                  <div key={b.id} className="px-4 py-2.5 flex items-start justify-between gap-2">
                    <div className="min-w-0">
                      <p className="text-xs text-gray-900 truncate">{b.usuario_nombre || b.usuario_email || '—'}</p>
                      <p className="text-xs text-gray-400 truncate">{b.tabla_afectada}</p>
                    </div>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <span className={`px-1.5 py-0.5 rounded text-xs font-medium ${ACCION_COLORES[b.accion] ?? 'bg-gray-100 text-gray-600'}`}>
                        {b.accion}
                      </span>
                      <span className="text-xs text-gray-400 whitespace-nowrap">
                        {new Date(b.fecha_accion).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ── Comparativa mensual (J) ────────────────────────────────── */}
      {(d?.comparativa_mensual ?? []).length > 0 && (
        <>
          <SeccionTitulo>Comparativa mensual por unidad</SeccionTitulo>
          <div className="border border-gray-200 rounded-xl overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">Unidad</th>
                  <th className="px-4 py-2 text-right text-xs font-medium text-gray-500">Citas este mes</th>
                </tr>
              </thead>
              <tbody>
                {(d?.comparativa_mensual ?? []).map((u, i) => (
                  <tr key={i} className="border-b border-gray-100 last:border-0 hover:bg-gray-50">
                    <td className="px-4 py-2">
                      <p className="font-medium text-gray-900">{u.nombre}</p>
                      <p className="text-xs text-gray-400">{u.clues}</p>
                    </td>
                    <td className="px-4 py-2 text-right font-bold text-gray-700">{u.citas_mes}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      {/* ── Estado normativas GIIS (K) ─────────────────────────────── */}
      {(d?.giis_adopcion ?? []).length > 0 && (
        <>
          <SeccionTitulo>Estado de normativas GIIS</SeccionTitulo>
          <div className="border border-gray-200 rounded-xl overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">Normativa</th>
                  <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">Versión</th>
                  <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">Estatus</th>
                  <th className="px-4 py-2 text-right text-xs font-medium text-gray-500">Unidades adoptan</th>
                </tr>
              </thead>
              <tbody>
                {(d?.giis_adopcion ?? []).map((n) => {
                  const pct = n.total_unidades_activas > 0
                    ? Math.round((n.unidades_adoptaron / n.total_unidades_activas) * 100)
                    : 0
                  return (
                    <tr key={n.id} className="border-b border-gray-100 last:border-0 hover:bg-gray-50">
                      <td className="px-4 py-2">
                        <p className="font-medium text-gray-900">{n.clave}</p>
                        <p className="text-xs text-gray-400 truncate max-w-xs">{n.nombre_documento}</p>
                      </td>
                      <td className="px-4 py-2 text-xs text-gray-500">{n.version || '—'}</td>
                      <td className="px-4 py-2">
                        <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                          n.estatus === 'ACTIVO' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'
                        }`}>
                          {n.estatus}
                        </span>
                      </td>
                      <td className="px-4 py-2 text-right">
                        <span className="text-sm font-bold text-gray-800">{n.unidades_adoptaron}</span>
                        <span className="text-xs text-gray-400"> / {n.total_unidades_activas}</span>
                        <div className="w-16 ml-auto mt-1 bg-gray-200 rounded-full h-1.5">
                          <div className="bg-primary-500 h-1.5 rounded-full" style={{ width: `${pct}%` }} />
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </>
      )}

      <div className="h-4" />
    </div>
  )
}
