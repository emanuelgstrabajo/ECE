import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './context/AuthContext.jsx'
import AppLayout from './components/Layout/AppLayout.jsx'
import Login from './pages/Login.jsx'
import Dashboard from './pages/Dashboard.jsx'
import Unidades from './pages/admin/Unidades.jsx'
import Usuarios from './pages/admin/Usuarios.jsx'
import Personal from './pages/admin/Personal.jsx'
import Bitacora from './pages/admin/Bitacora.jsx'

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
      </Route>

      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  )
}
