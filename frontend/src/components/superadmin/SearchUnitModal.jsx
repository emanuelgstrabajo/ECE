import { useState, useEffect } from 'react'
import { adminApi } from '../../api/adminApi.js'

export default function SearchUnitModal({ isOpen, onClose, onUnitFound }) {
    const [searchTerm, setSearchTerm] = useState('')
    const [isSearching, setIsSearching] = useState(false)
    const [results, setResults] = useState([])
    const [hasSearched, setHasSearched] = useState(false)

    // Efecto de búsqueda con debounce
    useEffect(() => {
        if (!isOpen) return;

        const term = searchTerm.trim()

        if (term.length < 3) {
            setResults([])
            setHasSearched(false)
            setIsSearching(false)
            return
        }

        const executeSearch = async () => {
            setIsSearching(true)
            setHasSearched(true)
            console.log("-> Búsqueda de catálogo iniciada con: ", term)

            try {
                const response = await adminApi.buscarCatalogoUnidades(term)
                console.log("<- Respuesta del API: ", response)
                if (response && response.data) {
                    console.log("-> Asignando resultados (length):", response.data.length || 0)
                    setResults(response.data)
                } else if (Array.isArray(response)) {
                    console.log("-> Asignando resultados directos (array):", response.length)
                    setResults(response)
                } else {
                    console.log("-> Respuesta inesperada, sin data array:", response)
                    setResults([])
                }
            } catch (err) {
                console.error('Error al buscar en el catálogo', err)
                setResults([])
            } finally {
                setIsSearching(false)
            }
        }

        const debounceTimer = setTimeout(() => {
            executeSearch()
        }, 400) // 400ms debounce

        return () => clearTimeout(debounceTimer)
    }, [searchTerm, isOpen])

    const handleSelectUnit = (unit) => {
        onUnitFound(unit)
        handleClose()
    }

    const handleClose = () => {
        setSearchTerm('')
        setResults([])
        setHasSearched(false)
        setIsSearching(false)
        onClose()
    }

    if (!isOpen) return null

    return (
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm transition-opacity">
            <div
                className="bg-white rounded-2xl shadow-2xl w-full max-w-xl overflow-visible transform transition-all animate-in fade-in zoom-in-95 duration-200 flex flex-col"
                role="dialog"
                aria-modal="true"
            >
                {/* Header Modal */}
                <div className="px-6 py-5 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between rounded-t-2xl">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-primary-100 flex items-center justify-center flex-shrink-0">
                            <svg className="w-5 h-5 text-primary-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                            </svg>
                        </div>
                        <div>
                            <h3 className="text-lg font-bold text-slate-900">Buscar en Catálogo Oficial</h3>
                            <p className="text-sm font-medium text-slate-500">Localiza la unidad médica a habilitar</p>
                        </div>
                    </div>
                    <button
                        onClick={handleClose}
                        className="text-slate-400 hover:text-slate-600 transition-colors p-2 rounded-lg hover:bg-slate-100 outline-none focus:ring-2 focus:ring-slate-200"
                    >
                        <span className="sr-only">Cerrar</span>
                        <svg className="w-5 h-5" viewBox="0 0 20 20" fill="currentColor">
                            <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                        </svg>
                    </button>
                </div>

                {/* Body Form */}
                <div className="p-6 sm:p-8 flex-1 overflow-visible">
                    <div className="space-y-6">

                        {/* Campo Búsqueda */}
                        <div className="relative">
                            <label htmlFor="clues_search" className="block text-sm font-bold text-gray-700 mb-1.5">
                                Clave CLUES o Nombre de Unidad <span className="text-red-500">*</span>
                            </label>
                            <div className="relative">
                                <input
                                    id="clues_search"
                                    type="text"
                                    placeholder="Ej. GTSSA... o Hospital..."
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    autoComplete="off"
                                    className="block w-full rounded-xl sm:text-base px-4 py-3 placeholder:text-gray-400 focus:ring-4 transition-all uppercase outline-none font-mono tracking-wider border border-gray-300 ring-primary-50 focus:border-primary-500 focus:ring-primary-100"
                                />
                                <div className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                                    {isSearching ? (
                                        <svg className="animate-spin h-5 w-5 text-primary-500" fill="none" viewBox="0 0 24 24">
                                            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                        </svg>
                                    ) : (
                                        <svg className="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                        </svg>
                                    )}
                                </div>
                            </div>

                            {/* Autocomplete Dropdown */}
                            {searchTerm.trim().length >= 3 && (
                                <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-xl shadow-[0_10px_40px_-10px_rgba(0,0,0,0.15)] border border-gray-100 overflow-hidden z-[999] max-h-60 overflow-y-auto ring-1 ring-black/5">
                                    {results && results.length > 0 ? (
                                        <ul className="divide-y divide-gray-50">
                                            {results.map((unit, idx) => (
                                                <li key={unit.clues || idx}>
                                                    <button
                                                        type="button"
                                                        onClick={() => handleSelectUnit(unit)}
                                                        className="w-full text-left px-4 py-3 hover:bg-slate-50 focus:bg-primary-50 transition-colors focus:outline-none flex flex-col group"
                                                    >
                                                        <div className="flex justify-between items-center mb-0.5">
                                                            <span className="font-bold text-sm text-gray-900 group-hover:text-primary-700 transition-colors">{unit.nombre}</span>
                                                            <span className="text-xs font-mono font-bold bg-slate-100 text-slate-600 px-2 py-0.5 rounded group-hover:bg-primary-100 group-hover:text-primary-800 transition-colors">{unit.clues}</span>
                                                        </div>
                                                        <span className="text-xs text-gray-500 capitalize-first">{unit.municipio || ''}, {unit.entidad || unit.estado || ''} &bull; {unit.tipo_unidad?.toLowerCase() || unit.tipo_establecimiento?.toLowerCase() || ''}</span>
                                                    </button>
                                                </li>
                                            ))}
                                        </ul>
                                    ) : hasSearched && !isSearching && results.length === 0 ? (
                                        <div className="px-4 py-6 text-center text-gray-500 text-sm bg-slate-50/50">
                                            <svg className="mx-auto h-6 w-6 text-gray-400 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                            </svg>
                                            <span className="block font-medium text-slate-700">No se encontraron unidades</span>
                                            <span className="block mt-0.5 text-slate-500">Verifica que el nombre o CLUES sea correcto.</span>
                                        </div>
                                    ) : null}
                                </div>
                            )}
                        </div>

                        {/* Hint Box */}
                        <div className="bg-slate-50 rounded-xl p-4 border border-slate-100">
                            <div className="flex gap-3">
                                <div className="flex-shrink-0">
                                    <svg className="h-5 w-5 text-slate-400" fill="currentColor" viewBox="0 0 20 20">
                                        <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                                    </svg>
                                </div>
                                <div className="text-sm text-slate-600">
                                    <p>
                                        Empieza a escribir la <strong>Clave CLUES</strong> o el <strong>Nombre Oficial</strong> de la unidad para ver sugerencias extraídas del catálogo nacional.
                                    </p>
                                </div>
                            </div>
                        </div>

                        {/* footer Form */}
                        <div className="pt-2 flex justify-end">
                            <button
                                type="button"
                                onClick={handleClose}
                                className="px-5 py-2.5 text-sm font-semibold text-slate-700 bg-white border border-slate-300 rounded-xl hover:bg-slate-50 hover:text-slate-900 focus:ring-4 focus:ring-slate-100 transition-all shadow-sm"
                            >
                                Cerrar Buscador
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
