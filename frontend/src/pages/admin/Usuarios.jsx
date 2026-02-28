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

export default function Usuarios() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [modal, setModal] = useState(null)
  const [seleccionado, setSeleccionado] = useState(null)

  const { data, isLoading } = useQuery({
    queryKey: ['usuarios', page, search],
    queryFn: () => adminApi.getUsuarios({ page, limit: 20, search }),
  })

  const { data: rolesData } = useQuery({
    queryKey: ['roles'],
    queryFn: () => catalogosApi.getRoles(),
  })

  const { data: unidadesData } = useQuery({
    queryKey: ['unidades-lista'],
    queryFn: () => adminApi.getUnidades({ limit: 500 }),
  })

  const { data: tiposData } = useQuery({
    queryKey: ['tipos-personal'],
    queryFn: () => catalogosApi.getTiposPersonal(),
  })

  const { register, handleSubmit, reset, watch, formState: { errors, isSubmitting } } = useForm()
  const rolSeleccionado = watch('rol_id')

  // Determinar si el rol requiere datos de personal
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

  function abrirEditar(row) {
    setSeleccionado(row)
    reset({ rol_id: row.rol_id, activo: row.activo })
    setModal('editar')
  }

  function abrirResetPass(row) { setSeleccionado(row); reset(); setModal('reset') }

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
      label: 'Rol',
      render: (row) => (
        <span className="px-2 py-0.5 bg-blue-50 text-blue-700 rounded-full text-xs font-medium">
          {row.rol_clave || '—'}
        </span>
      ),
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
      render: (row) => row.ultimo_acceso
        ? new Date(row.ultimo_acceso).toLocaleString('es-MX')
        : '—',
    },
  ]

  return (
    <div className="p-6">
      <PageHeader
        title="Usuarios del Sistema"
        subtitle={`${data?.pagination?.total ?? 0} usuarios registrados`}
        action={
          <button
            onClick={abrirCrear}
            className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 transition-colors"
          >
            + Nuevo usuario
          </button>
        }
      />

      <div className="mb-4">
        <input
          type="search"
          placeholder="Buscar por nombre, email o CURP..."
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
            <button onClick={() => abrirEditar(row)} className="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded-lg">
              Editar
            </button>
            <button onClick={() => abrirResetPass(row)} className="px-3 py-1 text-xs bg-amber-50 text-amber-700 hover:bg-amber-100 rounded-lg">
              Contraseña
            </button>
            {row.bloqueado_hasta && new Date(row.bloqueado_hasta) > new Date() && (
              <button onClick={() => desbloqueaMutation.mutate(row.id)} className="px-3 py-1 text-xs bg-green-50 text-green-700 hover:bg-green-100 rounded-lg">
                Desbloquear
              </button>
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
              <label className="block text-sm font-medium text-gray-700 mb-1">Rol *</label>
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
              <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider pt-2">Datos de personal de salud</p>
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nombre completo *</label>
                  <input {...register('nombre_completo', { required: requierePersonal ? 'Requerido para este rol' : false })}
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
                    placeholder="Nombre completo" />
                  {errors.nombre_completo && <p className="text-red-500 text-xs mt-1">{errors.nombre_completo.message}</p>}
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
                  <label className="block text-sm font-medium text-gray-700 mb-1">Unidad médica</label>
                  <select {...register('unidad_medica_id')}
                    className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none bg-white">
                    <option value="">Sin unidad asignada</option>
                    {(unidadesData?.data ?? []).map(u => <option key={u.id} value={u.id}>{u.nombre} ({u.clues})</option>)}
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
            <label className="block text-sm font-medium text-gray-700 mb-1">Rol</label>
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
    </div>
  )
}
