import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext.jsx'
import { apiLogin, apiSeleccionarUnidad } from '../api/authApi.js'

// Icono de cruz médica reutilizable
function IconoCruz() {
  return (
    <svg className="w-9 h-9 text-primary-600" fill="currentColor" viewBox="0 0 24 24">
      <path d="M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z" />
    </svg>
  )
}

// Etiqueta de rol con color institucional
function BadgeRol({ clave }) {
  const colores = {
    MEDICO: 'bg-blue-100 text-blue-800',
    ENFERMERA: 'bg-green-100 text-green-800',
    RECEPCIONISTA: 'bg-purple-100 text-purple-800',
    ADMIN_UNIDAD: 'bg-amber-100 text-amber-800',
  }
  return (
    <span className={`inline-block px-2 py-0.5 rounded-full text-xs font-semibold ${colores[clave] ?? 'bg-gray-100 text-gray-700'}`}>
      {clave}
    </span>
  )
}

export default function Login() {
  const { iniciarSesion } = useAuth()
  const navigate = useNavigate()

  // Paso actual: 'credenciales' | 'selector'
  const [paso, setPaso] = useState('credenciales')

  // Datos para el selector de unidad
  const [unidades, setUnidades] = useState([])
  const [preToken, setPreToken] = useState(null)
  const [seleccionando, setSeleccionando] = useState(false)

  const [error, setError] = useState(null)
  const [cargando, setCargando] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm()

  // ── Paso 1: credenciales ──────────────────────────────────────────
  async function onSubmitCredenciales({ identificador, password }) {
    setError(null)
    setCargando(true)
    try {
      const data = await apiLogin(identificador, password)

      if (data.requires_unit_selection) {
        // El usuario tiene múltiples asignaciones → mostrar selector
        setPreToken(data.pre_token)
        setUnidades(data.unidades)
        setPaso('selector')
      } else {
        // Una sola unidad o SUPERADMIN → token directo
        iniciarSesion(data.accessToken, data.usuario)

        if (data.usuario.rol === 'SUPERADMIN') {
          navigate('/superadmin/habilitar-unidad', { replace: true })
        } else {
          navigate('/dashboard', { replace: true })
        }
      }
    } catch (err) {
      const msg = err.response?.data?.error || 'Error al iniciar sesión. Intente de nuevo.'
      setError(msg)
    } finally {
      setCargando(false)
    }
  }

  // ── Paso 2: seleccionar unidad ────────────────────────────────────
  async function onSeleccionarUnidad(asignacion_id) {
    setError(null)
    setSeleccionando(asignacion_id)
    try {
      const data = await apiSeleccionarUnidad(asignacion_id, preToken)
      iniciarSesion(data.accessToken, data.usuario)
      navigate('/dashboard', { replace: true })
    } catch (err) {
      const msg = err.response?.data?.error || 'Error al seleccionar la unidad. Intente de nuevo.'
      setError(msg)
      // Si el pre_token expiró, volver a credenciales
      if (err.response?.status === 401) {
        setPaso('credenciales')
        setPreToken(null)
        setUnidades([])
      }
    } finally {
      setSeleccionando(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-700 to-primary-900 flex items-center justify-center px-4">
      <div className="w-full max-w-md">

        {/* Logo / encabezado */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white shadow-md mb-4">
            <IconoCruz />
          </div>
          <h1 className="text-3xl font-bold text-white">SIRES</h1>
          <p className="text-primary-200 text-sm mt-1">Sistema de Expediente Clínico Electrónico</p>
        </div>

        {/* ── PASO 1: formulario de credenciales ───────────────────── */}
        {paso === 'credenciales' && (
          <div className="bg-white rounded-2xl shadow-xl p-8">
            <h2 className="text-xl font-semibold text-gray-800 mb-6">Iniciar sesión</h2>

            <form onSubmit={handleSubmit(onSubmitCredenciales)} noValidate className="space-y-5">
              <div>
                <label htmlFor="identificador" className="block text-sm font-medium text-gray-700 mb-1">
                  Correo electrónico o CURP
                </label>
                <input
                  id="identificador"
                  type="text"
                  autoComplete="username"
                  className={`w-full px-4 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 transition
                    ${errors.identificador ? 'border-red-400 bg-red-50' : 'border-gray-300'}`}
                  placeholder="correo@dominio.mx o CURP"
                  {...register('identificador', {
                    required: 'El identificador es requerido',
                    minLength: { value: 3, message: 'Mínimo 3 caracteres' },
                  })}
                />
                {errors.identificador && (
                  <p className="text-red-500 text-xs mt-1">{errors.identificador.message}</p>
                )}
              </div>

              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                  Contraseña
                </label>
                <input
                  id="password"
                  type="password"
                  autoComplete="current-password"
                  className={`w-full px-4 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 transition
                    ${errors.password ? 'border-red-400 bg-red-50' : 'border-gray-300'}`}
                  placeholder="••••••••"
                  {...register('password', {
                    required: 'La contraseña es requerida',
                    minLength: { value: 6, message: 'Mínimo 6 caracteres' },
                  })}
                />
                {errors.password && (
                  <p className="text-red-500 text-xs mt-1">{errors.password.message}</p>
                )}
              </div>

              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">
                  {error}
                </div>
              )}

              <button
                type="submit"
                disabled={cargando}
                className="w-full bg-primary-600 hover:bg-primary-700 disabled:bg-primary-300 text-white font-medium py-2.5 rounded-lg text-sm transition-colors flex items-center justify-center gap-2"
              >
                {cargando ? (
                  <>
                    <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    Verificando...
                  </>
                ) : (
                  'Iniciar sesión'
                )}
              </button>
            </form>
          </div>
        )}

        {/* ── PASO 2: selector de unidad médica ────────────────────── */}
        {paso === 'selector' && (
          <div className="bg-white rounded-2xl shadow-xl p-8">
            <div className="flex items-center gap-3 mb-2">
              <button
                onClick={() => { setPaso('credenciales'); setError(null) }}
                className="text-gray-400 hover:text-gray-600 transition-colors"
                aria-label="Volver"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              <h2 className="text-xl font-semibold text-gray-800">Seleccionar unidad</h2>
            </div>
            <p className="text-sm text-gray-500 mb-6 ml-8">
              Tiene asignaciones en múltiples unidades. Seleccione con cuál desea trabajar esta sesión.
            </p>

            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3 mb-4">
                {error}
              </div>
            )}

            <div className="space-y-3">
              {unidades.map((u) => (
                <button
                  key={u.asignacion_id}
                  onClick={() => onSeleccionarUnidad(u.asignacion_id)}
                  disabled={!!seleccionando}
                  className="w-full text-left border border-gray-200 rounded-xl px-5 py-4 hover:border-primary-400 hover:bg-primary-50 transition-all disabled:opacity-60 group"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="font-medium text-gray-900 group-hover:text-primary-700 text-sm">
                        {u.unidad_nombre}
                      </p>
                      <p className="text-xs text-gray-400 mt-0.5">CLUES: {u.clues}</p>
                    </div>
                    <div className="flex items-center gap-3">
                      <BadgeRol clave={u.rol_clave} />
                      {seleccionando === u.asignacion_id ? (
                        <span className="w-4 h-4 border-2 border-primary-500 border-t-transparent rounded-full animate-spin flex-shrink-0" />
                      ) : (
                        <svg className="w-4 h-4 text-gray-300 group-hover:text-primary-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      )}
                    </div>
                  </div>
                </button>
              ))}
            </div>

            <p className="text-center text-xs text-gray-400 mt-6">
              Esta selección solo aplica para esta sesión
            </p>
          </div>
        )}

        {/* Pie */}
        <p className="text-center text-primary-300 text-xs mt-6">
          NOM-024-SSA3 · Expediente Clínico Electrónico
        </p>
      </div>
    </div>
  )
}
