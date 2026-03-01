import { useState, useEffect, useMemo } from 'react'
import { adminApi, catalogosApi } from '../../api/adminApi.js'
import toast from 'react-hot-toast'

export default function AssignAdminModal({ isOpen, onClose, unitData }) {
    const [searchTerm, setSearchTerm] = useState('')
    const [users, setUsers] = useState([])
    const [isLoading, setIsLoading] = useState(false)
    const [selectedUser, setSelectedUser] = useState(null)
    const [isAssigning, setIsAssigning] = useState(false)

    // Cargar usuarios cuando se abre el modal
    useEffect(() => {
        if (isOpen) {
            setSearchTerm('')
            setSelectedUser(null)
            fetchUsers()
        }
    }, [isOpen])

    const fetchUsers = async () => {
        setIsLoading(true)
        try {
            // Se traen los primeros 100 usuarios activos. Ideal para un select dinamico o filtro rapido
            const res = await adminApi.getUsuarios({ limit: 100 })
            if (res.data) {
                // Filtrar asegurando que tienen información
                setUsers(res.data)
            }
        } catch (error) {
            console.error('Error al cargar usuarios:', error)
            toast.error('Error al conectar con el servidor para buscar usuarios.')
        } finally {
            setIsLoading(false)
        }
    }

    const filteredUsers = useMemo(() => {
        if (!searchTerm) return users
        const term = searchTerm.toLowerCase()
        return users.filter(u =>
            u.email.toLowerCase().includes(term) ||
            u.curp.toLowerCase().includes(term) ||
            (u.nombre_completo && u.nombre_completo.toLowerCase().includes(term))
        )
    }, [users, searchTerm])

    const handleAssign = async () => {
        if (!selectedUser || !unitData) return

        setIsAssigning(true)

        try {
            // Asumiendo que el rol principal de administrador local tiene un ID conocido, o obtenemos la lista de roles
            const rolesRes = await catalogosApi.getRoles()
            const adminLocalRole = rolesRes.data.find(r => r.clave === 'ADMIN_LOCAL')

            if (!adminLocalRole) {
                toast.error('El rol de Administrador Local no existe en el sistema.')
                setIsAssigning(false)
                return
            }

            const body = {
                unidad_medica_id: unitData.id,
                rol_id: adminLocalRole.id,
                fecha_inicio: new Date().toISOString().split('T')[0] // 'YYYY-MM-DD'
            }

            await adminApi.crearAsignacion(selectedUser.id, body)

            toast.success(`Usuario asignado exitosamente como Administrador de ${unitData.clues}`)
            setTimeout(() => {
                onClose() // Cerrar despues de mostrar mensaje
            }, 1000)

        } catch (error) {
            console.error('Error al asignar usuario:', error)
            toast.error(error.response?.data?.error || 'No se pudo completar la asignación. Verifique que no esté asignado ya a esta unidad.')
        } finally {
            setIsAssigning(false)
        }
    }


    if (!isOpen) return null

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-gray-900/60 backdrop-blur-sm animate-in fade-in duration-200">
            <div className="bg-white rounded-2xl shadow-xl w-full max-w-lg overflow-hidden flex flex-col max-h-[90vh]">

                {/* Header */}
                <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                    <h3 className="text-lg font-bold text-gray-900">
                        Asignar Administrador Local
                    </h3>
                    <button
                        onClick={onClose}
                        className="text-gray-400 hover:text-gray-600 transition-colors p-1"
                    >
                        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                {/* Body */}
                <div className="p-6 overflow-y-auto">
                    {/* Tarjeta de Resumen de Unidad */}
                    <div className="mb-6 bg-slate-50 border border-slate-200 rounded-xl p-4 flex gap-4">
                        <div className="w-12 h-12 bg-white rounded-lg border border-slate-200 shadow-sm flex items-center justify-center shrink-0">
                            <svg className="w-6 h-6 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                            </svg>
                        </div>
                        <div>
                            <p className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-1">Unidad Seleccionada</p>
                            <h4 className="text-sm font-semibold text-slate-900 leading-tight">{unitData?.nombre}</h4>
                            <p className="text-sm font-mono text-slate-600 mt-1">{unitData?.clues}</p>
                        </div>
                    </div>

                    {/* Buscador de usuario */}
                    <div className="mb-4">
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            Seleccionar Usuario
                        </label>
                        <div className="relative">
                            <input
                                type="text"
                                placeholder="Buscar por email, CURP o nombre..."
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                                className="w-full pl-10 pr-4 py-2 bg-white border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition-shadow"
                            />
                            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                </svg>
                            </div>
                        </div>
                    </div>

                    {/* Lista de Usuarios (Radio buttons) */}
                    <div className="border border-gray-200 rounded-xl max-h-60 overflow-y-auto bg-gray-50/30">
                        {isLoading ? (
                            <div className="p-8 flex flex-col items-center justify-center text-gray-500">
                                <svg className="animate-spin h-6 w-6 text-primary-500 mb-2" fill="none" viewBox="0 0 24 24">
                                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                <span className="text-sm">Cargando usuarios...</span>
                            </div>
                        ) : filteredUsers.length === 0 ? (
                            <div className="p-8 text-center text-sm text-gray-500">
                                No se encontraron usuarios {searchTerm && 'con esa búsqueda'}
                            </div>
                        ) : (
                            <ul className="divide-y divide-gray-100">
                                {filteredUsers.map((user) => (
                                    <li key={user.id} className="hover:bg-gray-50">
                                        <label className={`flex items-start p-3 cursor-pointer transition-colors ${selectedUser?.id === user.id ? 'bg-primary-50' : ''}`}>
                                            <div className="flex items-center h-5 mt-1">
                                                <input
                                                    type="radio"
                                                    name="userSelection"
                                                    className="w-4 h-4 text-primary-600 border-gray-300 focus:ring-primary-500"
                                                    checked={selectedUser?.id === user.id}
                                                    onChange={() => setSelectedUser(user)}
                                                />
                                            </div>
                                            <div className="ml-3 flex flex-col">
                                                <span className="text-sm font-semibold text-gray-900">
                                                    {user.nombre_completo || user.email}
                                                </span>
                                                <span className="text-xs text-gray-500 mt-0.5">
                                                    {user.curp} • {user.email}
                                                </span>
                                                <span className="text-xs font-medium text-primary-600 mt-1">
                                                    Rol actual: {user.rol_nombre || user.rol_clave}
                                                </span>
                                            </div>
                                        </label>
                                    </li>
                                ))}
                            </ul>
                        )}
                    </div>
                </div>

                {/* Footer Actions */}
                <div className="px-6 py-4 border-t border-gray-100 bg-gray-50 flex justify-end gap-3 mt-auto">
                    <button
                        onClick={onClose}
                        type="button"
                        disabled={isAssigning}
                        className="px-4 py-2 text-sm font-semibold text-gray-700 bg-white border border-gray-300 rounded-xl hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 transition-colors"
                    >
                        Cancelar
                    </button>
                    <button
                        onClick={handleAssign}
                        disabled={!selectedUser || isAssigning}
                        type="button"
                        className="px-4 py-2 text-sm font-bold text-white bg-primary-600 rounded-xl hover:bg-primary-700 focus:outline-none focus:ring-4 focus:ring-primary-500/30 disabled:opacity-50 disabled:cursor-not-allowed transition-colors shadow-sm flex items-center justify-center min-w-[120px]"
                    >
                        {isAssigning ? (
                            <>
                                <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                Asignando...
                            </>
                        ) : (
                            'Asignar Privilegios'
                        )}
                    </button>
                </div>
            </div>
        </div>
    )
}
