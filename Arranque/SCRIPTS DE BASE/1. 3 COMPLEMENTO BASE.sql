-- =========================================================================
-- EL ÚLTIMO 5% - COMPLEMENTO FINAL PARA CUMPLIMIENTO TOTAL NOM-024
-- Módulo de Documentos Digitales y Bitácora Estricta de Auditoría
-- =========================================================================

-- =========================================================================
-- BLOQUE 1: MÓDULO DE DOCUMENTOS Y EXPEDIENTE DIGITAL
-- =========================================================================

-- 1.1 Crear el Cuadro de Clasificación Documental (Tipos de archivos)
CREATE TABLE IF NOT EXISTS public.cat_doc_clasificacion (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true
);

-- Inyectar las clasificaciones base obligatorias en cualquier HIS
INSERT INTO public.cat_doc_clasificacion (clave, nombre, descripcion) VALUES
('DOC-CONSENTIMIENTO', 'Consentimiento Informado', 'Documentos firmados por el paciente aceptando procedimientos'),
('DOC-LABORATORIO', 'Resultados de Laboratorio', 'Estudios de sangre, orina, patología (PDF)'),
('DOC-IMAGENOLOGIA', 'Resultados de Imagenología', 'Rayos X, Ultrasonidos, Mastografías (PDF o DICOM)'),
('DOC-IDENTIFICACION', 'Documento de Identidad', 'INE, Pasaporte, Acta de Nacimiento escaneada'),
('DOC-REFERENCIA', 'Hoja de Referencia/Contrarreferencia', 'Documentos físicos escaneados de traslados a otros hospitales'),
('DOC-OTROS', 'Otros Documentos Clínicos', 'Cualquier otro documento adjunto al expediente')
ON CONFLICT (clave) DO NOTHING;

-- 1.2 Crear la tabla repositorio del Expediente Digital
CREATE TABLE IF NOT EXISTS public.doc_expediente_digital (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL PRIMARY KEY,
    paciente_id uuid NOT NULL REFERENCES public.clin_pacientes(id) ON DELETE CASCADE,
    atencion_id uuid REFERENCES public.clin_citas(id) ON DELETE SET NULL, -- Opcional, puede estar ligado a una cita o solo al paciente
    clasificacion_id INT NOT NULL REFERENCES public.cat_doc_clasificacion(id),
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_almacenamiento TEXT NOT NULL, -- Ruta en AWS S3, Azure o Servidor local
    tipo_mime VARCHAR(100) NOT NULL, -- Ej: application/pdf, image/jpeg
    tamano_bytes BIGINT,
    hash_integridad VARCHAR(256) NOT NULL, -- CRÍTICO NOM-024: Firma criptográfica para probar que el PDF no fue alterado
    subido_por_usuario_id uuid NOT NULL REFERENCES public.adm_usuarios(id),
    fecha_subida TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT,
    activo BOOLEAN DEFAULT true
);

-- Crear índices para buscar documentos rápidamente
CREATE INDEX IF NOT EXISTS idx_doc_paciente ON public.doc_expediente_digital USING btree (paciente_id);
CREATE INDEX IF NOT EXISTS idx_doc_clasificacion ON public.doc_expediente_digital USING btree (clasificacion_id);

-- =========================================================================
-- BLOQUE 2: BITÁCORA DE AUDITORÍA INMUTABLE (CUMPLIMIENTO NOM-024 Y SGSI)
-- =========================================================================

-- 2.1 Crear la tabla de Log de Auditoría
CREATE TABLE IF NOT EXISTS public.sys_bitacora_auditoria (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL PRIMARY KEY,
    usuario_id uuid REFERENCES public.adm_usuarios(id) ON DELETE SET NULL,
    accion VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE', 'VIEW'
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id VARCHAR(100) NOT NULL, -- ID del registro que se alteró
    datos_anteriores JSONB, -- Cómo estaba el registro antes (Para UPDATE o DELETE)
    datos_nuevos JSONB, -- Cómo quedó el registro (Para INSERT o UPDATE)
    fecha_accion TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    direccion_ip VARCHAR(50),
    user_agent TEXT -- Navegador desde donde se hizo el cambio
);

-- Crear índices particionados en el tiempo (porque esta tabla crecerá masivamente)
CREATE INDEX IF NOT EXISTS idx_auditoria_tabla_registro ON public.sys_bitacora_auditoria USING btree (tabla_afectada, registro_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_usuario ON public.sys_bitacora_auditoria USING btree (usuario_id);
CREATE INDEX IF NOT EXISTS idx_auditoria_fecha ON public.sys_bitacora_auditoria USING btree (fecha_accion);

-- 2.2 Bloqueo de seguridad: Evitar que alguien haga un UPDATE o DELETE en la bitácora
-- (Nadie, ni el superadmin, debe poder borrar las huellas de auditoría)
CREATE OR REPLACE FUNCTION public.prevent_audit_tampering()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'ALERTA DE SEGURIDAD NOM-024: Está estrictamente prohibido alterar o eliminar registros de la bitácora de auditoría.';
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_audit_update ON public.sys_bitacora_auditoria;
CREATE TRIGGER trg_prevent_audit_update
    BEFORE UPDATE OR DELETE ON public.sys_bitacora_auditoria
    FOR EACH ROW EXECUTE FUNCTION public.prevent_audit_tampering();