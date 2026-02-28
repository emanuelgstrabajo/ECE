import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { adminApi, catalogosApi } from '../../api/adminApi.js'
import DataTable from '../../components/UI/DataTable.jsx'
import Modal from '../../components/UI/Modal.jsx'
import PageHeader from '../../components/UI/PageHeader.jsx'

function BadgeActivo({ activo }) {
  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
      activo ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-600'
    }`}>
      {activo ? 'Activo' : 'Inactivo'}
    </span>
  )
}

function BadgeBloqueado({ bloqueado_hasta }) {
  if (!bloqueado_hasta || new Date(bloqueado_hasta) < new Date()) return null
  return (
    <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-700 ml-1">
      Bloqueado
    </span>
  )
}

function BadgeRol({ clave }) {
  const colores = {
    SUPERADMIN:    'bg-red-100 text-red-800',
    ADMIN_UNIDAD:  'bg-amber-100 text-amber-800',
    MEDICO:        'bg-blue-100 text-blue-800',
    ENFERMERA:     'bg-green-100 text-green-800',
    RECEPCIONISTA: 'bg-purple-100 text-purple-800',
    PACIENTE:      'bg-gray-100 text-gray-700',
  }
  return (
    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${colores[clave] ?? 'bg-gray-100 text-gray-700'}`}>
      {clave || '—'}
    </span>
  )
}

