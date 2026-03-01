import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminApi } from '../../api/adminApi.js'
import DataTable from '../../components/UI/DataTable.jsx'
import Modal from '../../components/UI/Modal.jsx'
import PageHeader from '../../components/UI/PageHeader.jsx'

// ── Modal: Confirmar habilitación ─────────────────────────────────────────────
function ModalConfirmarHabilitar({ unidad, onClose }) {
  const qc = useQueryClient()

  const habilitarMut = useMutation({
    mutationFn: () => adminApi.habilitarUnidad(unidad.id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['unidades'] })
      qc.invalidateQueries({ queryKey: ['unidades-mapa'] })
      onClose()
    },
  })

  return (
    <Modal isOpen={!!unidad} onClose={onClose} title="Habilitar unidad médica" size="sm">
      <div className="space-y-4">
        <div className="border border-green-200 bg-green-50 rounded-xl p-4">
          <p className="text-sm font-semibold text-green-800">{unidad?.nombre}</p>
          <p className="text-xs text-green-600">CLUES: {unidad?.clues}</p>
          {unidad?.tipo_unidad && <p className="text-xs text-green-600">{unidad.tipo_unidad}</p>}
        </div>

        <div className="text-sm text-gray-600">
          Al habilitar esta unidad:
          <ul className="list-disc list-inside mt-1 text-xs text-gray-500 space-y-0.5">
            <li>Quedará disponible en el sistema operativo</li>
            <li>Se podrá asignar personal y gestionar pacientes</li>
            <li>Puedes deshabilitarla de nuevo en cualquier momento</li>
          </ul>
        </div>

        {habilitarMut.error && (
          <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-3 py-2">
            {habilitarMut.error?.response?.data?.error || 'Error al habilitar la unidad'}
          </div>
        )}

        <div className="flex justify-end gap-3">
          <button onClick={onClose} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">
            Cancelar
          </button>
          <button
            onClick={() => habilitarMut.mutate()}
            disabled={habilitarMut.isPending}
            className="px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700 disabled:opacity-50"
          >
            {habilitarMut.isPending ? 'Habilitando...' : 'Confirmar habilitación'}
          </button>
        </div>
      </div>
    </Modal>
  )
}

// ── Modal: Deshabilitar unidad con confirmación ───────────────────────────────
function ModalDesactivar({ unidad, onClose }) {
  const qc = useQueryClient()
  const [motivo, setMotivo] = useState('')

  const desactivarMut = useMutation({
    mutationFn: () => adminApi.deleteUnidad(unidad.id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['unidades'] })
      onClose()
    },
  })

  return (
    <Modal isOpen={!!unidad} onClose={onClose} title="Deshabilitar unidad médica" size="sm">
      <div className="space-y-4">
        <div className="border border-red-200 bg-red-50 rounded-xl p-4">
          <p className="text-sm font-semibold text-red-800">{unidad?.nombre}</p>
          <p className="text-xs text-red-600">CLUES: {unidad?.clues}</p>
        </div>
        <div className="text-sm text-gray-600">
          Al deshabilitar esta unidad:
          <ul className="list-disc list-inside mt-1 text-xs text-gray-500 space-y-0.5">
            <li>El personal asignado perderá acceso</li>
            <li>Pasará a la pestaña "Deshabilitadas" — no se elimina</li>
            <li>Puedes volver a habilitarla en cualquier momento</li>
            <li>El historial de datos se preserva (NOM-024)</li>
          </ul>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Motivo (recomendado)</label>
          <input
            value={motivo}
            onChange={e => setMotivo(e.target.value)}
            placeholder="Ej. Cierre temporal, remodelación..."
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-red-500 focus:outline-none"
          />
        </div>
        {desactivarMut.error && (
          <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-3 py-2">
            {desactivarMut.error?.response?.data?.error}
          </div>
        )}
        <div className="flex justify-end gap-3">
          <button onClick={onClose} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">
            Cancelar
          </button>
          <button
            onClick={() => desactivarMut.mutate()}
            disabled={desactivarMut.isPending}
            className="px-4 py-2 bg-red-600 text-white rounded-lg text-sm hover:bg-red-700 disabled:opacity-50"
          >
            {desactivarMut.isPending ? 'Deshabilitando...' : 'Deshabilitar unidad'}
          </button>
        </div>
      </div>
    </Modal>
  )
}

