import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import { apiRefresh, apiLogout } from '../api/authApi.js'
import { setAccessToken, clearAccessToken } from '../api/axiosClient.js'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [usuario, setUsuario] = useState(null)
  // null = verificando, false = no autenticado, object = autenticado
  const [cargando, setCargando] = useState(true)

  // Al montar: intentar renovar sesión con la cookie HttpOnly
  useEffect(() => {
    async function verificarSesion() {
      try {
        const data = await apiRefresh()
        setAccessToken(data.accessToken)
        // Decodificar el payload del token para obtener los datos del usuario
        const payload = JSON.parse(atob(data.accessToken.split('.')[1]))
        setUsuario(payload)
      } catch {
        // No hay sesión activa — es el estado normal si nunca inició sesión
        setUsuario(null)
      } finally {
        setCargando(false)
      }
    }

    verificarSesion()
  }, [])

  // Escuchar evento de sesión expirada desde el interceptor de axios
  useEffect(() => {
    function onSesionExpirada() {
      setUsuario(null)
      clearAccessToken()
    }
    window.addEventListener('sires:sesion-expirada', onSesionExpirada)
    return () => window.removeEventListener('sires:sesion-expirada', onSesionExpirada)
  }, [])

  const iniciarSesion = useCallback((accessToken, datosUsuario) => {
    setAccessToken(accessToken)
    setUsuario(datosUsuario)
  }, [])

  const cerrarSesion = useCallback(async () => {
    try {
      await apiLogout()
    } catch {
      // Continuar aunque falle el logout en servidor
    } finally {
      clearAccessToken()
      setUsuario(null)
    }
  }, [])

  return (
    <AuthContext.Provider value={{ usuario, cargando, iniciarSesion, cerrarSesion }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth debe usarse dentro de AuthProvider')
  return ctx
}
