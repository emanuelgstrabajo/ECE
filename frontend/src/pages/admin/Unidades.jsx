import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { MapContainer, TileLayer, Marker, Popup, useMapEvents } from 'react-leaflet'
import 'leaflet/dist/leaflet.css'
import L from 'leaflet'
import markerIconPng from 'leaflet/dist/images/marker-icon.png'
import markerShadowPng from 'leaflet/dist/images/marker-shadow.png'
import { adminApi } from '../../api/adminApi.js'
import DataTable from '../../components/UI/DataTable.jsx'
import Modal from '../../components/UI/Modal.jsx'
import PageHeader from '../../components/UI/PageHeader.jsx'

const markerIcon = new L.Icon({
  iconUrl: markerIconPng,
  shadowUrl: markerShadowPng,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
})

function MapClickHandler({ onCoords }) {
  useMapEvents({ click(e) { onCoords({ lat: e.latlng.lat, lng: e.latlng.lng }) } })
  return null
}

// ── Modal: Habilitar unidad desde catálogo ───────────────────────────────────
function ModalHabilitar({ isOpen, onClose }) {
  const qc = useQueryClient()
  const [busqueda, setBusqueda] = useState('')
  const [seleccionada, setSeleccionada] = useState(null)
  const [paso, setPaso] = useState('buscar')

  const { data, isLoading } = useQuery({
    queryKey: ['catalogo-unidades', busqueda],
    queryFn: () => adminApi.buscarCatalogoUnidades(busqueda),
    enabled: busqueda.length >= 2 || busqueda === '',
  })

  const habilitarMut = useMutation({
    mutationFn: () => adminApi.habilitarUnidad(seleccionada.id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['unidades'] })
      qc.invalidateQueries({ queryKey: ['unidades-mapa'] })
      handleClose()
    },
  })

  function handleClose() {
    setBusqueda(''); setSeleccionada(null); setPaso('buscar'); onClose()
  }

  function seleccionar(u) { setSeleccionada(u); setPaso('confirmar') }

  const unidades = data?.data ?? []

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Habilitar unidad médica" size="lg">
      {paso === 'buscar' && (
        <div className="space-y-4">
          <p className="text-sm text-gray-500">
            Busca una unidad del catálogo por CLUES o nombre para habilitarla. Solo aparecen unidades aún no habilitadas.
          </p>
          <input
            type="search"
            placeholder="Buscar por CLUES o nombre de unidad..."
            value={busqueda}
            onChange={(e) => setBusqueda(e.target.value)}
            className="w-full px-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            autoFocus
          />

          {isLoading && (
            <div className="flex justify-center py-6">
              <div className="w-6 h-6 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" />
            </div>
          )}

          {!isLoading && busqueda.length < 2 && (
            <p className="text-center py-6 text-sm text-gray-400">Escribe al menos 2 caracteres para buscar</p>
          )}

          {!isLoading && busqueda.length >= 2 && unidades.length === 0 && (
            <p className="text-center py-8 text-sm text-gray-500">
              No se encontraron unidades con "{busqueda}" en el catálogo.
            </p>
          )}

          {unidades.length > 0 && (
            <div className="space-y-2 max-h-80 overflow-y-auto">
              {unidades.map((u) => (
                <button
                  key={u.id}
                  onClick={() => seleccionar(u)}
                  className="w-full text-left border border-gray-200 rounded-xl px-4 py-3 hover:border-primary-400 hover:bg-primary-50 transition-colors"
                >
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="font-semibold text-gray-900">{u.nombre}</p>
                      <p className="text-xs text-gray-500 mt-0.5">
                        CLUES: <span className="font-mono">{u.clues}</span>
                        {u.tipo_unidad && <span> · {u.tipo_unidad}</span>}
                      </p>
                      {(u.municipio || u.entidad) && (
                        <p className="text-xs text-gray-400">{u.municipio}{u.municipio && u.entidad ? ', ' : ''}{u.entidad}</p>
                      )}
                    </div>
                    <svg className="w-5 h-5 text-primary-400 flex-shrink-0 mt-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {paso === 'confirmar' && seleccionada && (
        <div className="space-y-5">
          <button onClick={() => setPaso('buscar')} className="flex items-center gap-1 text-sm text-gray-500 hover:text-gray-700">
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
            Volver a la búsqueda
          </button>

          <div className="border border-gray-200 rounded-xl p-5 bg-gray-50">
            <h3 className="font-semibold text-gray-900 text-base mb-3">Información de la unidad</h3>
            <dl className="grid grid-cols-2 gap-x-6 gap-y-2 text-sm">
              <div>
                <dt className="text-gray-500 text-xs">CLUES</dt>
                <dd className="font-mono font-semibold text-gray-900">{seleccionada.clues}</dd>
              </div>
              <div>
                <dt className="text-gray-500 text-xs">Tipo de unidad</dt>
                <dd className="text-gray-900">{seleccionada.tipo_unidad || '—'}</dd>
              </div>
              <div className="col-span-2">
                <dt className="text-gray-500 text-xs">Nombre</dt>
                <dd className="text-gray-900 font-medium">{seleccionada.nombre}</dd>
              </div>
              <div>
                <dt className="text-gray-500 text-xs">Municipio</dt>
                <dd className="text-gray-900">{seleccionada.municipio || '—'}</dd>
              </div>
              <div>
                <dt className="text-gray-500 text-xs">Entidad</dt>
                <dd className="text-gray-900">{seleccionada.entidad || '—'}</dd>
              </div>
            </dl>
          </div>

          <div className="border border-amber-200 bg-amber-50 rounded-xl px-4 py-3 text-sm text-amber-800">
            Al habilitar esta unidad, quedará disponible en el sistema para asignar personal y gestionar pacientes.
          </div>

          {habilitarMut.error && (
            <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">
              {habilitarMut.error?.response?.data?.error || 'Error al habilitar la unidad'}
            </div>
          )}

          <div className="flex justify-end gap-3">
            <button onClick={() => setPaso('buscar')} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">
              Cancelar
            </button>
            <button
              onClick={() => habilitarMut.mutate()}
              disabled={habilitarMut.isPending}
              className="px-5 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700 disabled:opacity-50"
            >
              {habilitarMut.isPending ? 'Habilitando...' : 'Confirmar habilitación'}
            </button>
          </div>
        </div>
      )}
    </Modal>
  )
}

// ── Modal: Registrar unidad nueva en catálogo ────────────────────────────────
function ModalRegistrarCatalogo({ isOpen, onClose }) {
  const qc = useQueryClient()
  const [coords, setCoords] = useState(null)
  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm()

  function handleClose() { reset(); setCoords(null); onClose() }

  const createMutation = useMutation({
    mutationFn: adminApi.createUnidad,
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['catalogo-unidades'] }); handleClose() },
  })

  async function onSubmit(values) {
    await createMutation.mutateAsync({ ...values, lat: coords?.lat, lng: coords?.lng, activo: false })
  }

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Registrar unidad en catálogo" size="lg">
      <p className="text-sm text-gray-500 mb-4">
        Registra una nueva unidad médica en el catálogo. Después podrás habilitarla desde la pestaña "Deshabilitadas".
      </p>
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        {createMutation.error && (
          <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">
            {createMutation.error?.response?.data?.error}
          </div>
        )}

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">CLUES *</label>
            <input
              {...register('clues', { required: 'Requerido', maxLength: { value: 11, message: 'Máximo 11 caracteres' } })}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none uppercase"
              placeholder="Ej. DFIMB000026"
              maxLength={11}
            />
            {errors.clues && <p className="text-red-500 text-xs mt-1">{errors.clues.message}</p>}
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Nombre *</label>
            <input
              {...register('nombre', { required: 'Requerido' })}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
              placeholder="Nombre de la unidad"
            />
            {errors.nombre && <p className="text-red-500 text-xs mt-1">{errors.nombre.message}</p>}
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Tipo de unidad</label>
            <input {...register('tipo_unidad')}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
              placeholder="Ej. Centro de Salud" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Estatus de operación</label>
            <input {...register('estatus_operacion')}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
              placeholder="Ej. En operación" />
          </div>
        </div>

        <div className="flex gap-6">
          <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
            <input type="checkbox" {...register('tiene_espirometro')} className="rounded" />
            Tiene espirómetro
          </label>
          <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
            <input type="checkbox" {...register('es_servicio_amigable')} className="rounded" />
            Servicio amigable
          </label>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Ubicación en mapa {coords && <span className="text-xs text-green-600 font-normal">— {coords.lat.toFixed(5)}, {coords.lng.toFixed(5)}</span>}
          </label>
          <p className="text-xs text-gray-400 mb-2">Haz clic en el mapa para colocar la ubicación</p>
          <div className="rounded-xl overflow-hidden border border-gray-200 h-52">
            <MapContainer
              center={coords ? [coords.lat, coords.lng] : [19.4326, -99.1332]}
              zoom={coords ? 14 : 5}
              style={{ height: '100%', width: '100%' }}
            >
              <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
              <MapClickHandler onCoords={setCoords} />
              {coords && <Marker position={[coords.lat, coords.lng]} icon={markerIcon} />}
            </MapContainer>
          </div>
        </div>

        <div className="flex justify-end gap-3 pt-2">
          <button type="button" onClick={handleClose} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">
            Cancelar
          </button>
          <button type="submit" disabled={isSubmitting}
            className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 disabled:opacity-50">
            {isSubmitting ? 'Registrando...' : 'Registrar en catálogo'}
          </button>
        </div>
      </form>
    </Modal>
  )
}

