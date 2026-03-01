import { useState, useEffect, useMemo, useRef } from 'react'
import SearchUnitModal from '../../components/superadmin/SearchUnitModal.jsx'
import ConfirmUnitModal from '../../components/superadmin/ConfirmUnitModal.jsx'
import ConfirmDisableModal from '../../components/superadmin/ConfirmDisableModal.jsx'
import AssignAdminModal from '../../components/superadmin/AssignAdminModal.jsx'
import UnitMap from '../../components/superadmin/UnitMap.jsx'
import { adminApi } from '../../api/adminApi.js'
import toast from 'react-hot-toast'

export default function EnableUnitPage() {
    // View State
    const [viewMode, setViewMode] = useState('table') // 'table' | 'map'
    const [activeTab, setActiveTab] = useState('activas') // 'activas' | 'inactivas'

    // Estado de Modales
    const [isSearchModalOpen, setIsSearchModalOpen] = useState(false)
    const [isConfirmModalOpen, setIsConfirmModalOpen] = useState(false)
    const [isDisableModalOpen, setIsDisableModalOpen] = useState(false)
    const [isAssignModalOpen, setIsAssignModalOpen] = useState(false)

    // Datos Transaccionales
    const [foundUnit, setFoundUnit] = useState(null)
    const [unitToDisable, setUnitToDisable] = useState(null)
    const [unitToAssign, setUnitToAssign] = useState(null)
    const [isEnabling, setIsEnabling] = useState(false)
    const [isDisabling, setIsDisabling] = useState(false)

    // Dropdown Estado
    const [openDropdownId, setOpenDropdownId] = useState(null)
    const dropdownRef = useRef(null)

    // Estado para la tabla de unidades
    const [units, setUnits] = useState([])
    const [isLoadingUnits, setIsLoadingUnits] = useState(true)
    const [searchTerm, setSearchTerm] = useState('')

    // Cerrar dropdown al clicear fuera
    useEffect(() => {
        function handleClickOutside(event) {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
                setOpenDropdownId(null)
            }
        }
        document.addEventListener("mousedown", handleClickOutside)
        return () => document.removeEventListener("mousedown", handleClickOutside)
    }, [])

    // Cargar unidades de acuerdo al tab
    const fetchUnits = async () => {
        setIsLoadingUnits(true)
        try {
            const isActive = activeTab === 'activas'
            const res = await adminApi.getUnidades({ activo: isActive })
            if (res.data) {
                setUnits(res.data)
            }
        } catch (error) {
            console.error('Error fetching units:', error)
            toast.error('No se pudo cargar el listado de unidades.')
        } finally {
            setIsLoadingUnits(false)
        }
    }

    useEffect(() => {
        fetchUnits()
    }, [activeTab])

    // Filtrar unidades derivadas (Búsqueda local en tabla)
    const filteredUnits = useMemo(() => {
        if (!searchTerm) return units
        const term = searchTerm.toLowerCase()
        return units.filter(u =>
            (u.nombre?.toLowerCase().includes(term)) ||
            (u.clues?.toLowerCase().includes(term))
        )
    }, [units, searchTerm])

    // Handler: Cuando SearchUnitModal encuentra una unidad en el catálogo
    const handleUnitFound = (unitData) => {
        setFoundUnit(unitData)
        setIsSearchModalOpen(false)     // Cierra buscador
        setIsConfirmModalOpen(true)     // Abre visor confirmador
    }

    const handleConfirmEnable = async () => {
        setIsEnabling(true)
        try {
            const result = await adminApi.habilitarUnidad(foundUnit.id)
            if (result.mensaje || result.data) {

                // Intento de geocodificación para el mapa
                try {
                    const query = `${foundUnit.nombre}, ${foundUnit.municipio || ''}, ${foundUnit.entidad || ''}, Mexico`
                    const geoRes = await fetch(`https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=1`)
                    const geoData = await geoRes.json()

                    if (geoData && geoData.length > 0) {
                        const lat = geoData[0].lat
                        const lng = geoData[0].lon
                        // Guardar coordenadas en BD
                        await adminApi.updateUnidad(foundUnit.id, { lat, lng })
                    }
                } catch (geoError) {
                    console.log('Silenciosamente ignorando error de geocodificación:', geoError)
                }

                setIsConfirmModalOpen(false)
                toast.success(result.mensaje || `La unidad ${foundUnit.clues} ha sido habilitada exitosamente.`)
                setFoundUnit(null)
                // Recargar tabla para mostrar la nueva unidad
                fetchUnits()
            }
        } catch (error) {
            console.error('Error al habilitar unidad', error)
            toast.error(error.response?.data?.error || 'Error al habilitar la unidad.')
        } finally {
            setIsEnabling(false)
        }
    }

    const handleConfirmDisable = async () => {
        if (!unitToDisable) return;
        setIsDisabling(true)
        try {
            const result = await adminApi.deleteUnidad(unitToDisable.id)
            setIsDisableModalOpen(false)
            toast.success(result.mensaje || 'La unidad ha sido deshabilitada.')
            setUnitToDisable(null)
            fetchUnits()
        } catch (error) {
            console.error('Error al deshabilitar unidad', error)
            toast.error(error.response?.data?.error || 'Error al deshabilitar la unidad.')
        } finally {
            setIsDisabling(false)
        }
    }

    const openDisableModal = (unit) => {
        setUnitToDisable(unit)
        setOpenDropdownId(null)
        setIsDisableModalOpen(true)
    }

    const openAssignModal = (unit) => {
        setUnitToAssign(unit)
        setOpenDropdownId(null)
        setIsAssignModalOpen(true)
    }

    return (
        <div className="max-w-6xl mx-auto animation-fade-in pb-12 w-full h-full flex flex-col">
            {/* Header / Topbar */}
            <div className="flex flex-col md:flex-row md:items-end justify-between gap-5 mb-8 border-b border-gray-200 pb-5">
                <div>
                    <h1 className="text-2xl font-extrabold text-gray-900 tracking-tight flex items-center gap-3">
                        <div className="w-8 h-8 rounded-lg bg-primary-100 flex items-center justify-center">
                            <svg className="w-5 h-5 text-primary-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                            </svg>
                        </div>
                        Directorio de Unidades
                    </h1>
                    <p className="mt-2 text-sm text-gray-500 max-w-2xl">
                        Administre las unidades médicas que ya tienen acceso al sistema SIRES. Puede buscar en el catálogo oficial para habilitar nuevos hospitales o clínicas.
                    </p>
                </div>

                <div className="flex flex-col sm:flex-row gap-3">
                    {/* View Toggles */}
                    <div className="flex bg-gray-100 p-1 rounded-xl">
                        <button
                            onClick={() => setViewMode('table')}
                            className={`flex items-center gap-2 px-4 py-2 text-sm font-semibold rounded-lg transition-colors ${viewMode === 'table' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700'}`}
                        >
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 10h16M4 14h16M4 18h16" />
                            </svg>
                            Tabla
                        </button>
                        <button
                            onClick={() => setViewMode('map')}
                            className={`flex items-center gap-2 px-4 py-2 text-sm font-semibold rounded-lg transition-colors ${viewMode === 'map' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700'}`}
                        >
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
                            </svg>
                            Mapa
                        </button>
                    </div>

                    <button
                        onClick={() => setIsSearchModalOpen(true)}
                        className="w-full md:w-auto px-6 py-2.5 text-sm font-bold text-white bg-primary-600 rounded-xl hover:bg-primary-700 focus:ring-4 focus:ring-primary-500/30 transition-all shadow-md shadow-primary-500/20 flex items-center justify-center gap-2"
                    >
                        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                        </svg>
                        Habilitar Nueva Unidad
                    </button>
                </div>
            </div>

            {/* ====== SECCIÓN DE DATOS (TABLA o MAPA) ====== */}
            {viewMode === 'map' ? (
                <div className="w-full flex-1 animate-in fade-in slide-in-from-bottom-4 duration-300">
                    <UnitMap />
                </div>
            ) : (
                <div className="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden animate-in fade-in zoom-in-[0.98] duration-300" ref={dropdownRef}>
                    {/* Herramientas de Tabla */}
                    <div className="p-0 border-b border-gray-100 bg-white">
                        <div className="flex border-b border-gray-200">
                            <button
                                onClick={() => setActiveTab('activas')}
                                className={`flex-1 px-6 py-4 text-sm font-bold border-b-2 transition-all duration-200 ${activeTab === 'activas' ? 'border-primary-500 text-primary-600 bg-primary-50/10' : 'border-transparent text-gray-400 hover:text-gray-600 hover:bg-gray-50'}`}
                            >
                                <div className="flex items-center justify-center gap-2">
                                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                    </svg>
                                    Unidades Activas
                                </div>
                            </button>
                            <button
                                onClick={() => setActiveTab('inactivas')}
                                className={`flex-1 px-6 py-4 text-sm font-bold border-b-2 transition-all duration-200 ${activeTab === 'inactivas' ? 'border-red-500 text-red-600 bg-red-50/10' : 'border-transparent text-gray-400 hover:text-gray-600 hover:bg-gray-50'}`}
                            >
                                <div className="flex items-center justify-center gap-2">
                                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                                    </svg>
                                    Deshabilitadas / Inactivas
                                </div>
                            </button>
                        </div>

                        <div className="p-5 bg-gray-50/30 flex flex-col sm:flex-row justify-between items-center gap-4">
                            <div className="text-sm text-gray-500 font-medium">
                                Mostrando <span className="text-gray-900 font-bold">{filteredUnits.length}</span> unidades {activeTab === 'activas' ? 'activas' : 'deshabilitadas'}
                            </div>

                            {/* Buscador Simple */}
                            <div className="relative w-full sm:w-80">
                                <input
                                    type="text"
                                    placeholder="Buscar en esta lista..."
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    className="w-full pl-9 pr-4 py-2 bg-white border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none transition-all shadow-sm"
                                />
                                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                    </svg>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Tabla de Resultados */}
                    <div className="overflow-x-auto min-h-[300px]">
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-white">
                                <tr>
                                    <th scope="col" className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                        CLUES
                                    </th>
                                    <th scope="col" className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                        Nombre de la Unidad
                                    </th>
                                    <th scope="col" className="px-6 py-4 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                        Tipo / Ubicación
                                    </th>
                                    <th scope="col" className="px-6 py-4 text-center text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                        Añadido el
                                    </th>
                                    <th scope="col" className="px-6 py-4 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                        Acciones
                                    </th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-100">
                                {isLoadingUnits ? (
                                    <tr>
                                        <td colSpan="5" className="px-6 py-10 text-center text-gray-500">
                                            <div className="flex justify-center items-center gap-2">
                                                <svg className="animate-spin h-5 w-5 text-primary-500" fill="none" viewBox="0 0 24 24">
                                                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                                </svg>
                                                Cargando directorio...
                                            </div>
                                        </td>
                                    </tr>
                                ) : filteredUnits.length === 0 ? (
                                    <tr>
                                        <td colSpan="5" className="px-6 py-16 text-center">
                                            <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-gray-50 mb-4 border border-gray-100">
                                                <svg className="w-7 h-7 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 002-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                                                </svg>
                                            </div>
                                            <h3 className="text-base font-medium text-gray-900">Directorio Vacío</h3>
                                            <p className="mt-1.5 text-sm text-gray-500 max-w-sm mx-auto">
                                                {searchTerm
                                                    ? `No se encontraron resultados para "${searchTerm}".`
                                                    : 'Aún no hay unidades médicas registradas en el sistema SIRES.'}
                                            </p>
                                            {!searchTerm && (
                                                <button onClick={() => setIsSearchModalOpen(true)} className="mt-4 text-sm text-primary-600 font-semibold hover:text-primary-800">
                                                    + Habilitar la primera unidad
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                ) : (
                                    filteredUnits.map((unit) => (
                                        <tr key={unit.id} className="hover:bg-gray-50/80 transition-colors group">
                                            <td className="px-6 py-4 whitespace-nowrap">
                                                <span className="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-mono font-bold bg-slate-100/80 text-slate-800 border border-slate-200/60 group-hover:bg-white group-hover:border-slate-300 transition-colors">
                                                    {unit.clues}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="text-sm font-bold text-gray-900">{unit.nombre}</div>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="text-sm text-gray-900 capitalize-first">{unit.tipo_unidad?.toLowerCase() || unit.tipo_establecimiento?.toLowerCase()}</div>
                                                <div className="text-xs text-gray-500">{unit.entidad ? `${unit.municipio}, ${unit.entidad}` : `${unit.municipio}, ${unit.estado || ''}`}</div>
                                            </td>
                                            <td className="px-6 py-4 text-center whitespace-nowrap">
                                                <div className="text-sm text-gray-500">
                                                    {new Date(unit.updated_at || unit.fecha_habilitacion || Date.now()).toLocaleDateString('es-MX', {
                                                        year: 'numeric',
                                                        month: 'short',
                                                        day: 'numeric'
                                                    })}
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-right whitespace-nowrap relative">
                                                <button
                                                    onClick={() => setOpenDropdownId(openDropdownId === unit.id ? null : unit.id)}
                                                    className="text-gray-400 hover:text-gray-600 focus:outline-none p-1 rounded-md hover:bg-gray-100"
                                                >
                                                    <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                                                        <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                                                    </svg>
                                                </button>

                                                {/* Menú de Acciones */}
                                                {openDropdownId === unit.id && (
                                                    <div className="absolute right-8 top-10 w-48 bg-white rounded-md shadow-lg border border-gray-100 z-10 py-1 overflow-hidden animate-in fade-in slide-in-from-top-2">
                                                        {activeTab === 'activas' ? (
                                                            <>
                                                                <button
                                                                    onClick={() => openAssignModal(unit)}
                                                                    className="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
                                                                >
                                                                    <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                                                                    </svg>
                                                                    Asignar Administrador
                                                                </button>
                                                                <button
                                                                    onClick={() => openDisableModal(unit)}
                                                                    className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 flex items-center gap-2"
                                                                >
                                                                    <svg className="w-4 h-4 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                                                    </svg>
                                                                    Deshabilitar Unidad
                                                                </button>
                                                            </>
                                                        ) : (
                                                            <button
                                                                onClick={() => {
                                                                    setFoundUnit(unit)
                                                                    setOpenDropdownId(null)
                                                                    setIsConfirmModalOpen(true)
                                                                }}
                                                                className="w-full text-left px-4 py-2 text-sm text-emerald-600 hover:bg-emerald-50 flex items-center gap-2"
                                                            >
                                                                <svg className="w-4 h-4 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                                                </svg>
                                                                Restaurar/Habilitar Unidad
                                                            </button>
                                                        )}
                                                    </div>
                                                )}
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}

            {/* ====== MODALES ====== */}

            {/* Modal 1: Buscar en Catálogo Oficial */}
            <SearchUnitModal
                isOpen={isSearchModalOpen}
                onClose={() => setIsSearchModalOpen(false)}
                onUnitFound={handleUnitFound}
            />

            {/* Modal 2: Confirmación de Datos */}
            <ConfirmUnitModal
                isOpen={isConfirmModalOpen}
                onClose={() => setIsConfirmModalOpen(false)}
                onConfirm={handleConfirmEnable}
                unitData={foundUnit}
                isLoading={isEnabling}
            />

            {/* Modal 3: Confirmación de Deshabilitar */}
            <ConfirmDisableModal
                isOpen={isDisableModalOpen}
                onClose={() => setIsDisableModalOpen(false)}
                onConfirm={handleConfirmDisable}
                unitData={unitToDisable}
                isLoading={isDisabling}
            />

            {/* Modal 4: Asignar Administrador Local */}
            <AssignAdminModal
                isOpen={isAssignModalOpen}
                onClose={() => setIsAssignModalOpen(false)}
                unitData={unitToAssign}
            />
        </div>
    )
}
