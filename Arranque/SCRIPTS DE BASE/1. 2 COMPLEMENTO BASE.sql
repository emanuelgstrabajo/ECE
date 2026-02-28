-- =========================================================================
-- ACTUALIZACIÓN ARQUITECTÓNICA MAESTRA - PREPARACIÓN PARA PRODUCCIÓN
-- Cumplimiento NOM-024, PostGIS, Seguridad RBAC y Enrutamiento de Catálogos
-- =========================================================================

DO $$
DECLARE
    v_dic_id INT;
BEGIN

    -- =========================================================================
    -- BLOQUE 1: SEGURIDAD Y CONTROL DE ACCESOS (RBAC Y NOM-024)
    -- =========================================================================
    
    -- 1.1 Crear tabla de Roles de Sistema (No existía)
    CREATE TABLE IF NOT EXISTS public.cat_roles (
        id SERIAL PRIMARY KEY,
        clave VARCHAR(20) UNIQUE NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        descripcion TEXT,
        activo BOOLEAN DEFAULT true
    );

    -- 1.2 Inyectar los roles clínicos y administrativos fundamentales
    INSERT INTO public.cat_roles (clave, nombre, descripcion) VALUES
    ('SUPERADMIN', 'Super Administrador', 'Acceso total y configuración del sistema HIS'),
    ('MEDICO', 'Médico Tratante', 'Acceso a consulta, expediente clínico y recetas'),
    ('ENFERMERIA', 'Personal de Enfermería', 'Acceso a triage, somatometría y aplicación de medicamentos'),
    ('TRABAJO_SOCIAL', 'Trabajo Social', 'Acceso a estudios socioeconómicos y referencias'),
    ('RECEPCION', 'Recepción y Archivo', 'Acceso a agenda y registro demográfico de pacientes')
    ON CONFLICT (clave) DO NOTHING;

    -- 1.3 Blindar la tabla adm_usuarios (Agregar Rol y Auditoría de Accesos)
    ALTER TABLE public.adm_usuarios ADD COLUMN IF NOT EXISTS rol_id INT REFERENCES public.cat_roles(id);
    ALTER TABLE public.adm_usuarios ADD COLUMN IF NOT EXISTS ultimo_acceso TIMESTAMP WITHOUT TIME ZONE;
    ALTER TABLE public.adm_usuarios ADD COLUMN IF NOT EXISTS intentos_fallidos INT DEFAULT 0;
    ALTER TABLE public.adm_usuarios ADD COLUMN IF NOT EXISTS bloqueado_hasta TIMESTAMP WITHOUT TIME ZONE;

    -- =========================================================================
    -- BLOQUE 2: MEJORAS EN EL EXPEDIENTE DEL PACIENTE (CLIN_PACIENTES)
    -- =========================================================================
    
    -- 2.1 Agregar flag para "Paciente Desconocido" (Vital para Urgencias/Trauma)
    ALTER TABLE public.clin_pacientes ADD COLUMN IF NOT EXISTS es_identidad_desconocida BOOLEAN DEFAULT FALSE;

    -- 2.2 Crear el diccionario Maestro Global para Sexo del Paciente 
    -- (Para que clin_pacientes.sexo_id no se mezcle con las guías)
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) 
    VALUES ('SYS_SEXO_PACIENTE', 'Sexo Biológico (Expediente Paciente Maestro)', TRUE) 
    ON CONFLICT (codigo) DO NOTHING;
    
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'SYS_SEXO_PACIENTE';
    
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'HOMBRE', 1), 
    (v_dic_id, '2', 'MUJER', 2), 
    (v_dic_id, '3', 'INTERSEXUAL', 3) 
    ON CONFLICT ON CONSTRAINT gui_diccionario_opciones_diccionario_id_clave_valor_key DO NOTHING;

    -- =========================================================================
    -- BLOQUE 3: INTELIGENCIA DE ENRUTAMIENTO DE CATÁLOGOS (API GATEWAY)
    -- =========================================================================
    
    -- 3.1 Agregar columna "fuente_catalogo" para que el Backend sepa a qué tabla consultar
    ALTER TABLE public.sys_giis_campos ADD COLUMN IF NOT EXISTS fuente_catalogo VARCHAR(50);

    -- 3.2 Clasificación automática de todos los campos ya inyectados
    
    -- A) Catálogos Clínicos Mayores (CIE-10)
    UPDATE public.sys_giis_campos 
    SET fuente_catalogo = 'TABLA_CIE10' 
    WHERE catalogo_asociado IN ('DIAGNOSTICOS', 'MORFOLOGIA');

    -- B) Catálogos Quirúrgicos Mayores (CIE-9)
    UPDATE public.sys_giis_campos 
    SET fuente_catalogo = 'TABLA_CIE9' 
    WHERE catalogo_asociado = 'PROCEDIMIENTO';

    -- C) Catálogos Demográficos y Geográficos (INEGI / SEPOMEX)
    UPDATE public.sys_giis_campos 
    SET fuente_catalogo = 'TABLA_SEPOMEX' 
    WHERE catalogo_asociado IN ('PAIS', 'ENTIDAD_FEDERATIVA', 'MUNICIPIOS', 'LOCALIDADES', 'CODIGO_POSTAL', 'TIPO_ASENTAMIENTO', 'TIPO_VIALIDAD', 'ESCOLARIDAD');

    -- D) Catálogos DGIS (Catálogos nacionales de la tabla principal)
    UPDATE public.sys_giis_campos 
    SET fuente_catalogo = 'TABLA_UNIDADES' 
    WHERE catalogo_asociado = 'ESTABLECIMIENTO DE SALUD';
    
    UPDATE public.sys_giis_campos 
    SET fuente_catalogo = 'TABLA_ESPECIALIDADES' 
    WHERE catalogo_asociado = 'ESPECIALIDADES';

    -- E) Minicatálogos de Interfaz Gráfica (Los que viven en gui_diccionarios)
    UPDATE public.sys_giis_campos 
    SET fuente_catalogo = 'DICCIONARIO_GUI' 
    WHERE catalogo_asociado IS NOT NULL AND fuente_catalogo IS NULL;

    -- =========================================================================
    -- BLOQUE 4: ÍNDICES DE ALTO RENDIMIENTO (PERFORMANCE TUNING)
    -- =========================================================================
    
