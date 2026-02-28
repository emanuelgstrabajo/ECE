import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext.jsx'
import { apiLogin } from '../api/authApi.js'

export default function Login() {
  const { iniciarSesion } = useAuth()
  const navigate = useNavigate()
  const [error, setError] = useState(null)
  const [cargando, setCargando] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm()

  async function onSubmit({ identificador, password }) {
    setError(null)
    setCargando(true)
    try {
      const data = await apiLogin(identificador, password)
      iniciarSesion(data.accessToken, data.usuario)
      navigate('/dashboard', { replace: true })
    } catch (err) {
      const msg = err.response?.data?.error || 'Error al iniciar sesión. Intente de nuevo.'
      setError(msg)
    } finally {
      setCargando(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-700 to-primary-900 flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        {/* Logo / encabezado */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white shadow-md mb-4">
            {/* Cruz médica */}
            <svg className="w-9 h-9 text-primary-600" fill="currentColor" viewBox="0 0 24 24">
              <path d="M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-white">SIRES</h1>
          <p className="text-primary-200 text-sm mt-1">Sistema de Expediente Clínico Electrónico</p>
        </div>

        {/* Card */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <h2 className="text-xl font-semibold text-gray-800 mb-6">Iniciar sesión</h2>

          <form onSubmit={handleSubmit(onSubmit)} noValidate className="space-y-5">
            {/* Identificador */}
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

            {/* Contraseña */}
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

            {/* Error del servidor */}
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3">
                {error}
              </div>
            )}

            {/* Botón */}
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

        {/* Pie */}
        <p className="text-center text-primary-300 text-xs mt-6">
          NOM-024-SSA3 · Expediente Clínico Electrónico
        </p>
      </div>
    </div>
  )
}
