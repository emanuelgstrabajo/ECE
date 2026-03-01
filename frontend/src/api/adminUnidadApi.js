import axiosClient from './axiosClient.js'

export const adminUnidadApi = {
  // Dashboard
  getDashboard: () =>
    axiosClient.get('/admin-unidad/dashboard').then(r => r.data),

  // Personal
  getPersonal: (params) =>
    axiosClient.get('/admin-unidad/personal', { params }).then(r => r.data),
  getPersonalById: (asignacion_id) =>
    axiosClient.get(`/admin-unidad/personal/${asignacion_id}`).then(r => r.data),
  crearPersonal: (body) =>
    axiosClient.post('/admin-unidad/personal', body).then(r => r.data),
  revocarPersonal: (asignacion_id, body) =>
    axiosClient.delete(`/admin-unidad/personal/${asignacion_id}`, { data: body }).then(r => r.data),

  // Servicios y normativas
  getServicios: () =>
    axiosClient.get('/admin-unidad/servicios').then(r => r.data),
  getNormativas: () =>
    axiosClient.get('/admin-unidad/normativas').then(r => r.data),

  // Bitácora
  getBitacora: (params) =>
    axiosClient.get('/admin-unidad/bitacora', { params }).then(r => r.data),
}
