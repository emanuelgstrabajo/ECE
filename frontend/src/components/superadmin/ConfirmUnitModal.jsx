export default function ConfirmUnitModal({ isOpen, onClose, onConfirm, unitData, isLoading }) {
    if (!isOpen || !unitData) return null

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm transition-opacity">
            <div
                className="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden transform transition-all animate-in fade-in zoom-in-95 duration-200"
                role="dialog"
                aria-modal="true"
            >
                {/* Header Modal */}
                <div className="px-6 py-5 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center flex-shrink-0">
                            <svg className="w-5 h-5 text-emerald-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                            </svg>
                        </div>
                        <div>
                            <h3 className="text-lg font-bold text-slate-900">Confirmar Habilitación</h3>
                            <p className="text-sm font-medium text-slate-500">Verifique los datos de la unidad médica</p>
                        </div>
                    </div>
                    <button
                        onClick={onClose}
                        disabled={isLoading}
                        className="text-slate-400 hover:text-slate-600 transition-colors p-2 rounded-lg hover:bg-slate-100 outline-none focus:ring-2 focus:ring-slate-200"
                    >
                        <span className="sr-only">Cerrar</span>
                        <svg className="w-5 h-5" viewBox="0 0 20 20" fill="currentColor">
                            <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                        </svg>
                    </button>
                </div>

                {/* Cuerpo Modal - Datos de Unidad */}
                <div className="px-6 py-6 border-b border-slate-100">
                    <div className="bg-slate-50 rounded-xl p-5 border border-slate-200 space-y-4">
                        <div>
                            <p className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Nombre Oficial de la Unidad</p>
                            <p className="text-base font-semibold text-slate-900">{unitData.nombre}</p>
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <p className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">CLUES Verificada</p>
                                <div className="inline-flex items-center px-2.5 py-1 rounded-md bg-white border border-slate-200 text-sm font-mono font-medium text-slate-800">
                                    {unitData.clues}
                                </div>
                            </div>
                            <div>
                                <p className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Tipo de Establecimiento</p>
                                <p className="text-sm font-medium text-slate-700 capitalize-first">{unitData.tipo_unidad?.toLowerCase() || unitData.tipo_establecimiento?.toLowerCase() || 'Consulta Externa'}</p>
                            </div>
                        </div>

                        <div className="pt-2">
                            <p className="text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Ubicación</p>
                            <p className="text-sm text-slate-600 flex items-start gap-1.5">
                                <svg className="w-4 h-4 text-slate-400 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                                </svg>
                                {unitData.nombre_colonia || unitData.domicilio}, {unitData.codigo_postal ? `C.P. ${unitData.codigo_postal},` : ''} {unitData.municipio}, {unitData.entidad || unitData.estado}
                            </p>
                        </div>
                    </div>

                    <div className="mt-5 flex gap-3 p-4 bg-amber-50 text-amber-800 rounded-xl border border-amber-200/60">
                        <svg className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <p className="text-sm font-medium leading-relaxed">
                            Al confirmar, esta unidad quedará listada y disponible en el Dashboard. El Administrador de Unidad correspondiente deberá acceder para configurar el resto de parámetros (personal, roles, etc).
                        </p>
                    </div>
                </div>

                {/* Footer Acciones */}
                <div className="px-6 py-4 bg-slate-50 flex items-center justify-end gap-3">
                    <button
                        type="button"
                        onClick={onClose}
                        disabled={isLoading}
                        className="px-5 py-2.5 text-sm font-semibold text-slate-700 bg-white border border-slate-300 rounded-xl hover:bg-slate-50 hover:text-slate-900 focus:ring-4 focus:ring-slate-100 transition-all shadow-sm"
                    >
                        Cancelar
                    </button>
                    <button
                        type="button"
                        onClick={onConfirm}
                        disabled={isLoading}
                        className="px-6 py-2.5 text-sm font-semibold text-white bg-primary-600 rounded-xl hover:bg-primary-700 focus:ring-4 focus:ring-primary-500/30 transition-all shadow-md shadow-primary-500/20 flex items-center gap-2"
                    >
                        {isLoading && (
                            <svg className="animate-spin -ml-1 mr-1 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                        )}
                        Habilitar Permanentemente
                    </button>
                </div>
            </div>
        </div>
    )
}