END $$;

-- (Los índices se crean fuera del bloque DO porque PostGIS y concurrencia lo prefieren así)

-- 4.1 Índice Espacial GIST para Mapas y Geolocalización (PostGIS)
CREATE INDEX IF NOT EXISTS idx_unidades_medicas_geom 
ON public.adm_unidades_medicas USING GIST (geom);

-- 4.2 Índices B-Tree para búsqueda ultrarrápida de pacientes en Recepción
CREATE INDEX IF NOT EXISTS idx_paciente_apellidos 
ON public.clin_pacientes USING btree (primer_apellido, segundo_apellido);

CREATE INDEX IF NOT EXISTS idx_paciente_nombre 
ON public.clin_pacientes USING btree (nombre);

CREATE INDEX IF NOT EXISTS idx_paciente_fecha_nac 
ON public.clin_pacientes USING btree (fecha_nacimiento);

-- 4.3 Índices para el renderizado instantáneo de formularios en el Front-End
CREATE INDEX IF NOT EXISTS idx_giis_campos_orden 
ON public.sys_giis_campos USING btree (normatividad_id, orden);

CREATE INDEX IF NOT EXISTS idx_giis_restricciones_campo 
ON public.sys_giis_restricciones USING btree (campo_id);

-- 4.4 Índice de búsqueda para Historial de Citas
CREATE INDEX IF NOT EXISTS idx_citas_paciente 
ON public.clin_citas USING btree (paciente_id, fecha_hora_cita);