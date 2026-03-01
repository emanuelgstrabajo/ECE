import { NavLink, useNavigate } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext.jsx'

const svg = {
    hosp: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4'
}

function NavIcon({ d }) {
    return (
        <svg className="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={d} />
        </svg>
    )
}

function SidebarLink({ to, iconKey, label }) {
    return (
        <NavLink
            to={to}
            className={({ isActive }) =>
                `flex items-center gap-3 px-4 py-3 rounded-xl text-base font-medium transition-all ${isActive
                    ? 'bg-primary-600 text-white shadow-md shadow-primary-500/20'
                    : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                }`
            }
        >
            <NavIcon d={svg[iconKey]} />
            {label}
        </NavLink>
    )
}

function SidebarSection({ title }) {
    return (
        <p className="text-xs font-bold text-gray-400 uppercase tracking-widest px-4 pt-6 pb-2 select-none">
            {title}
        </p>
    )
}

export default function SuperAdminSidebar() {
    const { usuario, cerrarSesion } = useAuth()
    const navigate = useNavigate()

    async function handleLogout() {
        await cerrarSesion()
        navigate('/login', { replace: true })
    }

    return (
        <aside className="w-72 bg-white border-r border-gray-100 flex flex-col h-full shadow-sm z-20">
            {/* Logo Area */}
            <div className="p-6 border-b border-gray-100">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary-600 to-primary-800 flex items-center justify-center flex-shrink-0 shadow-inner">
                        <svg className="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z" />
                        </svg>
                    </div>
                    <div>
                        <p className="font-extrabold text-gray-900 text-lg leading-none tracking-tight">SIRES SA</p>
                        <p className="text-xs font-medium text-primary-600 mt-1">Super Administración</p>
                    </div>
                </div>
            </div>

            {/* Navegación Minimalista */}
            <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
                <SidebarSection title="Gestión de Red" />
                <SidebarLink to="/superadmin/habilitar-unidad" iconKey="hosp" label="Habilitar Unidad" />
            </nav>

            {/* Usuario Profile / Logout */}
            <div className="p-4 border-t border-gray-100 bg-gray-50/50">
                <div className="flex items-center gap-3 px-4 py-3 rounded-xl bg-white border border-gray-200 shadow-sm">
                    <div className="w-9 h-9 rounded-full bg-primary-100 flex items-center justify-center flex-shrink-0 border border-primary-200">
                        <span className="text-primary-700 text-sm font-bold uppercase">
                            {usuario?.nombre?.[0] || 'S'}
                        </span>
                    </div>
                    <div className="flex-1 min-w-0">
                        <p className="text-sm font-bold text-gray-900 truncate">{usuario?.nombre || 'Super Admin'}</p>
                        <p className="text-xs font-medium text-gray-500 truncate">Control Maestro</p>
                    </div>
                </div>

                <button
                    onClick={handleLogout}
                    className="w-full mt-2 flex items-center justify-center gap-2 px-4 py-2.5 text-sm font-medium text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-xl transition-colors border border-transparent hover:border-red-100"
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
