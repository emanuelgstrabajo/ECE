import { useQuery } from '@tanstack/react-query'
import { adminUnidadApi } from '../../api/adminUnidadApi.js'

export default function ServiciosUnidad() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['servicios-unidad'],
    queryFn:  adminUnidadApi.getServicios,
  })

  const servicios = data?.data ?? []

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Servicios de Atención</h1>
        <p className="text-sm text-gray-500 mt-0.5">Servicios disponibles en la unidad</p>
      </div>

      {isLoading && (
        <div className="flex items-center justify-center p-12">
          <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {isError && (
        <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl p-4">
          Error al cargar los servicios.
        </div>
      )}

      {!isLoading && servicios.length === 0 && (
        <div className="text-center py-12 text-gray-400">
          No hay servicios registrados en el catálogo.
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {servicios.map(s => (
          <div
            key={s.id}
            className="bg-white rounded-xl border border-gray-200 p-4"
          >
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-lg bg-primary-100 flex items-center justify-center flex-shrink-0">
                <svg className="w-4 h-4 text-primary-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p className="font-medium text-gray-900 text-sm">{s.nombre}</p>
                {s.descripcion && (
                  <p className="text-xs text-gray-500 mt-0.5">{s.descripcion}</p>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
