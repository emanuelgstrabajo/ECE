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

// Fix del ícono de marcador en Vite
const markerIcon = new L.Icon({
  iconUrl: markerIconPng,
  shadowUrl: markerShadowPng,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
})

function MapClickHandler({ onCoords }) {
  useMapEvents({
    click(e) {
      onCoords({ lat: e.latlng.lat, lng: e.latlng.lng })
    },
  })
  return null
}

function BadgeActivo({ activo }) {
  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
      activo ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-600'
    }`}>
      {activo ? 'Activa' : 'Inactiva'}
    </span>
  )
}

export default function Unidades() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [modal, setModal] = useState(null) // null | 'crear' | 'editar' | 'mapa'
  const [seleccionado, setSeleccionado] = useState(null)
  const [coords, setCoords] = useState(null)

  const { data, isLoading } = useQuery({
    queryKey: ['unidades', page, search],
    queryFn: () => adminApi.getUnidades({ page, limit: 20, search }),
  })

  const { data: mapaData } = useQuery({
    queryKey: ['unidades-mapa'],
    queryFn: () => adminApi.getUnidadesMapa(),
  })

  const { register, handleSubmit, reset, setValue, formState: { errors, isSubmitting } } = useForm()

  const createMutation = useMutation({
    mutationFn: adminApi.createUnidad,
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['unidades'] }); cerrarModal() },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, ...body }) => adminApi.updateUnidad(id, body),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['unidades'] }); cerrarModal() },
  })

  const deleteMutation = useMutation({
    mutationFn: adminApi.deleteUnidad,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['unidades'] }),
  })

  function abrirCrear() {
    reset(); setCoords(null); setModal('crear')
  }

  function abrirEditar(row) {
    setSeleccionado(row)
    setCoords(row.lat && row.lng ? { lat: row.lat, lng: row.lng } : null)
    reset({
      clues: row.clues,
      nombre: row.nombre,
      tipo_unidad: row.tipo_unidad || '',
      estatus_operacion: row.estatus_operacion || '',
      tiene_espirometro: row.tiene_espirometro,
      es_servicio_amigable: row.es_servicio_amigable,
    })
    setModal('editar')
  }

  function cerrarModal() {
    setModal(null); setSeleccionado(null); setCoords(null); reset()
  }

  async function onSubmit(values) {
    const body = { ...values, lat: coords?.lat, lng: coords?.lng }
    if (modal === 'crear') {
      await createMutation.mutateAsync(body)
    } else {
      await updateMutation.mutateAsync({ id: seleccionado.id, ...body })
    }
  }

  const columns = [
    { key: 'clues', label: 'CLUES' },
    { key: 'nombre', label: 'Nombre' },
    { key: 'tipo_unidad', label: 'Tipo' },
    { key: 'entidad', label: 'Entidad' },
    { key: 'municipio', label: 'Municipio' },
    {
      key: 'activo',
      label: 'Estatus',
      render: (row) => <BadgeActivo activo={row.activo} />,
    },
    {
      key: 'coords',
      label: 'Coords',
      render: (row) => row.lat
        ? <span className="text-xs text-gray-400">{parseFloat(row.lat).toFixed(4)}, {parseFloat(row.lng).toFixed(4)}</span>
        : <span className="text-xs text-gray-300">Sin coords</span>,
    },
  ]

  const errorMsg = createMutation.error?.response?.data?.error
    || updateMutation.error?.response?.data?.error

  return (
    <div className="p-6">
      <PageHeader
        title="Unidades Médicas"
        subtitle={`${data?.pagination?.total ?? 0} unidades registradas`}
        action={
          <div className="flex gap-2">
            <button
              onClick={() => setModal('mapa')}
              className="flex items-center gap-2 px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50 transition-colors"
            >
              🗺 Ver mapa
            </button>
            <button
              onClick={abrirCrear}
              className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 transition-colors"
            >
              + Nueva unidad
            </button>
          </div>
        }
      />

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

      <DataTable
        columns={columns}
        data={data?.data ?? []}
        loading={isLoading}
        pagination={data?.pagination}
        onPageChange={setPage}
        actions={(row) => (
          <div className="flex gap-1 justify-end">
            <button
              onClick={() => abrirEditar(row)}
              className="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
            >
              Editar
            </button>
            {row.activo && (
              <button
                onClick={() => { if (confirm(`¿Desactivar ${row.nombre}?`)) deleteMutation.mutate(row.id) }}
                className="px-3 py-1 text-xs bg-red-50 text-red-600 hover:bg-red-100 rounded-lg transition-colors"
              >
                Desactivar
              </button>
            )}
          </div>
        )}
      />

      {/* Modal crear/editar */}
      <Modal
        isOpen={modal === 'crear' || modal === 'editar'}
        onClose={cerrarModal}
        title={modal === 'crear' ? 'Nueva unidad médica' : `Editar: ${seleccionado?.nombre}`}
        size="lg"
      >
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {errorMsg && (
            <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">
              {errorMsg}
            </div>
          )}

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">CLUES *</label>
              <input
                {...register('clues', { required: 'Requerido' })}
                disabled={modal === 'editar'}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none disabled:bg-gray-50"
                placeholder="Ej. DFIMB000026"
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
              <input
                {...register('tipo_unidad')}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
                placeholder="Ej. Centro de Salud"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Estatus operación</label>
              <input
                {...register('estatus_operacion')}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
                placeholder="Ej. En operación"
              />
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

          {/* Mini mapa para seleccionar coordenadas */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Ubicación en mapa {coords && <span className="text-xs text-green-600 font-normal">— {coords.lat.toFixed(5)}, {coords.lng.toFixed(5)}</span>}
            </label>
            <p className="text-xs text-gray-400 mb-2">Haz clic en el mapa para colocar la ubicación de la unidad</p>
            <div className="rounded-xl overflow-hidden border border-gray-200 h-64">
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
            <button type="button" onClick={cerrarModal} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">
              Cancelar
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 disabled:opacity-50"
            >
              {isSubmitting ? 'Guardando...' : modal === 'crear' ? 'Crear unidad' : 'Guardar cambios'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Modal mapa general */}
      <Modal isOpen={modal === 'mapa'} onClose={cerrarModal} title="Mapa de Unidades Médicas" size="xl">
        <div className="rounded-xl overflow-hidden h-[500px]">
          <MapContainer center={[23.6345, -102.5528]} zoom={5} style={{ height: '100%', width: '100%' }}>
            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
            {(mapaData?.data ?? []).map((u) => (
              <Marker key={u.id} position={[u.lat, u.lng]} icon={markerIcon}>
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