// ── Página principal ──────────────────────────────────────────────────────────
export default function Unidades() {
  const [tab, setTab] = useState('habilitadas')
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [unidadHabilitar, setUnidadHabilitar] = useState(null)
  const [unidadDesactivar, setUnidadDesactivar] = useState(null)

  const activo = tab === 'habilitadas'

  const { data, isLoading } = useQuery({
    queryKey: ['unidades', tab, page, search],
    queryFn: () => adminApi.getUnidades({ page, limit: 20, search, activo }),
  })

  function cambiarTab(nuevaTab) {
    setTab(nuevaTab)
    setPage(1)
    setSearch('')
  }

  const total = data?.pagination?.total ?? 0

  const columns = [
    { key: 'clues', label: 'CLUES', render: (row) => <span className="font-mono text-sm">{row.clues}</span> },
    { key: 'nombre', label: 'Unidad' },
    { key: 'tipo_unidad', label: 'Tipo', render: (row) => row.tipo_unidad || <span className="text-gray-300">—</span> },
    { key: 'entidad', label: 'Entidad', render: (row) => row.entidad || <span className="text-gray-300">—</span> },
    { key: 'municipio', label: 'Municipio', render: (row) => row.municipio || <span className="text-gray-300">—</span> },
    {
      key: 'coords',
      label: 'Coords',
      render: (row) => row.lat
        ? <span className="text-xs text-gray-400 font-mono">{parseFloat(row.lat).toFixed(3)}, {parseFloat(row.lng).toFixed(3)}</span>
        : <span className="text-xs text-gray-300">Sin coords</span>,
    },
  ]

  return (
    <div className="p-6">
      <PageHeader
        title="Unidades Médicas"
        subtitle={`${total} unidad${total !== 1 ? 'es' : ''} ${tab}`}
      />

      {/* Pestañas */}
      <div className="flex gap-1 mb-5 border-b border-gray-200">
        {[
          { key: 'habilitadas',    label: 'Habilitadas'    },
          { key: 'deshabilitadas', label: 'Deshabilitadas' },
        ].map(({ key, label }) => (
          <button
            key={key}
            onClick={() => cambiarTab(key)}
            className={`px-5 py-2.5 text-sm font-medium border-b-2 transition-colors -mb-px ${
              tab === key
                ? 'border-primary-600 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {/* Buscador */}
      <div className="mb-4">
        <input
          type="search"
          placeholder="Buscar por nombre o CLUES..."
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1) }}
          className="w-full max-w-sm px-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        />
      </div>

      {/* Tabla */}
      <DataTable
        columns={columns}
        data={data?.data ?? []}
        loading={isLoading}
        pagination={data?.pagination}
        onPageChange={setPage}
        actions={(row) => (
          <div className="flex gap-1 justify-end">
            {tab === 'habilitadas' && (
              <button
                onClick={() => setUnidadDesactivar(row)}
                className="px-3 py-1 text-xs bg-red-50 text-red-600 hover:bg-red-100 rounded-lg transition-colors"
              >
                Deshabilitar
              </button>
            )}
            {tab === 'deshabilitadas' && (
              <button
                onClick={() => setUnidadHabilitar(row)}
                className="px-3 py-1 text-xs bg-green-50 text-green-700 hover:bg-green-100 rounded-lg transition-colors"
              >
                Habilitar
              </button>
            )}
          </div>
        )}
      />

      <ModalConfirmarHabilitar
        unidad={unidadHabilitar}
        onClose={() => setUnidadHabilitar(null)}
      />
      <ModalDesactivar
        unidad={unidadDesactivar}
        onClose={() => setUnidadDesactivar(null)}
      />
    </div>
  )
}
