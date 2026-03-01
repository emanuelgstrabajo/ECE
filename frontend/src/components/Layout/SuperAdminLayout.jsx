import { Outlet } from 'react-router-dom'
import SuperAdminSidebar from './SuperAdminSidebar.jsx'

export default function SuperAdminLayout() {
    return (
        <div className="flex h-screen bg-slate-50 overflow-hidden text-slate-900 selection:bg-primary-200 selection:text-primary-900 font-sans">
            <SuperAdminSidebar />
            <main className="flex-1 overflow-y-auto relative">
                {/* Subtle background decoration */}
                <div className="absolute top-0 left-0 right-0 h-64 bg-gradient-to-b from-primary-50 to-slate-50 opacity-60 pointer-events-none -z-10" />
                <div className="p-8 max-w-7xl mx-auto z-10">
                    <Outlet />
                </div>
            </main>
        </div>
    )
}
