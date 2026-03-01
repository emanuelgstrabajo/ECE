import { useQuery } from '@tanstack/react-query'
import { useAuth } from '../../context/AuthContext.jsx'
import { adminUnidadApi } from '../../api/adminUnidadApi.js'
import { Link } from 'react-router-dom'

const ROL_COLOR = {
  MEDICO:         'bg-blue-100 text-blue-800',
  ENFERMERA:      'bg-green-100 text-green-800',
  RECEPCIONISTA:  'bg-yellow-100 text-yellow-800',
  PACIENTE:       'bg-purple-100 text-purple-800',
}

function StatCard({ titulo, valor, sub, color = 'primary' }) {
  const colors = {
    primary: 'bg-primary-50 border-primary-200 text-primary-700',
    green:   'bg-green-50 border-green-200 text-green-700',
    blue:    'bg-blue-50 border-blue-200 text-blue-700',
  }
  return (
    <div className={`rounded-xl border p-5 ${colors[color]}`}>
      <p className="text-sm font-medium opacity-70">{titulo}</p>
      <p className="text-3xl font-bold mt-1">{valor}</p>
      {sub && <p className="text-xs mt-1 opacity-60">{sub}</p>}
    </div>
  )
}

export default function DashboardUnidad() {
  const { usuario } = useAuth()

  const { data, isLoading, isError } = useQuery({
    queryKey: ['dashboard-unidad'],
    queryFn:  adminUnidadApi.getDashboard,
  })

  if (isLoading) {
    return (
      <div className="p-8 flex items-center justify-center min-h-64">
        <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
      </div>
    )
  }

  if (isError) {
    return (
      <div className="p-8">
        <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl p-4">
          Error al cargar el dashboard. Intente de nuevo.
        </div>
      </div>
    )
  }

  const { unidad, personal_activo, personal_por_rol } = data?.data ?? {}

  return (
    <div className="p-6 max-w-5xl mx-auto">
      {/* Encabezado */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">
          {unidad?.nombre ?? 'Mi Unidad'}
        </h1>
        <p className="text-sm text-gray-500 mt-0.5">
          CLUES: <span className="font-mono">{unidad?.clues ?? '—'}</span>
          {' · '}
          Administrador de Unidad
        </p>
      </div>

      {/* Tarjetas de estadísticas */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
        <StatCard
          titulo="Personal activo"
          valor={personal_activo ?? 0}
          sub="asignaciones vigentes"
          color="primary"
        />
        <StatCard
          titulo="Roles activos"
          valor={personal_por_rol?.length ?? 0}
          sub="distintos en la unidad"
          color="blue"
        />
        <StatCard
          titulo="Estado"
          valor={unidad?.activo ? 'Activa' : 'Inactiva'}
          sub={unidad?.activo ? 'Unidad operativa' : 'Unidad suspendida'}
          color="green"
        />
      </div>

      {/* Distribución por rol */}
      {personal_por_rol?.length > 0 && (
        <div className="bg-white rounded-xl border border-gray-200 p-5 mb-8">
          <h2 className="text-sm font-semibold text-gray-700 mb-3">Personal por rol</h2>
          <div className="flex flex-wrap gap-2">
            {personal_por_rol.map(r => (
              <span
                key={r.clave}
                className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-sm font-medium ${ROL_COLOR[r.clave] ?? 'bg-gray-100 text-gray-700'}`}
              >
                {r.nombre}
                <span className="font-bold">{r.total}</span>
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Accesos rápidos */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {[
          {
            to: '/admin-unidad/personal',
            titulo: 'Personal de la Unidad',
            desc: 'Alta, baja y consulta del personal asignado',
            icon: '👨‍⚕️',
          },
          {
            to: '/admin-unidad/servicios',
            titulo: 'Servicios',
            desc: 'Servicios de atención disponibles',
            icon: '🏥',
          },
          {
            to: '/admin-unidad/normativas',
            titulo: 'Normativas',
            desc: 'Normativas NOM-024 y configuración GIIS',
            icon: '📋',
          },
          {
            to: '/admin-unidad/bitacora',
            titulo: 'Bitácora',
            desc: 'Registro de actividad del personal',
            icon: '📝',
          },
        ].map(item => (
          <Link
            key={item.to}
            to={item.to}
            className="bg-white rounded-xl border border-gray-200 p-5 hover:border-primary-400 hover:shadow-sm transition-all flex items-start gap-4"
          >
            <span className="text-3xl">{item.icon}</span>
            <div>
              <p className="font-semibold text-gray-900">{item.titulo}</p>
              <p className="text-sm text-gray-500 mt-0.5">{item.desc}</p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  )
}