// ── Modal: Desactivar unidad con confirmación ─────────────────────────────────
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

// ── Página principal ─────────────────────────────────────────────────────────
export default function Unidades() {
  const qc = useQueryClient()
  const [tab, setTab] = useState('habilitadas')
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [modalHabilitar, setModalHabilitar] = useState(false)
  const [modalRegistrar, setModalRegistrar] = useState(false)
  const [modalMapa, setModalMapa] = useState(false)
  const [unidadDesactivar, setUnidadDesactivar] = useState(null)

  const activo = tab === 'habilitadas'

  const { data, isLoading } = useQuery({
    queryKey: ['unidades', tab, page, search],
    queryFn: () => adminApi.getUnidades({ page, limit: 20, search, activo }),
  })

  const { data: mapaData } = useQuery({
    queryKey: ['unidades-mapa'],
    queryFn: adminApi.getUnidadesMapa,
  })

  const habilitarMut = useMutation({
    mutationFn: (id) => adminApi.habilitarUnidad(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['unidades'] })
      qc.invalidateQueries({ queryKey: ['unidades-mapa'] })
    },
  })

  function cambiarTab(nuevaTab) {
    setTab(nuevaTab)
    setPage(1)
    setSearch('')
  }

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

  const total = data?.pagination?.total ?? 0

  return (
    <div className="p-6">
      <PageHeader
        title="Unidades Médicas"
        subtitle={`${total} unidad${total !== 1 ? 'es' : ''} ${tab}`}
        action={
          <div className="flex gap-2">
            <button
              onClick={() => setModalMapa(true)}
              className="flex items-center gap-2 px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50 transition-colors"
            >
              <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                  d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
              </svg>
              Ver mapa
            </button>
            <button
              onClick={() => setModalRegistrar(true)}
              className="flex items-center gap-2 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg text-sm hover:bg-gray-50 transition-colors"
            >
              + Registrar en catálogo
            </button>
            <button
              onClick={() => setModalHabilitar(true)}
              className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 transition-colors"
            >
              + Habilitar unidad
            </button>
          </div>
        }
      />

      {/* ── Pestañas ── */}
      <div className="flex gap-1 mb-5 border-b border-gray-200">
        {[
          { key: 'habilitadas', label: 'Habilitadas' },
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

      {/* ── Buscador ── */}
      <div className="mb-4">
        <input
          type="search"
          placeholder="Buscar por nombre o CLUES..."
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1) }}
          className="w-full max-w-sm px-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        />
      </div>

      {/* ── Tabla ── */}
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
                onClick={() => habilitarMut.mutate(row.id)}
                disabled={habilitarMut.isPending}
                className="px-3 py-1 text-xs bg-green-50 text-green-700 hover:bg-green-100 rounded-lg transition-colors disabled:opacity-50"
              >
                {habilitarMut.isPending ? '...' : 'Habilitar'}
              </button>
            )}
          </div>
        )}
      />

      {/* Modales */}
      <ModalHabilitar isOpen={modalHabilitar} onClose={() => setModalHabilitar(false)} />
      <ModalRegistrarCatalogo isOpen={modalRegistrar} onClose={() => setModalRegistrar(false)} />
      <ModalDesactivar unidad={unidadDesactivar} onClose={() => setUnidadDesactivar(null)} />

      {/* Modal mapa global */}
      <Modal isOpen={modalMapa} onClose={() => setModalMapa(false)} title="Mapa de Unidades Médicas" size="xl">
        <div className="rounded-xl overflow-hidden h-[500px]">
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
      </Modal>
    </div>
  )
}
