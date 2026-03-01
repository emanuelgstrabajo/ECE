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

// ── Modal: Deshabilitar unidad ────────────────────────────────────────────────
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

// ── Modal: Administradores de unidad ─────────────────────────────────────────
function ModalAdministradores({ unidad, onClose }) {
  const qc = useQueryClient()
  const [tabForm, setTabForm] = useState('nuevo') // 'nuevo' | 'existente'
  const [busqueda, setBusqueda] = useState('')
  const [usuarioSeleccionado, setUsuarioSeleccionado] = useState(null)
  const [exito, setExito] = useState(null)

  // Formulario: nuevo usuario
  const [formNuevo, setFormNuevo] = useState({
    primer_nombre: '', segundo_nombre: '',
    apellido_paterno: '', apellido_materno: '',
    curp: '', email: '', cedula_profesional: '',
  })

  // Lista de admins actuales
  const { data: adminsData, isLoading: cargandoAdmins } = useQuery({
    queryKey: ['admins-unidad', unidad?.id],
    queryFn: () => adminApi.getAdministradoresUnidad(unidad.id),
    enabled: !!unidad,
  })

  // Búsqueda de usuarios existentes
  const { data: usuariosData, isFetching: buscandoUsuarios } = useQuery({
    queryKey: ['usuarios-busqueda', busqueda],
    queryFn: () => adminApi.getUsuarios({ search: busqueda, limit: 10 }),
    enabled: busqueda.length >= 2,
  })

  const asignarMut = useMutation({
    mutationFn: (body) => adminApi.crearAdministrador(unidad.id, body),
    onSuccess: (res) => {
      qc.invalidateQueries({ queryKey: ['admins-unidad', unidad.id] })
      setExito(res.mensaje)
      setFormNuevo({ primer_nombre: '', segundo_nombre: '', apellido_paterno: '', apellido_materno: '', curp: '', email: '', cedula_profesional: '' })
      setBusqueda('')
      setUsuarioSeleccionado(null)
    },
  })

  const revocarMut = useMutation({
    mutationFn: ({ asig_id }) => adminApi.revocarAdministrador(unidad.id, asig_id, { motivo: 'Revocado por superadmin' }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admins-unidad', unidad.id] }),
  })

  function submitNuevo(e) {
    e.preventDefault()
    setExito(null)
    asignarMut.mutate({ tipo: 'nuevo', ...formNuevo })
  }

  function submitExistente() {
    if (!usuarioSeleccionado) return
    setExito(null)
    asignarMut.mutate({ tipo: 'existente', usuario_id: usuarioSeleccionado.id })
  }

  const admins = adminsData?.data ?? []

  return (
    <Modal isOpen={!!unidad} onClose={onClose} title={`Administradores — ${unidad?.nombre ?? ''}`} size="lg">
      <div className="space-y-5">

        {/* ── Administradores actuales ── */}
        <div>
          <h3 className="text-sm font-semibold text-gray-700 mb-2">
            Administradores actuales
            {admins.length > 0 && (
              <span className="ml-2 text-xs bg-primary-100 text-primary-700 rounded-full px-2 py-0.5">
                {admins.length}
              </span>
            )}
          </h3>

          {cargandoAdmins && (
            <p className="text-sm text-gray-400 italic">Cargando...</p>
          )}

          {!cargandoAdmins && admins.length === 0 && (
            <p className="text-sm text-gray-400 italic py-2">
              Esta unidad aún no tiene administradores asignados.
            </p>
          )}

          {admins.length > 0 && (
            <ul className="divide-y divide-gray-100 border border-gray-100 rounded-xl overflow-hidden">
              {admins.map((a) => (
                <li key={a.asignacion_id} className="flex items-center justify-between px-4 py-2.5 bg-white hover:bg-gray-50">
                  <div>
                    <p className="text-sm font-medium text-gray-800">
                      {a.nombre_completo || <span className="text-gray-400 italic">Sin nombre</span>}
                    </p>
                    <p className="text-xs text-gray-500">{a.email}</p>
                    {a.cedula_profesional && (
                      <p className="text-xs text-gray-400">Cédula: {a.cedula_profesional}</p>
                    )}
                  </div>
                  <button
                    onClick={() => revocarMut.mutate({ asig_id: a.asignacion_id })}
                    disabled={revocarMut.isPending}
                    className="ml-4 px-3 py-1 text-xs text-red-600 bg-red-50 hover:bg-red-100 rounded-lg transition-colors disabled:opacity-50"
                  >
                    Revocar
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        <hr className="border-gray-100" />

        {/* ── Éxito ── */}
        {exito && (
          <div className="bg-green-50 border border-green-200 text-green-800 text-sm rounded-lg px-4 py-3">
            {exito}
          </div>
        )}

        {/* ── Error ── */}
        {asignarMut.error && (
          <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">
            {asignarMut.error?.response?.data?.error || 'Error al asignar administrador'}
          </div>
        )}

        {/* ── Tabs de formulario ── */}
        <div>
          <h3 className="text-sm font-semibold text-gray-700 mb-3">Agregar administrador</h3>

          <div className="flex gap-1 mb-4 border-b border-gray-200">
            {[
              { key: 'nuevo',     label: 'Crear usuario nuevo'   },
              { key: 'existente', label: 'Asignar usuario existente' },
            ].map(({ key, label }) => (
              <button
                key={key}
                onClick={() => { setTabForm(key); setExito(null); asignarMut.reset?.() }}
                className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors -mb-px ${
                  tabForm === key
                    ? 'border-primary-600 text-primary-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                {label}
              </button>
            ))}
          </div>

          {/* ── Tab: Nuevo usuario ── */}
          {tabForm === 'nuevo' && (
            <form onSubmit={submitNuevo} className="space-y-3">
              <div className="grid grid-cols-2 gap-3">
                {/* Nombre(s) — NOM-024 */}
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">Apellido paterno *</label>
                  <input
                    required
                    value={formNuevo.apellido_paterno}
                    onChange={e => setFormNuevo(f => ({ ...f, apellido_paterno: e.target.value }))}
                    placeholder="García"
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">Apellido materno</label>
                  <input
                    value={formNuevo.apellido_materno}
                    onChange={e => setFormNuevo(f => ({ ...f, apellido_materno: e.target.value }))}
                    placeholder="López (opcional)"
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">Nombre(s) *</label>
                  <input
                    required
                    value={formNuevo.primer_nombre}
                    onChange={e => setFormNuevo(f => ({ ...f, primer_nombre: e.target.value }))}
                    placeholder="Carlos"
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">Segundo nombre</label>
                  <input
                    value={formNuevo.segundo_nombre}
                    onChange={e => setFormNuevo(f => ({ ...f, segundo_nombre: e.target.value }))}
                    placeholder="Miguel (opcional)"
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
                {/* Identificación */}
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">CURP *</label>
                  <input
                    required
                    maxLength={18}
                    value={formNuevo.curp}
                    onChange={e => setFormNuevo(f => ({ ...f, curp: e.target.value.toUpperCase() }))}
                    placeholder="ABCD123456HDFXXX00"
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm font-mono uppercase focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">Email *</label>
                  <input
                    required
                    type="email"
                    value={formNuevo.email}
                    onChange={e => setFormNuevo(f => ({ ...f, email: e.target.value }))}
                    placeholder="correo@ejemplo.com"
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">Cédula profesional</label>
                  <input
                    value={formNuevo.cedula_profesional}
                    onChange={e => setFormNuevo(f => ({ ...f, cedula_profesional: e.target.value }))}
                    placeholder="Opcional"
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                  />
                </div>
              </div>
              <p className="text-xs text-gray-400">
                Se generará una contraseña temporal que se enviará al correo indicado.
              </p>
              <div className="flex justify-end">
                <button
                  type="submit"
                  disabled={asignarMut.isPending}
                  className="px-5 py-2 bg-primary-600 text-white text-sm font-medium rounded-lg hover:bg-primary-700 disabled:opacity-50"
                >
                  {asignarMut.isPending ? 'Creando...' : 'Crear y asignar'}
                </button>
              </div>
            </form>
          )}

          {/* ── Tab: Usuario existente ── */}
          {tabForm === 'existente' && (
            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Buscar por nombre, email o CURP
                </label>
                <input
                  value={busqueda}
                  onChange={e => { setBusqueda(e.target.value); setUsuarioSeleccionado(null) }}
                  placeholder="Escribe al menos 2 caracteres..."
                  className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
              </div>

              {buscandoUsuarios && (
                <p className="text-xs text-gray-400 italic">Buscando...</p>
              )}

              {usuariosData?.data?.length > 0 && !usuarioSeleccionado && (
                <ul className="border border-gray-100 rounded-xl overflow-hidden max-h-52 overflow-y-auto divide-y divide-gray-100">
                  {usuariosData.data.map((u) => (
                    <li key={u.id}>
                      <button
                        type="button"
                        onClick={() => setUsuarioSeleccionado(u)}
                        className="w-full text-left px-4 py-2.5 hover:bg-primary-50 transition-colors"
                      >
                        <p className="text-sm font-medium text-gray-800">
                          {u.nombre_completo || <span className="text-gray-400 italic">Sin nombre</span>}
                        </p>
                        <p className="text-xs text-gray-500">{u.email} · {u.curp}</p>
                        {u.rol_nombre && (
                          <span className="text-xs text-gray-400">Rol actual: {u.rol_nombre}</span>
                        )}
                      </button>
                    </li>
                  ))}
                </ul>
              )}

              {busqueda.length >= 2 && !buscandoUsuarios && usuariosData?.data?.length === 0 && (
                <p className="text-xs text-gray-400 italic">No se encontraron usuarios.</p>
              )}

              {usuarioSeleccionado && (
                <div className="border border-primary-200 bg-primary-50 rounded-xl p-3 flex items-center justify-between">
                  <div>
                    <p className="text-sm font-semibold text-primary-800">{usuarioSeleccionado.nombre_completo || usuarioSeleccionado.email}</p>
                    <p className="text-xs text-primary-600">{usuarioSeleccionado.email} · {usuarioSeleccionado.curp}</p>
                  </div>
                  <button
                    onClick={() => setUsuarioSeleccionado(null)}
                    className="ml-4 text-xs text-gray-400 hover:text-gray-600"
                  >
                    Cambiar
                  </button>
                </div>
              )}

              <div className="flex justify-end">
                <button
                  onClick={submitExistente}
                  disabled={!usuarioSeleccionado || asignarMut.isPending}
                  className="px-5 py-2 bg-primary-600 text-white text-sm font-medium rounded-lg hover:bg-primary-700 disabled:opacity-50"
                >
                  {asignarMut.isPending ? 'Asignando...' : 'Asignar como administrador'}
                </button>
              </div>
            </div>
          )}
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
  const [unidadHabilitar, setUnidadHabilitar]   = useState(null)
  const [unidadDesactivar, setUnidadDesactivar] = useState(null)
  const [unidadAdmins, setUnidadAdmins]         = useState(null)

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
    { key: 'clues',  label: 'CLUES',   render: (row) => <span className="font-mono text-sm">{row.clues}</span> },
    { key: 'nombre', label: 'Unidad'   },
    { key: 'tipo_unidad', label: 'Tipo',     render: (row) => row.tipo_unidad || <span className="text-gray-300">—</span> },
    { key: 'entidad',     label: 'Entidad',  render: (row) => row.entidad     || <span className="text-gray-300">—</span> },
    { key: 'municipio',   label: 'Municipio',render: (row) => row.municipio   || <span className="text-gray-300">—</span> },
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
              <>
                <button
                  onClick={() => setUnidadAdmins(row)}
                  className="px-3 py-1 text-xs bg-blue-50 text-blue-700 hover:bg-blue-100 rounded-lg transition-colors"
                >
                  Administradores
                </button>
                <button
                  onClick={() => setUnidadDesactivar(row)}
                  className="px-3 py-1 text-xs bg-red-50 text-red-600 hover:bg-red-100 rounded-lg transition-colors"
                >
                  Deshabilitar
                </button>
              </>
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
      <ModalAdministradores
        unidad={unidadAdmins}
        onClose={() => setUnidadAdmins(null)}
      />
    </div>
  )
}
