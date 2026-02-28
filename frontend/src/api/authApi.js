import axiosClient from './axiosClient.js'
import axios from 'axios'

export async function apiLogin(identificador, password) {
  const { data } = await axiosClient.post('/auth/login', { identificador, password })
  return data
}

/**
 * Segunda etapa del login multi-unidad.
 * Se llama cuando el servidor devolvió requires_unit_selection: true.
 * @param {string} asignacion_id  UUID de la asignación seleccionada
 * @param {string} preToken       Token temporal de selección (5 min)
 */
export async function apiSeleccionarUnidad(asignacion_id, preToken) {
  const { data } = await axiosClient.post(
    '/auth/seleccionar-unidad',
    { asignacion_id },
    { headers: { Authorization: `Bearer ${preToken}` } }
  )
  return data
}

export async function apiRefresh() {
  // Usa axios directo para no activar el interceptor de refresh nuevamente
  const { data } = await axios.post('/api/auth/refresh', {}, { withCredentials: true })
  return data
}

export async function apiLogout() {
  const { data } = await axiosClient.post('/auth/logout')
  return data
}

export async function apiMe() {
  const { data } = await axiosClient.get('/auth/me')
  return data
}
