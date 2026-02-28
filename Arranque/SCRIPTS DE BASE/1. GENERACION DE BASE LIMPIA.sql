-- =============================================================================
-- SISTEMA ECE GLOBAL - ESQUEMA DE BASE DE DATOS V6.0 (MAESTRO INTEGRAL)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. EXTENSIONES Y FUNCIONES BASE
-- -----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- -----------------------------------------------------------------------------
-- 2. INFRAESTRUCTURA DE NORMATIVIDAD Y GOBERNANZA (TABLAS SYS)
-- -----------------------------------------------------------------------------
CREATE TABLE sys_normatividad_giis (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(50) UNIQUE,        
    nombre_documento VARCHAR(255),   
    version VARCHAR(20),             
    fecha_publicacion DATE,
    url_pdf VARCHAR(500),            
    estatus VARCHAR(20) DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sys_registro_catalogos (
    id SERIAL PRIMARY KEY,
    archivo_origen VARCHAR(255),
    tabla_destino VARCHAR(255),
    criterios_carga TEXT,
    version VARCHAR(50) DEFAULT '1.0 (Carga Inicial)',
    estatus VARCHAR(20) DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sys_adopcion_catalogos (
    id SERIAL PRIMARY KEY,
    normatividad_id INTEGER REFERENCES sys_normatividad_giis(id) ON DELETE CASCADE,
    catalogo_nombre VARCHAR(100),    
    registro_importacion_id INTEGER REFERENCES sys_registro_catalogos(id) ON DELETE CASCADE, 
    fecha_adopcion DATE DEFAULT CURRENT_DATE,
    comentarios TEXT
);

-- -----------------------------------------------------------------------------
-- 3. DICCIONARIOS DINÁMICOS Y SUS RELACIONES (TABLAS GUI Y REL)
-- -----------------------------------------------------------------------------
CREATE TABLE gui_diccionarios (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(100) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT
);

CREATE TABLE gui_diccionario_opciones (
    id SERIAL PRIMARY KEY,
    diccionario_id INTEGER REFERENCES gui_diccionarios(id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES gui_diccionario_opciones(id),
    clave VARCHAR(50) NOT NULL,
    valor TEXT NOT NULL,
    metadatos JSONB,
    activo BOOLEAN DEFAULT TRUE,
    UNIQUE(diccionario_id, clave, valor)
);

CREATE TABLE rel_normatividad_opciones (
    normatividad_id INTEGER REFERENCES sys_normatividad_giis(id) ON DELETE CASCADE,
    opcion_id INTEGER REFERENCES gui_diccionario_opciones(id) ON DELETE CASCADE,
    PRIMARY KEY (normatividad_id, opcion_id)
);

-- -----------------------------------------------------------------------------
-- 4. CATÁLOGOS GEOGRÁFICOS Y CLÍNICOS MASIVOS (TABLAS CAT)
-- -----------------------------------------------------------------------------
CREATE TABLE cat_entidades (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(5) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    abreviatura VARCHAR(10)
);

CREATE TABLE cat_municipios (
    id SERIAL PRIMARY KEY,
    entidad_id INTEGER REFERENCES cat_entidades(id) ON DELETE CASCADE,
    clave VARCHAR(10) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    UNIQUE(entidad_id, clave)
);

CREATE TABLE cat_asentamientos_cp (
    id SERIAL PRIMARY KEY,
    municipio_id INTEGER REFERENCES cat_municipios(id) ON DELETE CASCADE,
    codigo_postal VARCHAR(5) NOT NULL,
    nombre_colonia VARCHAR(255) NOT NULL,
    tipo_asentamiento VARCHAR(100),
    zona VARCHAR(50)
);
CREATE INDEX idx_cp ON cat_asentamientos_cp(codigo_postal);

CREATE TABLE cat_cie10_diagnosticos (
    id SERIAL PRIMARY KEY,
    catalog_key VARCHAR(10) NOT NULL,
    nombre TEXT NOT NULL,
    lsex VARCHAR(10) DEFAULT 'NO',
    linf VARCHAR(20),
    lsup VARCHAR(20),
    es_suive_morb BOOLEAN DEFAULT FALSE,
    metadatos JSONB,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_cie10_activo ON cat_cie10_diagnosticos(catalog_key) WHERE activo = TRUE;

CREATE TABLE cat_cie9_procedimientos (
    id SERIAL PRIMARY KEY,
    catalog_key VARCHAR(10) NOT NULL,
    nombre TEXT NOT NULL,
    sex_type VARCHAR(2) DEFAULT '0',
    procedimiento_type CHAR(1),
    metadatos JSONB,
    activo BOOLEAN DEFAULT TRUE
);
CREATE INDEX idx_cie9_activo ON cat_cie9_procedimientos(catalog_key) WHERE activo = TRUE;

-- -----------------------------------------------------------------------------
-- 5. ADMINISTRACIÓN, UNIDADES Y MATRICES SIS (TABLAS ADM Y CAT)
-- -----------------------------------------------------------------------------
CREATE TABLE adm_unidades_medicas (
    id SERIAL PRIMARY KEY,
    clues VARCHAR(11) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    asentamiento_id INTEGER REFERENCES cat_asentamientos_cp(id),
    tipo_unidad VARCHAR(255),
    estatus_operacion VARCHAR(100),
    tiene_espirometro BOOLEAN DEFAULT FALSE,
    es_servicio_amigable BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    geom GEOMETRY(Point, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_clues_activo ON adm_unidades_medicas(clues) WHERE activo = TRUE;

CREATE TABLE cat_tipos_personal (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(10) UNIQUE NOT NULL,
    descripcion VARCHAR(150) NOT NULL
);

CREATE TABLE cat_servicios_atencion (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(10) UNIQUE NOT NULL,
    descripcion VARCHAR(150) NOT NULL
);

CREATE TABLE cat_matriz_personal_servicio (
    tipo_personal_id INTEGER NOT NULL REFERENCES cat_tipos_personal(id) ON DELETE CASCADE,
    servicio_atencion_id INTEGER NOT NULL REFERENCES cat_servicios_atencion(id) ON DELETE CASCADE,
    PRIMARY KEY (tipo_personal_id, servicio_atencion_id)
);

CREATE TABLE adm_usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    curp VARCHAR(18) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE adm_personal_salud (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES adm_usuarios(id),
    unidad_medica_id INTEGER REFERENCES adm_unidades_medicas(id),
    tipo_personal_id INTEGER NOT NULL REFERENCES cat_tipos_personal(id),
    cedula_profesional VARCHAR(20),
    nombre_completo VARCHAR(255) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 6. REGISTRO CLÍNICO Y ATENCIÓN (TABLAS CLIN)
-- -----------------------------------------------------------------------------
CREATE TABLE clin_pacientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    numero_expediente_global VARCHAR(50) UNIQUE NOT NULL,
    curp VARCHAR(18) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    primer_apellido VARCHAR(100) NOT NULL,
    segundo_apellido VARCHAR(100),
    fecha_nacimiento DATE NOT NULL,
    sexo_id INTEGER REFERENCES gui_diccionario_opciones(id),
    asentamiento_id INTEGER REFERENCES cat_asentamientos_cp(id),
    datos_clinicos JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clin_citas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    paciente_id UUID NOT NULL REFERENCES clin_pacientes(id) ON DELETE CASCADE,
    unidad_medica_id INTEGER NOT NULL REFERENCES adm_unidades_medicas(id),
    personal_salud_id UUID REFERENCES adm_personal_salud(id),
    fecha_hora_cita TIMESTAMP NOT NULL,
    estatus_cita VARCHAR(50) DEFAULT 'PROGRAMADA', -- Ej: PROGRAMADA, REALIZADA, CANCELADA, AUSENTE
    motivo_cita TEXT,
    notas_adicionales TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clin_atenciones (
    id UUID DEFAULT uuid_generate_v4(),
    paciente_id UUID NOT NULL REFERENCES clin_pacientes(id),
    cita_id UUID REFERENCES clin_citas(id),
    unidad_medica_id INTEGER NOT NULL REFERENCES adm_unidades_medicas(id),
    personal_salud_id UUID NOT NULL REFERENCES adm_personal_salud(id),
    fecha_atencion DATE NOT NULL,
    datos_atencion JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, fecha_atencion)
) PARTITION BY RANGE (fecha_atencion);

-- Partición inicial 2026-2027
CREATE TABLE clin_atenciones_2026 PARTITION OF clin_atenciones
FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- -----------------------------------------------------------------------------
-- 7. TRIGGERS DE AUDITORÍA
-- -----------------------------------------------------------------------------
CREATE TRIGGER trigger_upd_unidades BEFORE UPDATE ON adm_unidades_medicas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_upd_pacientes BEFORE UPDATE ON clin_pacientes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_upd_citas BEFORE UPDATE ON clin_citas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- =========================================================================
-- FASE 0: MEJORA DE LA ESTRUCTURA ACTUAL 
-- =========================================================================
ALTER TABLE public.gui_diccionarios ADD COLUMN IF NOT EXISTS es_sistema BOOLEAN DEFAULT FALSE;
ALTER TABLE public.gui_diccionario_opciones ADD COLUMN IF NOT EXISTS orden INT DEFAULT 0;

-- =========================================================================
-- FASE 1: CREACIÓN DE LAS TABLAS DEL MOTOR DE REGLAS GIIS
-- =========================================================================
CREATE TABLE IF NOT EXISTS public.sys_giis_campos (
    id SERIAL PRIMARY KEY,
    normatividad_id INT REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE,
    orden INT NOT NULL,
    nombre_campo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo_dato VARCHAR(30) NOT NULL,
    longitud_maxima INT,
    obligatorio BOOLEAN DEFAULT FALSE,
    confidencial BOOLEAN DEFAULT FALSE,
    catalogo_asociado VARCHAR(100),
    tipo_validacion VARCHAR(20) DEFAULT 'CATALOGO',
    UNIQUE (normatividad_id, nombre_campo)
);

CREATE TABLE IF NOT EXISTS public.sys_giis_restricciones (
    id SERIAL PRIMARY KEY,
    normatividad_id INT REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE,
    campo_id INT REFERENCES public.sys_giis_campos(id) ON DELETE CASCADE,
    nombre_regla VARCHAR(100) NOT NULL,
    tipo_regla VARCHAR(50) NOT NULL,
    expresion JSONB NOT NULL,
    mensaje_error TEXT NOT NULL,
    nivel VARCHAR(20) DEFAULT 'ERROR',
    fecha_inicio DATE NOT NULL
);
