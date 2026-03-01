import { useQuery } from '@tanstack/react-query'
import { adminUnidadApi } from '../../api/adminUnidadApi.js'

export default function NormativasUnidad() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ['normativas-unidad'],
    queryFn:  adminUnidadApi.getNormativas,
  })

  const normativas = data?.data ?? []

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Normativas GIIS</h1>
        <p className="text-sm text-gray-500 mt-0.5">
          Normativas activas del sistema (NOM-024-SSA3-2010)
        </p>
      </div>

      {isLoading && (
        <div className="flex items-center justify-center p-12">
          <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
        </div>
      )}

      {isError && (
        <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl p-4">
          Error al cargar las normativas.
        </div>
      )}

      {!isLoading && normativas.length === 0 && (
        <div className="text-center py-12 text-gray-400">
          No hay normativas configuradas.
        </div>
      )}

      <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-gray-50 border-b border-gray-100">
              <th className="text-left px-4 py-3 font-semibold text-gray-600">Clave</th>
              <th className="text-left px-4 py-3 font-semibold text-gray-600">Nombre</th>
              <th className="text-left px-4 py-3 font-semibold text-gray-600">Versión</th>
              <th className="text-left px-4 py-3 font-semibold text-gray-600">Opciones</th>
              <th className="text-left px-4 py-3 font-semibold text-gray-600">Estado</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {normativas.map(n => (
              <tr key={n.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 font-mono text-xs text-gray-600">{n.clave}</td>
                <td className="px-4 py-3 font-medium text-gray-900">{n.nombre}</td>
                <td className="px-4 py-3 text-gray-500">{n.version ?? '—'}</td>
                <td className="px-4 py-3 text-gray-500">{n.opciones_adoptadas}</td>
                <td className="px-4 py-3">
                  <span className={`inline-block px-2 py-0.5 rounded-full text-xs font-medium ${
                    n.activa ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'
                  }`}>
                    {n.activa ? 'Activa' : 'Inactiva'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