// ── Panel de asignaciones (adm_usuario_unidad_rol) ────────────────────────────
function PanelAsignaciones({ usuario }) {
  const qc = useQueryClient()
  const [mostrarForm, setMostrarForm] = useState(false)
  const { register, handleSubmit, reset, formState: { isSubmitting } } = useForm()
  const [errorAsig, setErrorAsig] = useState(null)

  const { data: asigData, isLoading } = useQuery({
    queryKey: ['asignaciones', usuario.id],
    queryFn: () => adminApi.getAsignaciones(usuario.id),
    enabled: !!usuario.id,
  })

  const { data: rolesData } = useQuery({
    queryKey: ['roles'],
    queryFn: () => catalogosApi.getRoles(),
  })

  const { data: unidadesData } = useQuery({
    queryKey: ['unidades-lista'],
    queryFn: () => adminApi.getUnidades({ limit: 500 }),
  })

  const crearMut = useMutation({
    mutationFn: (body) => adminApi.crearAsignacion(usuario.id, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['asignaciones', usuario.id] })
      qc.invalidateQueries({ queryKey: ['usuarios'] })
      reset(); setMostrarForm(false); setErrorAsig(null)
    },
    onError: (err) => setErrorAsig(err.response?.data?.error || 'Error al crear asignación'),
  })

  const revocarMut = useMutation({
    mutationFn: ({ asig_id }) =>
      adminApi.revocarAsignacion(usuario.id, asig_id, { motivo_cambio: 'Revocado por administrador' }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['asignaciones', usuario.id] })
      qc.invalidateQueries({ queryKey: ['usuarios'] })
    },
  })

  const asignaciones = asigData?.data ?? []
  const activas   = asignaciones.filter(a => a.activo)
  const historial  = asignaciones.filter(a => !a.activo)
  const rolesOp   = (rolesData?.data ?? []).filter(r => !['SUPERADMIN', 'PACIENTE'].includes(r.clave))
  const unidades  = unidadesData?.data ?? []

  return (
    <div className="space-y-4">
      <div>
        <div className="flex items-center justify-between mb-2">
          <p className="text-sm font-semibold text-gray-700">Asignaciones activas</p>
          <button onClick={() => { setMostrarForm(v => !v); setErrorAsig(null) }}
            className="text-xs px-3 py-1 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors">
            {mostrarForm ? 'Cancelar' : '+ Agregar'}
          </button>
        </div>

        {isLoading ? (
          <p className="text-xs text-gray-400 py-2">Cargando...</p>
        ) : activas.length === 0 ? (
          <p className="text-xs text-gray-400 py-3 text-center border border-dashed border-gray-200 rounded-lg">
            Sin asignaciones activas
          </p>
        ) : (
          <div className="space-y-2">
            {activas.map(a => (
              <div key={a.asignacion_id} className="flex items-center justify-between bg-green-50 border border-green-100 rounded-lg px-3 py-2">
                <div>
                  <p className="text-sm font-medium text-gray-900">{a.unidad_nombre}</p>
                  <p className="text-xs text-gray-500">CLUES: {a.clues} · Desde {new Date(a.fecha_inicio).toLocaleDateString('es-MX')}</p>
                </div>
                <div className="flex items-center gap-2">
                  <BadgeRol clave={a.rol_clave} />
                  <button
                    onClick={() => { if (confirm(`¿Revocar la asignación de ${a.unidad_nombre}?`)) revocarMut.mutate({ asig_id: a.asignacion_id }) }}
                    disabled={revocarMut.isPending}
                    className="text-xs px-2 py-1 bg-red-50 text-red-600 hover:bg-red-100 rounded-lg">
                    Revocar
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {mostrarForm && (
        <form onSubmit={handleSubmit(data => crearMut.mutateAsync(data))}
          className="border border-primary-200 bg-primary-50 rounded-lg p-4 space-y-3">
          <p className="text-xs font-semibold text-primary-700 uppercase tracking-wider">Nueva asignación</p>
          {errorAsig && <div className="bg-red-50 border border-red-200 text-red-700 text-xs rounded-lg px-3 py-2">{errorAsig}</div>}

          <div className="grid grid-cols-2 gap-3">
            <div className="col-span-2">
              <label className="block text-xs font-medium text-gray-700 mb-1">Unidad médica *</label>
              <select {...register('unidad_medica_id', { required: true })}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm bg-white focus:ring-2 focus:ring-primary-500 focus:outline-none">
                <option value="">Seleccionar unidad...</option>
                {unidades.map(u => <option key={u.id} value={u.id}>{u.nombre} ({u.clues})</option>)}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">Rol *</label>
              <select {...register('rol_id', { required: true })}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm bg-white focus:ring-2 focus:ring-primary-500 focus:outline-none">
                <option value="">Seleccionar rol...</option>
                {rolesOp.map(r => <option key={r.id} value={r.id}>{r.nombre}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-700 mb-1">Fecha inicio</label>
              <input type="date" {...register('fecha_inicio')}
                defaultValue={new Date().toISOString().slice(0, 10)}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none" />
            </div>
            <div className="col-span-2">
              <label className="block text-xs font-medium text-gray-700 mb-1">Motivo</label>
              <input {...register('motivo_cambio')} placeholder="Ej. Contratación, Transferencia..."
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none" />
            </div>
          </div>
          <div className="flex justify-end">
            <button type="submit" disabled={isSubmitting}
              className="px-4 py-1.5 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 disabled:opacity-50">
              {isSubmitting ? 'Guardando...' : 'Guardar asignación'}
            </button>
          </div>
        </form>
      )}

      {historial.length > 0 && (
        <details className="mt-2">
          <summary className="text-xs text-gray-500 cursor-pointer select-none hover:text-gray-700">
            Historial ({historial.length} asignaciones cerradas)
          </summary>
          <div className="mt-2 space-y-1">
            {historial.map(a => (
              <div key={a.asignacion_id} className="flex items-center justify-between bg-gray-50 border border-gray-100 rounded-lg px-3 py-2 opacity-70">
                <div>
                  <p className="text-xs font-medium text-gray-600">{a.unidad_nombre}</p>
                  <p className="text-xs text-gray-400">
                    {new Date(a.fecha_inicio).toLocaleDateString('es-MX')} → {a.fecha_fin ? new Date(a.fecha_fin).toLocaleDateString('es-MX') : '—'}
                    {a.motivo_cambio && ` · ${a.motivo_cambio}`}
                  </p>
                </div>
                <BadgeRol clave={a.rol_clave} />
              </div>
            ))}
          </div>
        </details>
      )}
    </div>
  )
}

// ── Página principal ──────────────────────────────────────────────────────────
export default function Usuarios() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [modal, setModal] = useState(null)   // 'crear' | 'editar' | 'reset' | 'asignaciones'
  const [seleccionado, setSeleccionado] = useState(null)

  const { data, isLoading } = useQuery({
    queryKey: ['usuarios', page, search],
    queryFn: () => adminApi.getUsuarios({ page, limit: 20, search }),
  })

  const { data: rolesData } = useQuery({
    queryKey: ['roles'],
    queryFn: () => catalogosApi.getRoles(),
  })

  const { data: tiposData } = useQuery({
    queryKey: ['tipos-personal'],
    queryFn: () => catalogosApi.getTiposPersonal(),
  })

  const { register, handleSubmit, reset, watch, formState: { errors, isSubmitting } } = useForm()
  const rolSeleccionado = watch('rol_id')

  const roles = rolesData?.data ?? []
  const rolObj = roles.find(r => r.id == rolSeleccionado)
  const requierePersonal = rolObj && !['SUPERADMIN'].includes(rolObj.clave)

  const createMutation = useMutation({
    mutationFn: adminApi.createUsuario,
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['usuarios'] }); cerrarModal() },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, ...body }) => adminApi.updateUsuario(id, body),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['usuarios'] }); cerrarModal() },
  })

  const desbloqueaMutation = useMutation({
    mutationFn: adminApi.desbloquear,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['usuarios'] }),
  })

  const resetPassMutation = useMutation({
    mutationFn: ({ id, ...body }) => adminApi.resetPassword(id, body),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['usuarios'] }); cerrarModal() },
  })

  function abrirCrear() { reset(); setModal('crear') }
  function abrirEditar(row) { setSeleccionado(row); reset({ rol_id: row.rol_id, activo: row.activo }); setModal('editar') }
  function abrirResetPass(row) { setSeleccionado(row); reset(); setModal('reset') }
  function abrirAsignaciones(row) { setSeleccionado(row); setModal('asignaciones') }
  function cerrarModal() { setModal(null); setSeleccionado(null); reset() }

  async function onSubmit(values) {
    if (modal === 'crear') await createMutation.mutateAsync(values)
    else if (modal === 'editar') await updateMutation.mutateAsync({ id: seleccionado.id, ...values })
    else if (modal === 'reset') await resetPassMutation.mutateAsync({ id: seleccionado.id, nueva_password: values.nueva_password })
  }

  const errorMsg = createMutation.error?.response?.data?.error
    || updateMutation.error?.response?.data?.error
    || resetPassMutation.error?.response?.data?.error

  const columns = [
    {
      key: 'nombre',
      label: 'Nombre / Email',
      render: (row) => (
        <div>
          <p className="font-medium text-gray-900">{row.nombre_completo || '—'}</p>
          <p className="text-xs text-gray-400">{row.email}</p>
        </div>
      ),
    },
    { key: 'curp', label: 'CURP' },
    {
      key: 'rol',
      label: 'Rol base',
      render: (row) => <BadgeRol clave={row.rol_clave} />,
    },
    {
      key: 'asignaciones',
      label: 'Asignaciones activas',
      render: (row) => {
        const lista = row.asignaciones ?? []
        if (lista.length === 0) return <span className="text-xs text-gray-400">Sin asignar</span>
        return (
          <div className="space-y-0.5">
            {lista.slice(0, 2).map((a, i) => (
              <p key={i} className="text-xs text-gray-600">
                <span className="font-medium">{a.unidad_nombre}</span>
                <span className="text-gray-400"> · {a.rol_clave}</span>
              </p>
            ))}
            {lista.length > 2 && <p className="text-xs text-gray-400">+{lista.length - 2} más</p>}
          </div>
        )
      },
    },
    {
      key: 'activo',
      label: 'Estatus',
      render: (row) => (
        <>
          <BadgeActivo activo={row.activo} />
          <BadgeBloqueado bloqueado_hasta={row.bloqueado_hasta} />
        </>
      ),
    },
    {
      key: 'ultimo_acceso',
      label: 'Último acceso',
      render: (row) => row.ultimo_acceso ? new Date(row.ultimo_acceso).toLocaleString('es-MX') : '—',
    },
  ]

  return (
    <div className="p-6">
      <PageHeader
        title="Usuarios del Sistema"
        subtitle={`${data?.pagination?.total ?? 0} usuarios registrados`}
        action={
          <button onClick={abrirCrear}
            className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 transition-colors">
            + Nuevo usuario
          </button>
        }
      />

      <div className="mb-4">
        <input type="search" placeholder="Buscar por nombre, email o CURP..."
          value={search} onChange={(e) => { setSearch(e.target.value); setPage(1) }}
          className="w-full max-w-sm px-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
      </div>

      <DataTable
        columns={columns}
        data={data?.data ?? []}
        loading={isLoading}
        pagination={data?.pagination}
        onPageChange={setPage}
        actions={(row) => (
          <div className="flex gap-1 justify-end flex-wrap">
            <button onClick={() => abrirEditar(row)} className="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded-lg">Editar</button>
            <button onClick={() => abrirAsignaciones(row)} className="px-3 py-1 text-xs bg-blue-50 text-blue-700 hover:bg-blue-100 rounded-lg">Asignaciones</button>
            <button onClick={() => abrirResetPass(row)} className="px-3 py-1 text-xs bg-amber-50 text-amber-700 hover:bg-amber-100 rounded-lg">Contraseña</button>
            {row.bloqueado_hasta && new Date(row.bloqueado_hasta) > new Date() && (
              <button onClick={() => desbloqueaMutation.mutate(row.id)} className="px-3 py-1 text-xs bg-green-50 text-green-700 hover:bg-green-100 rounded-lg">Desbloquear</button>
            )}
          </div>
        )}
      />

      {/* Modal crear usuario */}
      <Modal isOpen={modal === 'crear'} onClose={cerrarModal} title="Nuevo usuario" size="lg">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {errorMsg && <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">{errorMsg}</div>}

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">CURP *</label>
              <input {...register('curp', { required: 'Requerido', minLength: { value: 18, message: '18 caracteres' } })}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none uppercase"
                placeholder="CURP (18 chars)" maxLength={18} />
              {errors.curp && <p className="text-red-500 text-xs mt-1">{errors.curp.message}</p>}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
              <input {...register('email', { required: 'Requerido' })} type="email"
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
                placeholder="correo@dominio.mx" />
              {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email.message}</p>}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Contraseña inicial *</label>
              <input {...register('password', { required: 'Requerido', minLength: { value: 8, message: 'Mínimo 8 caracteres' } })} type="password"
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
                placeholder="Mínimo 8 caracteres" />
              {errors.password && <p className="text-red-500 text-xs mt-1">{errors.password.message}</p>}
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Rol base *</label>
              <select {...register('rol_id', { required: 'Requerido' })}
                className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none bg-white">
                <option value="">Seleccionar rol...</option>
                {roles.map(r => <option key={r.id} value={r.id}>{r.nombre}</option>)}
              </select>
              {errors.rol_id && <p className="text-red-500 text-xs mt-1">{errors.rol_id.message}</p>}
            </div>
          </div>

          {requierePersonal && (
            <>
              <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider pt-2">Perfil profesional (opcional)</p>
              <p className="text-xs text-gray-400 -mt-2">Las asignaciones a unidades se configuran después con el botón "Asignaciones".</p>
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nombre completo</label>
                  <input {...register('nombre_completo')}
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
                    placeholder="Nombre completo" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tipo de personal</label>
                  <select {...register('tipo_personal_id')}
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none bg-white">
                    <option value="">Seleccionar...</option>
                    {(tiposData?.data ?? []).map(t => <option key={t.id} value={t.id}>{t.descripcion}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Cédula profesional</label>
                  <input {...register('cedula_profesional')}
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
                    placeholder="Opcional" />
                </div>
              </div>
            </>
          )}

          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={cerrarModal} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">Cancelar</button>
            <button type="submit" disabled={isSubmitting} className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 disabled:opacity-50">
              {isSubmitting ? 'Creando...' : 'Crear usuario'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Modal editar usuario */}
      <Modal isOpen={modal === 'editar'} onClose={cerrarModal} title={`Editar: ${seleccionado?.email}`}>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {errorMsg && <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">{errorMsg}</div>}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Rol base</label>
            <select {...register('rol_id')} className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none bg-white">
              {roles.map(r => <option key={r.id} value={r.id}>{r.nombre}</option>)}
            </select>
          </div>
          <div>
            <label className="flex items-center gap-2 text-sm text-gray-700 cursor-pointer">
              <input type="checkbox" {...register('activo')} className="rounded" />
              Usuario activo
            </label>
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={cerrarModal} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">Cancelar</button>
            <button type="submit" disabled={isSubmitting} className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 disabled:opacity-50">
              {isSubmitting ? 'Guardando...' : 'Guardar cambios'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Modal reset contraseña */}
      <Modal isOpen={modal === 'reset'} onClose={cerrarModal} title={`Resetear contraseña: ${seleccionado?.email}`} size="sm">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {errorMsg && <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">{errorMsg}</div>}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Nueva contraseña *</label>
            <input {...register('nueva_password', { required: 'Requerida', minLength: { value: 8, message: 'Mínimo 8 caracteres' } })}
              type="password" className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
              placeholder="Mínimo 8 caracteres" />
            {errors.nueva_password && <p className="text-red-500 text-xs mt-1">{errors.nueva_password.message}</p>}
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={cerrarModal} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">Cancelar</button>
            <button type="submit" disabled={isSubmitting} className="px-4 py-2 bg-amber-600 text-white rounded-lg text-sm hover:bg-amber-700 disabled:opacity-50">
              {isSubmitting ? 'Actualizando...' : 'Cambiar contraseña'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Modal asignaciones usuario ↔ unidad ↔ rol */}
      <Modal isOpen={modal === 'asignaciones'} onClose={cerrarModal}
        title={`Asignaciones: ${seleccionado?.nombre_completo || seleccionado?.email}`} size="lg">
        {seleccionado && <PanelAsignaciones usuario={seleccionado} />}
      </Modal>
    </div>
  )
}
