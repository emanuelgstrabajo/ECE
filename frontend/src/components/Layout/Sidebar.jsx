import { NavLink, useNavigate } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext.jsx'

const iconos = {
  dashboard:  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />,
  unidades:   <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />,
  usuarios:   <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />,
  personal:   <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />,
  bitacora:   <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />,
}

function NavIcon({ d }) {
  return (
    <svg className="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={d?.props?.d} />
      {d}
    </svg>
  )
}

function SidebarLink({ to, icon, label }) {
  return (
    <NavLink
      to={to}
      className={({ isActive }) =>
        `flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
          isActive
            ? 'bg-primary-600 text-white'
            : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
        }`
      }
    >
      <svg className="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        {icon}
      </svg>
      {label}
    </NavLink>
  )
}

export default function Sidebar() {
  const { usuario, cerrarSesion } = useAuth()
  const navigate = useNavigate()

  async function handleLogout() {
    await cerrarSesion()
    navigate('/login', { replace: true })
  }

  const esSuperAdmin  = usuario?.rol === 'SUPERADMIN'
  const esAdminUnidad = usuario?.rol === 'ADMIN_UNIDAD'

  return (
    <aside className="w-60 bg-white border-r border-gray-200 flex flex-col h-full">
      {/* Logo */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary-600 flex items-center justify-center flex-shrink-0">
            <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z" />
            </svg>
          </div>
          <div>
            <p className="font-bold text-gray-900 text-sm leading-none">SIRES</p>
            <p className="text-xs text-gray-400">ECE Global</p>
          </div>
        </div>
      </div>

      {/* Navegación */}
      <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
        <SidebarLink
          to="/dashboard"
          label="Inicio"
          icon={iconos.dashboard}
        />

        {/* SuperAdmin */}
        {esSuperAdmin && (
          <>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider px-3 pt-4 pb-1">
              Superadministración
            </p>
            <SidebarLink to="/admin/unidades" label="Unidades Médicas" icon={iconos.unidades} />
            <SidebarLink to="/admin/usuarios" label="Usuarios del Sistema" icon={iconos.usuarios} />
            <SidebarLink to="/admin/personal" label="Personal de Salud" icon={iconos.personal} />
            <SidebarLink to="/admin/bitacora" label="Bitácora NOM-024" icon={iconos.bitacora} />
          </>
        )}

        {/* Admin de Unidad — Fase 2 */}
        {esAdminUnidad && (
          <>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider px-3 pt-4 pb-1">
              Mi Unidad
            </p>
            <SidebarLink to="/admin-unidad/dashboard"  label="Dashboard"  icon={iconos.dashboard} />
            <SidebarLink to="/admin-unidad/personal"   label="Personal"   icon={iconos.personal} />
            <SidebarLink to="/admin-unidad/servicios"  label="Servicios"  icon={iconos.unidades} />
            <SidebarLink to="/admin-unidad/normativas" label="Normativas" icon={iconos.bitacora} />
            <SidebarLink to="/admin-unidad/bitacora"   label="Bitácora"   icon={iconos.bitacora} />
          </>
        )}
      </nav>

      {/* Usuario / Logout */}
      <div className="p-3 border-t border-gray-200">
        <div className="flex items-center gap-2 px-3 py-2">
          <div className="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center flex-shrink-0">
            <span className="text-primary-700 text-sm font-semibold">
              {usuario?.nombre?.[0]?.toUpperCase() || '?'}
            </span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs font-medium text-gray-900 truncate">{usuario?.nombre}</p>
            <p className="text-xs text-gray-400">{usuario?.rol}</p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="w-full mt-1 flex items-center gap-2 px-3 py-2 text-xs text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
              d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Cerrar sesión
        </button>
      </div>
    </aside>
  )
}
