import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { adminApi } from '../../api/adminApi.js'
import DataTable from '../../components/UI/DataTable.jsx'
import PageHeader from '../../components/UI/PageHeader.jsx'

const ACCIONES = ['LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE', 'VIEW']

const ACCION_COLORS = {
  LOGIN:  'bg-green-100 text-green-700',
  LOGOUT: 'bg-gray-100 text-gray-600',
  CREATE: 'bg-blue-100 text-blue-700',
  UPDATE: 'bg-amber-100 text-amber-700',
  DELETE: 'bg-red-100 text-red-600',
  VIEW:   'bg-purple-100 text-purple-700',
}

export default function Bitacora() {
  const [page, setPage] = useState(1)
  const [filtros, setFiltros] = useState({ accion: '', tabla: '', desde: '', hasta: '' })
  const [detalle, setDetalle] = useState(null)

  const { data, isLoading } = useQuery({
    queryKey: ['bitacora', page, filtros],
    queryFn: () => adminApi.getBitacora({ page, limit: 50, ...filtros }),
  })

  const columns = [
    {
      key: 'fecha_accion',
      label: 'Fecha y hora',
      render: (row) => (
        <span className="text-xs text-gray-500 whitespace-nowrap">
          {new Date(row.fecha_accion).toLocaleString('es-MX', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit', second: '2-digit',
          })}
        </span>
      ),
    },
    {
      key: 'accion',
      label: 'Acción',
      render: (row) => (
        <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${ACCION_COLORS[row.accion] ?? 'bg-gray-100 text-gray-600'}`}>
          {row.accion}
        </span>
      ),
    },
    { key: 'tabla_afectada', label: 'Tabla' },
    { key: 'registro_id', label: 'ID registro', render: (row) => <span className="text-xs font-mono text-gray-500">{row.registro_id?.slice(0, 12)}...</span> },
    {
      key: 'usuario',
      label: 'Usuario',
      render: (row) => (
        <div>
          <p className="text-xs">{row.usuario_email || 'Sistema'}</p>
          <p className="text-xs text-gray-400">{row.direccion_ip || '—'}</p>
        </div>
      ),
    },
    {
      key: 'datos',
      label: 'Datos',
      render: (row) => (row.datos_nuevos || row.datos_anteriores) ? (
        <button
          onClick={() => setDetalle(row)}
          className="text-xs text-primary-600 hover:text-primary-700 underline"
        >
          Ver detalle
        </button>
      ) : '—',
    },
  ]

  return (
    <div className="p-6">
      <PageHeader
        title="Bitácora de Auditoría"
        subtitle={`${data?.pagination?.total ?? 0} registros · Solo lectura (NOM-024-SSA3)`}
      />

      {/* Filtros */}
      <div className="flex flex-wrap gap-3 mb-4">
        <select
          value={filtros.accion}
          onChange={(e) => { setFiltros(f => ({ ...f, accion: e.target.value })); setPage(1) }}
          className="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 bg-white"
        >
          <option value="">Todas las acciones</option>
          {ACCIONES.map(a => <option key={a} value={a}>{a}</option>)}
        </select>

        <input
          type="text"
          placeholder="Filtrar por tabla..."
          value={filtros.tabla}
          onChange={(e) => { setFiltros(f => ({ ...f, tabla: e.target.value })); setPage(1) }}
          className="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 w-44"
        />

        <input
          type="date"
          value={filtros.desde}
          onChange={(e) => { setFiltros(f => ({ ...f, desde: e.target.value })); setPage(1) }}
          className="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        />
        <span className="self-center text-gray-400 text-sm">a</span>
        <input
          type="date"
          value={filtros.hasta}
          onChange={(e) => { setFiltros(f => ({ ...f, hasta: e.target.value })); setPage(1) }}
          className="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        />

        {(filtros.accion || filtros.tabla || filtros.desde || filtros.hasta) && (
          <button
            onClick={() => { setFiltros({ accion: '', tabla: '', desde: '', hasta: '' }); setPage(1) }}
            className="text-xs text-gray-500 hover:text-gray-700 px-3 py-2"
          >
            Limpiar filtros
          </button>
        )}
      </div>

      <DataTable
        columns={columns}
        data={data?.data ?? []}
        loading={isLoading}
        pagination={data?.pagination}
        onPageChange={setPage}
      />

      {/* Panel de detalle */}
      {detalle && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-black/40" onClick={() => setDetalle(null)} />
          <div className="relative bg-white rounded-2xl shadow-xl w-full max-w-2xl max-h-[80vh] overflow-y-auto">
            <div className="flex items-center justify-between px-6 py-4 border-b">
              <h2 className="font-semibold text-gray-900">Detalle del registro</h2>
              <button onClick={() => setDetalle(null)} className="text-gray-400 hover:text-gray-600 p-1 rounded-lg hover:bg-gray-100">
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <div className="p-6 space-y-4">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div><span className="font-medium text-gray-500">Acción:</span> <span>{detalle.accion}</span></div>
                <div><span className="font-medium text-gray-500">Tabla:</span> <span>{detalle.tabla_afectada}</span></div>
                <div><span className="font-medium text-gray-500">Fecha:</span> <span>{new Date(detalle.fecha_accion).toLocaleString('es-MX')}</span></div>
                <div><span className="font-medium text-gray-500">IP:</span> <span>{detalle.direccion_ip || '—'}</span></div>
                <div className="col-span-2"><span className="font-medium text-gray-500">Usuario:</span> <span>{detalle.usuario_email || 'Sistema'}</span></div>
              </div>

              {detalle.datos_anteriores && (
                <div>
                  <p className="text-xs font-semibold text-gray-500 uppercase mb-1">Datos anteriores</p>
                  <pre className="bg-gray-50 rounded-lg p-3 text-xs overflow-x-auto text-gray-700">
                    {JSON.stringify(detalle.datos_anteriores, null, 2)}
                  </pre>
                </div>
              )}

              {detalle.datos_nuevos && (
                <div>
                  <p className="text-xs font-semibold text-gray-500 uppercase mb-1">Datos nuevos</p>
                  <pre className="bg-green-50 rounded-lg p-3 text-xs overflow-x-auto text-gray-700">
                    {JSON.stringify(detalle.datos_nuevos, null, 2)}
                  </pre>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
