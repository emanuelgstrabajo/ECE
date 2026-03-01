import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './context/AuthContext.jsx'
import AppLayout from './components/Layout/AppLayout.jsx'
import Login from './pages/Login.jsx'
import Dashboard from './pages/Dashboard.jsx'

// Super Admin - Habilitación Minimalista
import SuperAdminLayout from './components/layout/SuperAdminLayout.jsx'
import EnableUnitPage from './pages/superadmin/EnableUnitPage.jsx'

// SuperAdmin — 4 secciones fijas (antiguas/ocultas por ahora)
import DashboardSuperAdmin from './pages/admin/DashboardSuperAdmin.jsx'
import Unidades from './pages/admin/Unidades.jsx'
import Usuarios from './pages/admin/Usuarios.jsx'
import Catalogos from './pages/admin/Catalogos.jsx'

// SuperAdmin — secciones adicionales
import Personal from './pages/admin/Personal.jsx'
import Bitacora from './pages/admin/Bitacora.jsx'

// Fase 2 — Admin de Unidad
import DashboardUnidad from './pages/adminUnidad/DashboardUnidad.jsx'
import PersonalUnidad from './pages/adminUnidad/PersonalUnidad.jsx'
import ServiciosUnidad from './pages/adminUnidad/ServiciosUnidad.jsx'
import NormativasUnidad from './pages/adminUnidad/NormativasUnidad.jsx'
import BitacoraUnidad from './pages/adminUnidad/BitacoraUnidad.jsx'

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
  if (roles && !roles.includes(usuario.rol)) {
    if (usuario.rol === 'SUPERADMIN') return <Navigate to="/superadmin/habilitar-unidad" replace />
    return <Navigate to="/dashboard" replace />
  }
  return children
}

function RutaPublica({ children }) {
  const { usuario, cargando } = useAuth()
  if (cargando) return null
  if (usuario) {
    if (usuario.rol === 'SUPERADMIN') return <Navigate to="/superadmin/habilitar-unidad" replace />
    return <Navigate to="/dashboard" replace />
  }
  return children
}

function FallbackRoute() {
  const { usuario, cargando } = useAuth()
  if (cargando) return <Cargando />
  if (!usuario) return <Navigate to="/login" replace />
  if (usuario.rol === 'SUPERADMIN') return <Navigate to="/superadmin/habilitar-unidad" replace />
  return <Navigate to="/dashboard" replace />
}

export default function App() {
  return (
    <Routes>
      {/* Ruta pública */}
      <Route path="/login" element={<RutaPublica><Login /></RutaPublica>} />

      {/* ── Ruta Minimalista Super Administrador ── */}
      <Route element={<RutaProtegida roles={['SUPERADMIN']}><SuperAdminLayout /></RutaProtegida>}>
        <Route path="/superadmin/habilitar-unidad" element={<EnableUnitPage />} />
      </Route>

      {/* Rutas con layout (sidebar) — requieren autenticación */}
      <Route element={<RutaProtegida><AppLayout /></RutaProtegida>}>
        <Route path="/dashboard" element={<Dashboard />} />

        {/* SuperAdmin — 4 secciones fijas (OCULTADAS FASE 1B MINIMALISTA) */}
        {/* <Route path="/admin/dashboard" element={<RutaProtegida roles={['SUPERADMIN']}><DashboardSuperAdmin /></RutaProtegida>} />
        <Route path="/admin/unidades" element={<RutaProtegida roles={['SUPERADMIN']}><Unidades /></RutaProtegida>} />
        <Route path="/admin/usuarios" element={<RutaProtegida roles={['SUPERADMIN']}><Usuarios /></RutaProtegida>} />
        <Route path="/admin/catalogos" element={<RutaProtegida roles={['SUPERADMIN']}><Catalogos /></RutaProtegida>} /> */}

        {/* SuperAdmin — secciones adicionales (OCULTADAS FASE 1B MINIMALISTA) */}
        {/* <Route path="/admin/personal" element={<RutaProtegida roles={['SUPERADMIN']}><Personal /></RutaProtegida>} />
        <Route path="/admin/bitacora" element={<RutaProtegida roles={['SUPERADMIN']}><Bitacora /></RutaProtegida>} /> */}

        {/* Fase 2 — Admin de Unidad */}
        <Route path="/admin-unidad/dashboard" element={<RutaProtegida roles={['ADMIN_UNIDAD']}><DashboardUnidad /></RutaProtegida>} />
        <Route path="/admin-unidad/personal" element={<RutaProtegida roles={['ADMIN_UNIDAD']}><PersonalUnidad /></RutaProtegida>} />
        <Route path="/admin-unidad/servicios" element={<RutaProtegida roles={['ADMIN_UNIDAD']}><ServiciosUnidad /></RutaProtegida>} />
        <Route path="/admin-unidad/normativas" element={<RutaProtegida roles={['ADMIN_UNIDAD']}><NormativasUnidad /></RutaProtegida>} />
        <Route path="/admin-unidad/bitacora" element={<RutaProtegida roles={['ADMIN_UNIDAD']}><BitacoraUnidad /></RutaProtegida>} />
      </Route>

      {/* Redirección por defecto */}
      <Route path="*" element={<FallbackRoute />} />
    </Routes>
  )
}
