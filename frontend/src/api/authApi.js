import axiosClient from './axiosClient.js'
import axios from 'axios'

export async function apiLogin(identificador, password) {
  const { data } = await axiosClient.post('/auth/login', { identificador, password })
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
