import axios from 'axios'

// El token de acceso se guarda en memoria (seguro vs XSS)
let accessToken = null

export function setAccessToken(token) {
  accessToken = token
}

export function getAccessToken() {
  return accessToken
}

export function clearAccessToken() {
  accessToken = null
}

const axiosClient = axios.create({
  baseURL: '/api',
  withCredentials: true, // necesario para enviar la cookie HttpOnly
  headers: { 'Content-Type': 'application/json' },
})

// Interceptor de request: adjunta el access token
axiosClient.interceptors.request.use(
  (config) => {
    if (accessToken) {
      config.headers['Authorization'] = `Bearer ${accessToken}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Interceptor de response: renueva el token si expiró
axiosClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const original = error.config

    // Solo intentar refresh si el error es 401 (token expirado) y no es un retry
    if (
      error.response?.status === 401 &&
      error.response?.data?.code === 'TOKEN_EXPIRED' &&
      !original._retry
    ) {
      original._retry = true

      try {
        const { data } = await axios.post('/api/auth/refresh', {}, { withCredentials: true })
        setAccessToken(data.accessToken)
        original.headers['Authorization'] = `Bearer ${data.accessToken}`
        return axiosClient(original)
      } catch {
        // Refresh falló — sesión expirada, limpiar estado
        clearAccessToken()
        window.dispatchEvent(new CustomEvent('sires:sesion-expirada'))
      }
    }

    return Promise.reject(error)
  }
)

export default axiosClient
