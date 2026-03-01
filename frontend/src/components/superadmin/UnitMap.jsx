import { useState, useEffect } from 'react'
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'
import { adminApi } from '../../api/adminApi'
import L from 'leaflet'

// Fix required for default marker icons missing in React-Leaflet
import iconRetina from 'leaflet/dist/images/marker-icon-2x.png'
import icon from 'leaflet/dist/images/marker-icon.png'
import iconShadow from 'leaflet/dist/images/marker-shadow.png'

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: iconRetina,
    iconUrl: icon,
    shadowUrl: iconShadow,
});

export default function UnitMap() {
    const [mapUnits, setMapUnits] = useState([])
    const [isLoading, setIsLoading] = useState(true)

    useEffect(() => {
        const fetchMapCoords = async () => {
            setIsLoading(true)
            try {
                const res = await adminApi.getUnidadesMapa()
                if (res.data) setMapUnits(res.data)
            } catch (error) {
                console.error('Error fetching map data:', error)
            } finally {
                setIsLoading(false)
            }
        }
        fetchMapCoords()
    }, [])

    if (isLoading) {
        return (
            <div className="h-[500px] w-full bg-slate-100 rounded-xl flex items-center justify-center border border-slate-200">
                <div className="flex flex-col items-center text-slate-500">
                    <svg className="animate-spin h-8 w-8 text-primary-500 mb-4" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span className="font-medium">Cargando mapa interactivo...</span>
                </div>
            </div>
        )
    }

    // Default center point at Mexico coordinates (adjust if necessary)
    const mxCenter = [23.6345, -102.5528]

    return (
        <div className="h-[600px] w-full rounded-2xl overflow-hidden border border-slate-200 shadow-sm relative z-0 bg-slate-50">
            <MapContainer
                center={mxCenter}
                zoom={4}
                scrollWheelZoom={true}
                style={{ height: '600px', width: '100%' }}
            >
                <TileLayer
                    attribution='&copy; <a href="https://carto.com/">Carto</a>'
                    url="https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png"
                />

                {mapUnits.map((u) => {
                    if (!u.lat || !u.lng) return null
                    return (
                        <Marker key={u.id} position={[u.lat, u.lng]}>
                            <Popup className="sires-popup">
                                <div className="p-1 min-w-[200px]">
                                    <div className="text-xs font-mono font-bold text-primary-700 bg-primary-50 inline-block px-1.5 py-0.5 rounded mb-1">{u.clues}</div>
                                    <h4 className="font-bold text-slate-900 text-sm leading-tight mb-1">{u.nombre}</h4>
                                    <p className="text-xs text-slate-500 capitalize-first">{u.tipo_unidad?.toLowerCase()}</p>

                                    <div className="mt-2 pt-2 border-t border-slate-100">
                                        <span className={`inline-flex items-center gap-1 text-[10px] font-bold uppercase tracking-wide
                                            ${u.estatus_operacion === 'EN OPERACION' ? 'text-emerald-600' : 'text-amber-600'}`}>
                                            <span className={`w-1.5 h-1.5 rounded-full ${u.estatus_operacion === 'EN OPERACION' ? 'bg-emerald-500' : 'bg-amber-500'}`}></span>
                                            {u.estatus_operacion || 'Sin estatus'}
                                        </span>
                                    </div>
                                </div>
                            </Popup>
                        </Marker>
                    )
                })}
            </MapContainer>

            {/* Custom Leaflet overrides overlay via Tailwind arbitrary variants if needed, but styling is mostly handled by TileLayer and standard classes */}
        </div>
    )
}
