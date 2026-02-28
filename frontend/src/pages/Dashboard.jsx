import { useAuth } from '../context/AuthContext.jsx'

const ROL_LABELS = {
  SUPERADMIN: 'Superadministrador',
  ADMIN_UNIDAD: 'Administrador de Unidad',
  MEDICO: 'Médico',
  ENFERMERIA: 'Enfermería',
  TRABAJO_SOCIAL: 'Trabajo Social',
  RECEPCION: 'Recepción',
  PACIENTE: 'Paciente',
}

export default function Dashboard() {
  const { usuario, cerrarSesion } = useAuth()

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Barra superior */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-primary-600 flex items-center justify-center">
              <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
                <path d="M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z" />
              </svg>
            </div>
            <span className="font-semibold text-gray-900">SIRES</span>
          </div>

          <div className="flex items-center gap-4">
            <div className="text-right hidden sm:block">
              <p className="text-sm font-medium text-gray-900">{usuario?.nombre}</p>
              <p className="text-xs text-gray-500">{ROL_LABELS[usuario?.rol] ?? usuario?.rol}</p>
            </div>
            <button
              onClick={cerrarSesion}
              className="text-sm text-gray-500 hover:text-red-600 transition-colors px-3 py-1.5 rounded-lg hover:bg-red-50"
            >
              Cerrar sesión
            </button>
          </div>
        </div>
      </header>

      {/* Contenido principal */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center">
          <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-primary-100 mb-6">
            <svg className="w-10 h-10 text-primary-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            ¡Bienvenido, {usuario?.nombre?.split(' ')[0]}!
          </h1>
          <p className="text-gray-500 text-lg mb-8">
            {ROL_LABELS[usuario?.rol] ?? usuario?.rol} · SIRES v1.0
          </p>

          {/* Tarjetas de módulos (próximamente) */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 max-w-3xl mx-auto">
            {[
              { titulo: 'Gestión de Unidades', icono: '🏥', desc: 'Administrar unidades médicas', fase: 'Fase 1B' },
              { titulo: 'Personal de Salud', icono: '👨‍⚕️', desc: 'Alta y gestión de personal', fase: 'Fase 1B' },
              { titulo: 'Catálogos', icono: '📋', desc: 'CIE-10, CIE-9, GIIS', fase: 'Fase 1B' },
              { titulo: 'Pacientes', icono: '🧑‍🤝‍🧑', desc: 'Expediente y búsqueda MPI', fase: 'Fase 3' },
              { titulo: 'Consulta Médica', icono: '🩺', desc: 'Formularios GIIS dinámicos', fase: 'Fase 3' },
              { titulo: 'Expediente Digital', icono: '📁', desc: 'Documentos NOM-024', fase: 'Fase 3' },
            ].map((mod) => (
              <div
                key={mod.titulo}
                className="bg-white rounded-xl border border-gray-200 p-6 text-left opacity-60 cursor-not-allowed"
              >
                <div className="text-3xl mb-3">{mod.icono}</div>
                <h3 className="font-semibold text-gray-900 mb-1">{mod.titulo}</h3>
                <p className="text-sm text-gray-500 mb-3">{mod.desc}</p>
                <span className="inline-block text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">
                  {mod.fase} — Próximamente
                </span>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  )
}
