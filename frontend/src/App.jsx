import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './context/AuthContext.jsx'
import AppLayout from './components/Layout/AppLayout.jsx'
import Login from './pages/Login.jsx'
import Dashboard from './pages/Dashboard.jsx'
import Unidades from './pages/admin/Unidades.jsx'
import Usuarios from './pages/admin/Usuarios.jsx'
import Personal from './pages/admin/Personal.jsx'
import Bitacora from './pages/admin/Bitacora.jsx'
// Fase 2 — Admin de Unidad
import DashboardUnidad  from './pages/adminUnidad/DashboardUnidad.jsx'
import PersonalUnidad   from './pages/adminUnidad/PersonalUnidad.jsx'
import ServiciosUnidad  from './pages/adminUnidad/ServiciosUnidad.jsx'
import NormativasUnidad from './pages/adminUnidad/NormativasUnidad.jsx'
import BitacoraUnidad   from './pages/adminUnidad/BitacoraUnidad.jsx'

function Cargando() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <div className="w-12 h-12 border-4 border-primary-500 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
        <p className="text-gray-500">Verificando sesión...</p>
      </div>
    </div>
  )
}

function RutaProtegida({ children, roles }) {
  const { usuario, cargando } = useAuth()
  if (cargando) return <Cargando />
  if (!usuario) return <Navigate to="/login" replace />
  if (roles && !roles.includes(usuario.rol)) return <Navigate to="/dashboard" replace />
  return children
}

function RutaPublica({ children }) {
  const { usuario, cargando } = useAuth()
  if (cargando) return null
  if (usuario) return <Navigate to="/dashboard" replace />
  return children
}

export default function App() {
  return (
    <Routes>
      {/* Ruta pública */}
      <Route path="/login" element={<RutaPublica><Login /></RutaPublica>} />

      {/* Rutas con layout (sidebar) — requieren autenticación */}
      <Route element={<RutaProtegida><AppLayout /></RutaProtegida>}>
        <Route path="/dashboard" element={<Dashboard />} />

        {/* SuperAdmin */}
        <Route path="/admin/unidades" element={<RutaProtegida roles={['SUPERADMIN']}><Unidades /></RutaProtegida>} />
        <Route path="/admin/usuarios" element={<RutaProtegida roles={['SUPERADMIN']}><Usuarios /></RutaProtegida>} />
        <Route path="/admin/personal" element={<RutaProtegida roles={['SUPERADMIN']}><Personal /></RutaProtegida>} />
        <Route path="/admin/bitacora" element={<RutaProtegida roles={['SUPERADMIN']}><Bitacora /></RutaProtegida>} />

        {/* Fase 2 — Admin de Unidad */}
        <Route path="/admin-unidad/dashboard"  element={<RutaProtegida roles={['ADMIN_UNIDAD']}><DashboardUnidad /></RutaProtegida>} />
        <Route path="/admin-unidad/personal"   element={<RutaProtegida roles={['ADMIN_UNIDAD']}><PersonalUnidad /></RutaProtegida>} />
        <Route path="/admin-unidad/servicios"  element={<RutaProtegida roles={['ADMIN_UNIDAD']}><ServiciosUnidad /></RutaProtegida>} />
        <Route path="/admin-unidad/normativas" element={<RutaProtegida roles={['ADMIN_UNIDAD']}><NormativasUnidad /></RutaProtegida>} />
        <Route path="/admin-unidad/bitacora"   element={<RutaProtegida roles={['ADMIN_UNIDAD']}><BitacoraUnidad /></RutaProtegida>} />
      </Route>

      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  )
}
