import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { adminUnidadApi } from '../../api/adminUnidadApi.js'
import { catalogosApi } from '../../api/adminApi.js'
import { useForm } from 'react-hook-form'

const ROL_BADGE = {
  MEDICO:         'bg-blue-100 text-blue-700',
  ENFERMERA:      'bg-green-100 text-green-700',
  RECEPCIONISTA:  'bg-yellow-100 text-yellow-700',
  PACIENTE:       'bg-purple-100 text-purple-700',
}

// ── Modal Alta de Personal ─────────────────────────────────────────
function ModalAlta({ onClose, onSuccess }) {
  const { register, handleSubmit, formState: { errors } } = useForm()
  const queryClient = useQueryClient()

  const { data: rolesData }   = useQuery({ queryKey: ['roles'],        queryFn: catalogosApi.getRoles })
  const { data: tiposData }   = useQuery({ queryKey: ['tipos-personal'], queryFn: catalogosApi.getTiposPersonal })

  const ROLES_OPERATIVOS = ['MEDICO', 'ENFERMERA', 'RECEPCIONISTA']
  const roles   = (rolesData?.data ?? []).filter(r => ROLES_OPERATIVOS.includes(r.clave))
  const tipos   = tiposData?.data ?? []

  const crearMutation = useMutation({
    mutationFn: adminUnidadApi.crearPersonal,
    onSuccess: () => {
      queryClient.invalidateQueries(['personal-unidad'])
      onSuccess?.()
      onClose()
    },
  })

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-lg">
        <div className="p-5 border-b border-gray-100">
          <h2 className="text-lg font-semibold text-gray-900">Alta de Personal</h2>
          <p className="text-sm text-gray-500 mt-0.5">Crea el usuario, perfil y asignación en tu unidad</p>
        </div>

        <form onSubmit={handleSubmit(data => crearMutation.mutate(data))} className="p-5 space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">Email *</label>
              <input
                {...register('email', { required: true })}
                type="email"
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-400"
                placeholder="medico@ejemplo.mx"
              />
              {errors.email && <p className="text-red-500 text-xs mt-0.5">Requerido</p>}
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">CURP *</label>
              <input
                {...register('curp', { required: true, minLength: 18, maxLength: 18 })}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm uppercase focus:outline-none focus:ring-2 focus:ring-primary-400"
                placeholder="XEXX010101HNEXXXA8"
              />
              {errors.curp && <p className="text-red-500 text-xs mt-0.5">CURP de 18 caracteres</p>}
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">Contraseña temporal *</label>
            <input
              {...register('password', { required: true, minLength: 8 })}
              type="password"
              className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-400"
            />
            {errors.password && <p className="text-red-500 text-xs mt-0.5">Mínimo 8 caracteres</p>}
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">Nombre completo *</label>
            <input
              {...register('nombre_completo', { required: true })}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-400"
              placeholder="Apellido Apellido Nombre"
            />
            {errors.nombre_completo && <p className="text-red-500 text-xs mt-0.5">Requerido</p>}
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">Rol *</label>
              <select
                {...register('rol_id', { required: true })}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-400"
              >
                <option value="">Seleccionar...</option>
                {roles.map(r => <option key={r.id} value={r.id}>{r.nombre}</option>)}
              </select>
              {errors.rol_id && <p className="text-red-500 text-xs mt-0.5">Requerido</p>}
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">Tipo de personal *</label>
              <select
                {...register('tipo_personal_id', { required: true })}
                className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-400"
              >
                <option value="">Seleccionar...</option>
                {tipos.map(t => <option key={t.id} value={t.id}>{t.descripcion}</option>)}
              </select>
              {errors.tipo_personal_id && <p className="text-red-500 text-xs mt-0.5">Requerido</p>}
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-700 mb-1">Cédula profesional</label>
            <input
              {...register('cedula_profesional')}
              className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-400"
              placeholder="Opcional"
            />
          </div>

          {crearMutation.isError && (
            <div className="bg-red-50 border border-red-200 text-red-700 rounded-lg p-3 text-sm">
              {crearMutation.error?.response?.data?.error ?? 'Error al crear el personal'}
            </div>
          )}

          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 border border-gray-200 text-gray-700 rounded-lg py-2 text-sm font-medium hover:bg-gray-50 transition-colors"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={crearMutation.isPending}
              className="flex-1 bg-primary-600 text-white rounded-lg py-2 text-sm font-medium hover:bg-primary-700 disabled:opacity-50 transition-colors"
            >
              {crearMutation.isPending ? 'Guardando...' : 'Crear personal'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

// ── Modal Revocar ──────────────────────────────────────────────────
function ModalRevocar({ asignacion, onClose }) {
  const [motivo, setMotivo] = useState('')
  const queryClient = useQueryClient()

  const revocarMutation = useMutation({
    mutationFn: () => adminUnidadApi.revocarPersonal(asignacion.asignacion_id, { motivo_cambio: motivo }),
    onSuccess: () => {
      queryClient.invalidateQueries(['personal-unidad'])
      onClose()
    },
  })

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md p-5">
        <h2 className="text-lg font-semibold text-gray-900 mb-1">Revocar asignación</h2>
        <p className="text-sm text-gray-500 mb-4">
          Se cerrará la asignación de <strong>{asignacion.nombre_completo ?? asignacion.email}</strong>.
          El historial se conserva (NOM-024).
        </p>

        <label className="block text-xs font-medium text-gray-700 mb-1">Motivo del cambio</label>
        <textarea
          value={motivo}
          onChange={e => setMotivo(e.target.value)}
          rows={3}
          className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400 mb-4"
          placeholder="Ej: Baja voluntaria, traslado a otra unidad..."
        />

        {revocarMutation.isError && (
          <div className="bg-red-50 border border-red-200 text-red-700 rounded-lg p-3 text-sm mb-3">
            {revocarMutation.error?.response?.data?.error ?? 'Error al revocar'}
          </div>
        )}

        <div className="flex gap-3">
          <button
            onClick={onClose}
            className="flex-1 border border-gray-200 text-gray-700 rounded-lg py-2 text-sm font-medium hover:bg-gray-50"
          >
            Cancelar
          </button>
          <button
            onClick={() => revocarMutation.mutate()}
            disabled={revocarMutation.isPending}
            className="flex-1 bg-red-600 text-white rounded-lg py-2 text-sm font-medium hover:bg-red-700 disabled:opacity-50"
          >
            {revocarMutation.isPending ? 'Revocando...' : 'Confirmar revocación'}
          </button>
        </div>
      </div>
    </div>
  )
}

// ── Página principal ───────────────────────────────────────────────
export default function PersonalUnidad() {
  const [search, setSearch]       = useState('')
  const [showAlta, setShowAlta]   = useState(false)
  const [revocar, setRevocar]     = useState(null)   // asignación a revocar
  const [page, setPage]           = useState(1)

  const { data, isLoading } = useQuery({
    queryKey: ['personal-unidad', search, page],
    queryFn:  () => adminUnidadApi.getPersonal({ search, page, limit: 20 }),
    keepPreviousData: true,
  })

  const personal    = data?.data ?? []
  const pagination  = data?.pagination ?? {}

  return (
    <div className="p-6 max-w-5xl mx-auto">
      {/* Encabezado */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Personal de la Unidad</h1>
          <p className="text-sm text-gray-500 mt-0.5">Gestiona el personal asignado a tu unidad</p>
        </div>
        <button
          onClick={() => setShowAlta(true)}
          className="bg-primary-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-700 transition-colors"
        >
          + Alta de personal
        </button>
      </div>

      {/* Búsqueda */}
      <div className="mb-4">
        <input
          value={search}
          onChange={e => { setSearch(e.target.value); setPage(1) }}
          placeholder="Buscar por nombre o email..."
          className="w-full max-w-md border border-gray-200 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-400"
        />
      </div>

      {/* Tabla */}
      <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
        {isLoading ? (
          <div className="flex items-center justify-center p-12">
            <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : personal.length === 0 ? (
          <div className="text-center py-12 text-gray-400">
            <p className="text-lg">Sin personal registrado</p>
            <p className="text-sm mt-1">Usa "Alta de personal" para agregar el primero</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-100">
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Personal</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">CURP / Email</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Rol</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Desde</th>
                <th className="px-4 py-3"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {personal.map(p => (
                <tr key={p.asignacion_id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center flex-shrink-0">
                        <span className="text-primary-700 text-xs font-semibold">
                          {(p.nombre_completo ?? p.email)?.[0]?.toUpperCase() ?? '?'}
                        </span>
                      </div>
                      <div>
                        <p className="font-medium text-gray-900">{p.nombre_completo ?? '—'}</p>
                        <p className="text-xs text-gray-400">{p.tipo_personal ?? '—'}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <p className="font-mono text-xs text-gray-500">{p.curp ?? '—'}</p>
                    <p className="text-xs text-gray-400">{p.email}</p>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${ROL_BADGE[p.rol_clave] ?? 'bg-gray-100 text-gray-600'}`}>
                      {p.rol_nombre}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-xs text-gray-500">
                    {p.fecha_inicio ? new Date(p.fecha_inicio).toLocaleDateString('es-MX') : '—'}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <button
                      onClick={() => setRevocar(p)}
                      className="text-xs text-red-500 hover:text-red-700 hover:bg-red-50 px-2 py-1 rounded transition-colors"
                    >
                      Revocar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {/* Paginación */}
        {pagination.pages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-100 bg-gray-50">
            <p className="text-xs text-gray-500">
              {pagination.total} registros · página {pagination.page} de {pagination.pages}
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

      {/* Modales */}
      {showAlta && <ModalAlta onClose={() => setShowAlta(false)} />}
      {revocar   && <ModalRevocar asignacion={revocar} onClose={() => setRevocar(null)} />}
    </div>
  )
}
