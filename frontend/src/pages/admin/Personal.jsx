import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { adminApi, catalogosApi } from '../../api/adminApi.js'
import DataTable from '../../components/UI/DataTable.jsx'
import Modal from '../../components/UI/Modal.jsx'
import PageHeader from '../../components/UI/PageHeader.jsx'

export default function Personal() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [modal, setModal] = useState(null)
  const [seleccionado, setSeleccionado] = useState(null)

  const { data, isLoading } = useQuery({
    queryKey: ['personal', page, search],
    queryFn: () => adminApi.getPersonal({ page, limit: 20, search }),
  })

  const { data: tiposData } = useQuery({
    queryKey: ['tipos-personal'],
    queryFn: () => catalogosApi.getTiposPersonal(),
  })

  const { data: usuariosData } = useQuery({
    queryKey: ['usuarios-lista'],
    queryFn: () => adminApi.getUsuarios({ limit: 500 }),
  })

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm()

  const createMutation = useMutation({
    mutationFn: adminApi.createPersonal,
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['personal'] }); cerrarModal() },
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, ...body }) => adminApi.updatePersonal(id, body),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['personal'] }); cerrarModal() },
  })

  const deleteMutation = useMutation({
    mutationFn: adminApi.deletePersonal,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['personal'] }),
  })

  function abrirCrear() { reset(); setModal('crear') }

  function abrirEditar(row) {
    setSeleccionado(row)
    reset({
      primer_nombre:     row.primer_nombre,
      segundo_nombre:    row.segundo_nombre,
      apellido_paterno:  row.apellido_paterno,
      apellido_materno:  row.apellido_materno,
      tipo_personal_id:  row.tipo_personal_id,
      cedula_profesional: row.cedula_profesional,
    })
    setModal('editar')
  }

  function cerrarModal() { setModal(null); setSeleccionado(null); reset() }

  async function onSubmit(values) {
    if (modal === 'crear') await createMutation.mutateAsync(values)
    else await updateMutation.mutateAsync({ id: seleccionado.id, ...values })
  }

  const errorMsg = createMutation.error?.response?.data?.error
    || updateMutation.error?.response?.data?.error

  const columns = [
    {
      key: 'nombre_completo',
      label: 'Nombre',
      render: (row) => (
        <div>
          <p className="font-medium text-gray-900">{row.nombre_completo}</p>
          {row.cedula_profesional && <p className="text-xs text-gray-400">Ced. {row.cedula_profesional}</p>}
        </div>
      ),
    },
    { key: 'tipo_personal', label: 'Tipo de personal' },
    {
      key: 'asignaciones',
      label: 'Unidades asignadas',
      render: (row) => {
        const lista = row.asignaciones ?? []
        if (lista.length === 0) return <span className="text-gray-400 text-xs">Sin asignar</span>
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
      key: 'usuario',
      label: 'Usuario vinculado',
      render: (row) => row.email
        ? <><p className="text-xs">{row.email}</p><span className={`text-xs ${row.usuario_activo ? 'text-green-600' : 'text-red-500'}`}>{row.usuario_activo ? '● Activo' : '● Inactivo'}</span></>
        : <span className="text-gray-400 text-xs">Sin usuario</span>,
    },
  ]

  const FormModal = (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {errorMsg && <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">{errorMsg}</div>}

      <div className="grid grid-cols-2 gap-4">
        {/* Nombres — NOM-024-SSA3-2010 */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Apellido paterno *</label>
          <input {...register('apellido_paterno', { required: 'Requerido' })}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
            placeholder="García" />
          {errors.apellido_paterno && <p className="text-red-500 text-xs mt-1">{errors.apellido_paterno.message}</p>}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Apellido materno</label>
          <input {...register('apellido_materno')}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
            placeholder="López (opcional)" />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Nombre(s) *</label>
          <input {...register('primer_nombre', { required: 'Requerido' })}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
            placeholder="Carlos" />
          {errors.primer_nombre && <p className="text-red-500 text-xs mt-1">{errors.primer_nombre.message}</p>}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Segundo nombre</label>
          <input {...register('segundo_nombre')}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
            placeholder="Miguel (opcional)" />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Tipo de personal *</label>
          <select {...register('tipo_personal_id', { required: 'Requerido' })}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none bg-white">
            <option value="">Seleccionar...</option>
            {(tiposData?.data ?? []).map(t => <option key={t.id} value={t.id}>{t.descripcion}</option>)}
          </select>
          {errors.tipo_personal_id && <p className="text-red-500 text-xs mt-1">{errors.tipo_personal_id.message}</p>}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Cédula profesional</label>
          <input {...register('cedula_profesional')}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
            placeholder="Opcional" />
        </div>

        {modal === 'crear' && (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Vincular usuario</label>
            <select {...register('usuario_id')}
              className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none bg-white">
              <option value="">Sin usuario</option>
              {(usuariosData?.data ?? [])
                .filter(u => !u.personal_id)
                .map(u => <option key={u.id} value={u.id}>{u.email} — {u.rol_clave}</option>)}
            </select>
          </div>
        )}
      </div>

      <div className="flex justify-end gap-3 pt-2">
        <button type="button" onClick={cerrarModal} className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">Cancelar</button>
        <button type="submit" disabled={isSubmitting} className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 disabled:opacity-50">
          {isSubmitting ? 'Guardando...' : modal === 'crear' ? 'Registrar personal' : 'Guardar cambios'}
        </button>
      </div>
    </form>
  )

  return (
    <div className="p-6">
      <PageHeader
        title="Personal de Salud"
        subtitle={`${data?.pagination?.total ?? 0} registros`}
        action={
          <button onClick={abrirCrear} className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 transition-colors">
            + Registrar personal
          </button>
        }
      />

      <div className="mb-4">
        <input type="search" placeholder="Buscar por nombre o email..."
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
          <div className="flex gap-1 justify-end">
            <button onClick={() => abrirEditar(row)} className="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded-lg">Editar</button>
            <button onClick={() => { if (confirm(`¿Eliminar el registro de ${row.nombre_completo}?`)) deleteMutation.mutate(row.id) }}
              className="px-3 py-1 text-xs bg-red-50 text-red-600 hover:bg-red-100 rounded-lg">
              Eliminar
            </button>
          </div>
        )}
      />

      <Modal isOpen={modal === 'crear'} onClose={cerrarModal} title="Registrar personal de salud" size="lg">{FormModal}</Modal>
      <Modal isOpen={modal === 'editar'} onClose={cerrarModal} title={`Editar: ${seleccionado?.nombre_completo}`} size="lg">{FormModal}</Modal>
    </div>
  )
}
