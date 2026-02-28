import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { adminApi, catalogosApi } from '../../api/adminApi.js'
import Modal from '../../components/UI/Modal.jsx'
import PageHeader from '../../components/UI/PageHeader.jsx'

// ── Badge helpers ─────────────────────────────────────────────────────────────
function BadgeEstatus({ estatus }) {
  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
      estatus === 'ACTIVO' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'
    }`}>
      {estatus}
    </span>
  )
}

// ── Formulario de creación / edición GIIS ─────────────────────────────────────
function FormGiis({ giis, onSuccess, onCancel }) {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm({
    defaultValues: giis
      ? {
          nombre_documento: giis.nombre_documento,
          version: giis.version || '',
          fecha_publicacion: giis.fecha_publicacion?.slice(0, 10) || '',
          url_pdf: giis.url_pdf || '',
          estatus: giis.estatus || 'ACTIVO',
        }
      : { estatus: 'ACTIVO' },
  })

  const qc = useQueryClient()

  const crearMut = useMutation({
    mutationFn: adminApi.createGiis,
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['giis'] }); onSuccess() },
  })

  const actualizarMut = useMutation({
    mutationFn: (body) => adminApi.updateGiis(giis.id, body),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['giis'] }); onSuccess() },
  })

  const error = crearMut.error?.response?.data?.error || actualizarMut.error?.response?.data?.error

  async function onSubmit(values) {
    if (giis) await actualizarMut.mutateAsync(values)
    else await crearMut.mutateAsync(values)
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">{error}</div>
      )}

      {!giis && (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Clave *</label>
          <input
            {...register('clave', { required: 'Requerido' })}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none uppercase"
            placeholder="Ej. NOM-024"
          />
          {errors.clave && <p className="text-red-500 text-xs mt-1">{errors.clave.message}</p>}
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Nombre del documento *</label>
        <input
          {...register('nombre_documento', { required: 'Requerido' })}
          className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
          placeholder="Ej. Norma Oficial Mexicana NOM-024-SSA3-2010"
        />
        {errors.nombre_documento && <p className="text-red-500 text-xs mt-1">{errors.nombre_documento.message}</p>}
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Versión</label>
          <input
            {...register('version')}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
            placeholder="Ej. 2010, 2.1"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Fecha de publicación</label>
          <input
            type="date"
            {...register('fecha_publicacion')}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">URL del PDF (opcional)</label>
        <input
          {...register('url_pdf')}
          type="url"
          className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:outline-none"
          placeholder="https://dof.gob.mx/..."
        />
      </div>

      {giis && (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Estatus</label>
          <select
            {...register('estatus')}
            className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm bg-white focus:ring-2 focus:ring-primary-500 focus:outline-none"
          >
            <option value="ACTIVO">ACTIVO</option>
            <option value="INACTIVO">INACTIVO</option>
          </select>
        </div>
      )}

      <div className="flex justify-end gap-3 pt-2">
        <button type="button" onClick={onCancel}
          className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-700 hover:bg-gray-50">
          Cancelar
        </button>
        <button type="submit" disabled={isSubmitting}
          className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 disabled:opacity-50">
          {isSubmitting ? 'Guardando...' : giis ? 'Guardar cambios' : 'Crear normativa'}
        </button>
      </div>
    </form>
  )
}

// ── Sección de catálogos de referencia ────────────────────────────────────────
const CATALOGOS_REFERENCIA = [
  {
    clave: 'cat_roles',
    nombre: 'Roles del sistema (RBAC)',
    descripcion: 'SUPERADMIN, ADMIN_UNIDAD, MEDICO, ENFERMERA, RECEPCIONISTA, PACIENTE',
    editable: false,
    icono: '🔐',
  },
  {
    clave: 'cat_tipos_personal',
    nombre: 'Tipos de personal de salud',
    descripcion: 'Clasificación del personal médico',
    editable: false,
    icono: '👨‍⚕️',
  },
  {
    clave: 'cat_cie10',
    nombre: 'CIE-10 — Diagnósticos',
    descripcion: 'Clasificación Internacional de Enfermedades, 10ª revisión',
    editable: false,
    importacion: true,
    icono: '🏥',
  },
  {
    clave: 'cat_cie9',
    nombre: 'CIE-9 — Procedimientos',
    descripcion: 'Clasificación Internacional de Procedimientos',
    editable: false,
    importacion: true,
    icono: '🩺',
  },
  {
    clave: 'cat_servicios_atencion',
    nombre: 'Servicios de atención',
    descripcion: 'Tipos de servicios que pueden ofrecer las unidades médicas',
    editable: true,
    icono: '🏨',
  },
  {
    clave: 'gui_diccionarios',
    nombre: 'Diccionarios de interfaz (GUI)',
    descripcion: 'Catálogos de opciones para formularios GIIS',
    editable: false,
    icono: '📋',
  },
  {
    clave: 'cat_sepomex',
    nombre: 'Geografía SEPOMEX',
    descripcion: 'Entidades, municipios y códigos postales de México',
    editable: false,
    importacion: true,
    icono: '🗺',
  },
]

// ── Página principal ──────────────────────────────────────────────────────────
export default function Catalogos() {
  const qc = useQueryClient()
  const [tab, setTab] = useState('giis') // 'giis' | 'catalogos'
  const [modal, setModal] = useState(null) // null | 'crear' | 'editar'
  const [giisSeleccionado, setGiisSeleccionado] = useState(null)
  const [giisVerCampos, setGiisVerCampos] = useState(null)

  const { data: giisData, isLoading: giisLoading } = useQuery({
    queryKey: ['giis'],
    queryFn: adminApi.getGiis,
  })

  const { data: camposData, isLoading: camposLoading } = useQuery({
    queryKey: ['giis-campos', giisVerCampos?.id],
    queryFn: () => adminApi.getCamposGiis(giisVerCampos.id),
    enabled: !!giisVerCampos?.id,
  })

  const cambiarEstatusMut = useMutation({
    mutationFn: ({ id, estatus }) => adminApi.cambiarEstatusGiis(id, estatus),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['giis'] }),
  })

  const normativas = giisData?.data ?? []

  function abrirEditar(n) { setGiisSeleccionado(n); setModal('editar') }
  function cerrarModal() { setModal(null); setGiisSeleccionado(null) }

  return (
    <div className="p-6">
      <PageHeader
        title="Catálogos & GIIS"
        subtitle="Gestión de normativas GIIS y catálogos del sistema"
        action={tab === 'giis' && (
          <button
            onClick={() => setModal('crear')}
            className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700 transition-colors"
          >
            + Nueva normativa GIIS
          </button>
        )}
      />

      {/* Tabs */}
      <div className="flex border-b border-gray-200 mb-6">
        {[
          { id: 'giis', label: 'Normativas GIIS' },
          { id: 'catalogos', label: 'Catálogos del sistema' },
        ].map(t => (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            className={`px-5 py-2.5 text-sm font-medium border-b-2 -mb-px transition-colors ${
              tab === t.id
                ? 'border-primary-600 text-primary-700'
                : 'border-transparent text-gray-500 hover:text-gray-700'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* ── Tab GIIS ───────────────────────────────────────────────── */}
      {tab === 'giis' && (
        <div>
          {giisLoading ? (
            <div className="flex justify-center py-12">
              <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin" />
            </div>
          ) : normativas.length === 0 ? (
            <div className="text-center py-16 border-2 border-dashed border-gray-200 rounded-xl">
              <p className="text-gray-400 text-sm mb-3">No hay normativas GIIS registradas</p>
              <button
                onClick={() => setModal('crear')}
                className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm hover:bg-primary-700"
              >
                Crear primera normativa
              </button>
            </div>
          ) : (
            <div className="space-y-3">
              {normativas.map((n) => {
                const totalUnidades = parseInt(n.total_unidades_activas ?? 0)
                const adoptaron = parseInt(n.unidades_adoptaron ?? 0)
                const pct = totalUnidades > 0 ? Math.round((adoptaron / totalUnidades) * 100) : 0

                return (
                  <div key={n.id} className="border border-gray-200 rounded-xl p-5 hover:border-gray-300 transition-colors">
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="font-mono text-sm font-bold text-primary-700 bg-primary-50 px-2 py-0.5 rounded">
                            {n.clave}
                          </span>
                          <BadgeEstatus estatus={n.estatus} />
                        </div>
                        <p className="font-medium text-gray-900">{n.nombre_documento}</p>
                        <p className="text-xs text-gray-400 mt-1">
                          {n.version && <span>Versión {n.version}</span>}
                          {n.version && n.fecha_publicacion && <span> · </span>}
                          {n.fecha_publicacion && <span>Publicada {new Date(n.fecha_publicacion).toLocaleDateString('es-MX')}</span>}
                        </p>

                        {/* Barra de adopción */}
                        <div className="flex items-center gap-3 mt-3">
                          <div className="flex-1 bg-gray-200 rounded-full h-1.5">
                            <div className="bg-primary-500 h-1.5 rounded-full transition-all" style={{ width: `${pct}%` }} />
                          </div>
                          <span className="text-xs text-gray-500 flex-shrink-0">
                            {adoptaron}/{totalUnidades} unidades adoptaron ({pct}%)
                          </span>
                        </div>
                      </div>

                      <div className="flex items-center gap-2 flex-shrink-0">
                        {n.url_pdf && (
                          <a href={n.url_pdf} target="_blank" rel="noopener noreferrer"
                            className="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded-lg text-gray-700 transition-colors">
                            PDF
                          </a>
                        )}
                        <button
                          onClick={() => setGiisVerCampos(giisVerCampos?.id === n.id ? null : n)}
                          className="px-3 py-1 text-xs bg-sky-50 text-sky-700 hover:bg-sky-100 rounded-lg transition-colors"
                        >
                          {giisVerCampos?.id === n.id ? 'Ocultar campos' : 'Ver campos'}
                        </button>
                        <button onClick={() => abrirEditar(n)}
                          className="px-3 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                          Editar
                        </button>
                        <button
                          onClick={() => cambiarEstatusMut.mutate({ id: n.id, estatus: n.estatus === 'ACTIVO' ? 'INACTIVO' : 'ACTIVO' })}
                          className={`px-3 py-1 text-xs rounded-lg transition-colors ${
                            n.estatus === 'ACTIVO'
                              ? 'bg-red-50 text-red-600 hover:bg-red-100'
                              : 'bg-green-50 text-green-600 hover:bg-green-100'
                          }`}
                        >
                          {n.estatus === 'ACTIVO' ? 'Desactivar' : 'Activar'}
                        </button>
                      </div>
                    </div>

                    {/* Campos de la normativa */}
                    {giisVerCampos?.id === n.id && (
                      <div className="mt-4 pt-4 border-t border-gray-100">
                        <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
                          Campos dinámicos de la normativa
                        </p>
                        {camposLoading ? (
                          <p className="text-xs text-gray-400">Cargando campos...</p>
                        ) : (camposData?.data ?? []).length === 0 ? (
                          <p className="text-xs text-gray-400 italic">Sin campos registrados para esta normativa.</p>
                        ) : (
                          <div className="grid grid-cols-2 lg:grid-cols-3 gap-2">
                            {(camposData?.data ?? []).map((c) => (
                              <div key={c.id} className="border border-gray-100 rounded-lg px-3 py-2 bg-gray-50">
                                <p className="text-xs font-medium text-gray-700">{c.etiqueta || c.nombre_campo}</p>
                                <p className="text-xs text-gray-400">{c.tipo_campo}</p>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          )}

          {/* Nota de importación */}
          <div className="mt-6 border border-dashed border-gray-200 rounded-xl p-4 text-center">
            <p className="text-sm text-gray-400 mb-2">
              ¿Tienes un archivo GIIS externo (JSON/XML)?
            </p>
            <button
              disabled
              className="px-4 py-2 text-sm border border-gray-200 rounded-lg text-gray-400 cursor-not-allowed"
              title="Próximamente"
            >
              Importar GIIS desde archivo — Próximamente
            </button>
          </div>
        </div>
      )}

      {/* ── Tab Catálogos del sistema ───────────────────────────────── */}
      {tab === 'catalogos' && (
        <div className="space-y-3">
          {CATALOGOS_REFERENCIA.map((cat) => (
            <div key={cat.clave} className="border border-gray-200 rounded-xl p-5 flex items-start justify-between gap-4">
              <div className="flex items-start gap-4">
                <span className="text-2xl">{cat.icono}</span>
                <div>
                  <p className="font-medium text-gray-900">{cat.nombre}</p>
                  <p className="text-xs text-gray-500 mt-0.5">{cat.descripcion}</p>
                  <div className="flex items-center gap-2 mt-2">
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                      cat.editable ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-500'
                    }`}>
                      {cat.editable ? 'Editable en UI' : 'Solo lectura'}
                    </span>
                    {cat.importacion && (
                      <span className="px-2 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-700">
                        Importación externa
                      </span>
                    )}
                  </div>
                </div>
              </div>
              <div className="flex gap-2 flex-shrink-0">
                {cat.editable && (
                  <button
                    disabled
                    className="px-3 py-1 text-xs bg-blue-50 text-blue-500 rounded-lg cursor-not-allowed"
                    title="Gestión de servicios — Próximamente"
                  >
                    Gestionar
                  </button>
                )}
                {cat.importacion && (
                  <button
                    disabled
                    className="px-3 py-1 text-xs bg-amber-50 text-amber-500 rounded-lg cursor-not-allowed"
                    title="Reimportación — Próximamente"
                  >
                    Reimportar
                  </button>
                )}
              </div>
            </div>
          ))}

          <div className="mt-4 border border-blue-100 bg-blue-50 rounded-xl px-5 py-4 text-sm text-blue-700">
            Los catálogos marcados como <strong>Editable en UI</strong> se podrán modificar directamente.
            Los catálogos de <strong>importación externa</strong> (SEPOMEX, CIE-10, CIE-9) requieren cargar un archivo CSV/SQL actualizado.
          </div>
        </div>
      )}

      {/* Modal crear normativa */}
      <Modal isOpen={modal === 'crear'} onClose={cerrarModal} title="Nueva normativa GIIS" size="lg">
        <FormGiis onSuccess={cerrarModal} onCancel={cerrarModal} />
      </Modal>

      {/* Modal editar normativa */}
      <Modal isOpen={modal === 'editar'} onClose={cerrarModal}
        title={`Editar: ${giisSeleccionado?.clave}`} size="lg">
        {giisSeleccionado && (
          <FormGiis giis={giisSeleccionado} onSuccess={cerrarModal} onCancel={cerrarModal} />
        )}
      </Modal>
    </div>
  )
}
