import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { adminUnidadApi } from '../../api/adminUnidadApi.js'

export default function BitacoraUnidad() {
  const [page, setPage] = useState(1)

  const { data, isLoading } = useQuery({
    queryKey: ['bitacora-unidad', page],
    queryFn:  () => adminUnidadApi.getBitacora({ page, limit: 20 }),
    keepPreviousData: true,
  })

  const registros  = data?.data ?? []
  const pagination = data?.pagination ?? {}

  const colorAccion = {
    CREATE: 'bg-green-100 text-green-700',
    UPDATE: 'bg-blue-100 text-blue-700',
    DELETE: 'bg-red-100 text-red-700',
    LOGIN:  'bg-purple-100 text-purple-700',
    LOGOUT: 'bg-gray-100 text-gray-600',
  }

  return (
    <div className="p-6 max-w-5xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Bitácora de Actividad</h1>
        <p className="text-sm text-gray-500 mt-0.5">
          Registro NOM-024 de acciones del personal de la unidad
        </p>
      </div>

      <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
        {isLoading ? (
          <div className="flex items-center justify-center p-12">
            <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : registros.length === 0 ? (
          <div className="text-center py-12 text-gray-400">
            Sin registros de actividad.
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-100">
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Fecha</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Usuario</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Acción</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Tabla</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">IP</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {registros.map(r => (
                <tr key={r.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3 text-xs text-gray-500 whitespace-nowrap">
                    {new Date(r.created_at).toLocaleString('es-MX', {
                      dateStyle: 'short', timeStyle: 'short',
                    })}
                  </td>
                  <td className="px-4 py-3">
                    <p className="font-medium text-gray-900 text-xs">{r.usuario_nombre ?? r.usuario_email ?? '—'}</p>
                    <p className="text-xs text-gray-400">{r.usuario_email}</p>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${colorAccion[r.accion] ?? 'bg-gray-100 text-gray-600'}`}>
                      {r.accion}
                    </span>
                  </td>
                  <td className="px-4 py-3 font-mono text-xs text-gray-500">{r.tabla_afectada}</td>
                  <td className="px-4 py-3 font-mono text-xs text-gray-400">{r.ip_origen ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100 bg-gray-50">
            <p className="text-xs text-gray-500">
              {pagination.total} eventos · página {pagination.page} de {pagination.pages}
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="px-3 py-1 text-xs border border-gray-200 rounded disabled:opacity-40 hover:bg-gray-100"
              >
                Anterior
              </button>
              <button
                onClick={() => setPage(p => Math.min(pagination.pages, p + 1))}
                disabled={page === pagination.pages}
                className="px-3 py-1 text-xs border border-gray-200 rounded disabled:opacity-40 hover:bg-gray-100"
              >
                Siguiente
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
