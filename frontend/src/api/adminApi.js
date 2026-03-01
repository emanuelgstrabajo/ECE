import axiosClient from './axiosClient.js'

export const adminApi = {
  // Dashboard SUPERADMIN
  getDashboard: () => axiosClient.get('/admin/dashboard').then(r => r.data),

  // Unidades — habilitadas (activo=true)
  getUnidades: (params) => axiosClient.get('/admin/unidades', { params }).then(r => r.data),
  getUnidadesMapa: () => axiosClient.get('/admin/unidades/mapa').then(r => r.data),
  getUnidad: (id) => axiosClient.get(`/admin/unidades/${id}`).then(r => r.data),
  // Búsqueda en catálogo (activo=false) para el modal "Habilitar unidad"
  buscarCatalogoUnidades: (q) => axiosClient.get('/admin/unidades/catalogo', { params: { q } }).then(r => r.data),
  // Habilitar una unidad del catálogo
  habilitarUnidad: (id) => axiosClient.post(`/admin/unidades/${id}/habilitar`).then(r => r.data),
  // Registrar una unidad nueva en el catálogo (activo=false por default en el form de alta inicial)
  createUnidad: (body) => axiosClient.post('/admin/unidades', body).then(r => r.data),
  updateUnidad: (id, body) => axiosClient.put(`/admin/unidades/${id}`, body).then(r => r.data),
  deleteUnidad: (id) => axiosClient.delete(`/admin/unidades/${id}`).then(r => r.data),

  // Usuarios
  getUsuarios: (params) => axiosClient.get('/admin/usuarios', { params }).then(r => r.data),
  getUsuario: (id) => axiosClient.get(`/admin/usuarios/${id}`).then(r => r.data),
  createUsuario: (body) => axiosClient.post('/admin/usuarios', body).then(r => r.data),
  updateUsuario: (id, body) => axiosClient.put(`/admin/usuarios/${id}`, body).then(r => r.data),
  resetPassword: (id, body) => axiosClient.post(`/admin/usuarios/${id}/reset-password`, body).then(r => r.data),
  desbloquear: (id) => axiosClient.post(`/admin/usuarios/${id}/desbloquear`).then(r => r.data),

  // Personal de Salud
  getPersonal: (params) => axiosClient.get('/admin/personal', { params }).then(r => r.data),
  getPersonalById: (id) => axiosClient.get(`/admin/personal/${id}`).then(r => r.data),
  createPersonal: (body) => axiosClient.post('/admin/personal', body).then(r => r.data),
  updatePersonal: (id, body) => axiosClient.put(`/admin/personal/${id}`, body).then(r => r.data),
  deletePersonal: (id) => axiosClient.delete(`/admin/personal/${id}`).then(r => r.data),

  // Asignaciones usuario ↔ unidad ↔ rol
  getAsignaciones: (usuario_id, params) =>
    axiosClient.get(`/admin/usuarios/${usuario_id}/asignaciones`, { params }).then(r => r.data),
  crearAsignacion: (usuario_id, body) =>
    axiosClient.post(`/admin/usuarios/${usuario_id}/asignaciones`, body).then(r => r.data),
  revocarAsignacion: (usuario_id, asig_id, body) =>
    axiosClient.delete(`/admin/usuarios/${usuario_id}/asignaciones/${asig_id}`, { data: body }).then(r => r.data),

  // Normativas GIIS
  getGiis: () => axiosClient.get('/admin/giis').then(r => r.data),
  getGiisById: (id) => axiosClient.get(`/admin/giis/${id}`).then(r => r.data),
  createGiis: (body) => axiosClient.post('/admin/giis', body).then(r => r.data),
  updateGiis: (id, body) => axiosClient.put(`/admin/giis/${id}`, body).then(r => r.data),
  cambiarEstatusGiis: (id, estatus) => axiosClient.patch(`/admin/giis/${id}/estatus`, { estatus }).then(r => r.data),
  getCamposGiis: (id) => axiosClient.get(`/admin/giis/${id}/campos`).then(r => r.data),

  // Administradores de unidad
  getAdministradoresUnidad: (unidadId) =>
    axiosClient.get(`/admin/unidades/${unidadId}/administradores`).then(r => r.data),
  crearAdministrador: (unidadId, body) =>
    axiosClient.post(`/admin/unidades/${unidadId}/administradores`, body).then(r => r.data),
  revocarAdministrador: (unidadId, asigId, body) =>
    axiosClient.delete(`/admin/unidades/${unidadId}/administradores/${asigId}`, { data: body }).then(r => r.data),

  // Bitácora
  getBitacora: (params) => axiosClient.get('/admin/bitacora', { params }).then(r => r.data),
}

// ── Catálogos ─────────────────────────────────────────────────────
export const catalogosApi = {
  getRoles: () => axiosClient.get('/catalogos/roles').then(r => r.data),
  getTiposPersonal: () => axiosClient.get('/catalogos/tipos-personal').then(r => r.data),
  getEntidades: () => axiosClient.get('/catalogos/entidades').then(r => r.data),
  getMunicipios: (entidad_id) => axiosClient.get('/catalogos/municipios', { params: { entidad_id } }).then(r => r.data),
  getAsentamientos: (municipio_id) => axiosClient.get('/catalogos/asentamientos', { params: { municipio_id } }).then(r => r.data),
  searchCie10: (q) => axiosClient.get('/catalogos/cie10', { params: { q } }).then(r => r.data),
  searchCie9: (q) => axiosClient.get('/catalogos/cie9', { params: { q } }).then(r => r.data),
  getDiccionario: (codigo, parent_id) => axiosClient.get(`/catalogos/diccionario/${codigo}`, { params: { parent_id } }).then(r => r.data),
}
