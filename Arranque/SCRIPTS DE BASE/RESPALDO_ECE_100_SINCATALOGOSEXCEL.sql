--
-- PostgreSQL database dump
--

-- Dumped from database version 14.12
-- Dumped by pg_dump version 16.3

-- Started on 2026-02-27 20:50:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3 (class 3079 OID 158954)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 4655 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 4 (class 3079 OID 158991)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 4656 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 2 (class 3079 OID 158943)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 4657 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1073 (class 1255 OID 160554)
-- Name: prevent_audit_tampering(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.prevent_audit_tampering() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'ALERTA DE SEGURIDAD NOM-024: Está estrictamente prohibido alterar o eliminar registros de la bitácora de auditoría.';
END;
$$;


ALTER FUNCTION public.prevent_audit_tampering() OWNER TO postgres;

--
-- TOC entry 1072 (class 1255 OID 160071)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 246 (class 1259 OID 160291)
-- Name: adm_personal_salud; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adm_personal_salud (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    usuario_id uuid NOT NULL,
    unidad_medica_id integer,
    tipo_personal_id integer NOT NULL,
    cedula_profesional character varying(20),
    nombre_completo character varying(255) NOT NULL
);


ALTER TABLE public.adm_personal_salud OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 160228)
-- Name: adm_unidades_medicas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adm_unidades_medicas (
    id integer NOT NULL,
    clues character varying(11) NOT NULL,
    nombre character varying(255) NOT NULL,
    asentamiento_id integer,
    tipo_unidad character varying(255),
    estatus_operacion character varying(100),
    tiene_espirometro boolean DEFAULT false,
    es_servicio_amigable boolean DEFAULT false,
    activo boolean DEFAULT true,
    geom public.geometry(Point,4326),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.adm_unidades_medicas OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 160227)
-- Name: adm_unidades_medicas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adm_unidades_medicas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adm_unidades_medicas_id_seq OWNER TO postgres;

--
-- TOC entry 4658 (class 0 OID 0)
-- Dependencies: 238
-- Name: adm_unidades_medicas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adm_unidades_medicas_id_seq OWNED BY public.adm_unidades_medicas.id;


--
-- TOC entry 245 (class 1259 OID 160280)
-- Name: adm_usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adm_usuarios (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    curp character varying(18) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    activo boolean DEFAULT true,
    rol_id integer,
    ultimo_acceso timestamp without time zone,
    intentos_fallidos integer DEFAULT 0,
    bloqueado_hasta timestamp without time zone
);


ALTER TABLE public.adm_usuarios OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 160189)
-- Name: cat_asentamientos_cp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_asentamientos_cp (
    id integer NOT NULL,
    municipio_id integer,
    codigo_postal character varying(5) NOT NULL,
    nombre_colonia character varying(255) NOT NULL,
    tipo_asentamiento character varying(100),
    zona character varying(50)
);


ALTER TABLE public.cat_asentamientos_cp OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 160188)
-- Name: cat_asentamientos_cp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_asentamientos_cp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_asentamientos_cp_id_seq OWNER TO postgres;

--
-- TOC entry 4659 (class 0 OID 0)
-- Dependencies: 232
-- Name: cat_asentamientos_cp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_asentamientos_cp_id_seq OWNED BY public.cat_asentamientos_cp.id;


--
-- TOC entry 235 (class 1259 OID 160202)
-- Name: cat_cie10_diagnosticos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_cie10_diagnosticos (
    id integer NOT NULL,
    catalog_key character varying(10) NOT NULL,
    nombre text NOT NULL,
    lsex character varying(10) DEFAULT 'NO'::character varying,
    linf character varying(20),
    lsup character varying(20),
    es_suive_morb boolean DEFAULT false,
    metadatos jsonb,
    activo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cat_cie10_diagnosticos OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 160201)
-- Name: cat_cie10_diagnosticos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_cie10_diagnosticos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_cie10_diagnosticos_id_seq OWNER TO postgres;

--
-- TOC entry 4660 (class 0 OID 0)
-- Dependencies: 234
-- Name: cat_cie10_diagnosticos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_cie10_diagnosticos_id_seq OWNED BY public.cat_cie10_diagnosticos.id;


--
-- TOC entry 237 (class 1259 OID 160216)
-- Name: cat_cie9_procedimientos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_cie9_procedimientos (
    id integer NOT NULL,
    catalog_key character varying(10) NOT NULL,
    nombre text NOT NULL,
    sex_type character varying(2) DEFAULT '0'::character varying,
    procedimiento_type character(1),
    metadatos jsonb,
    activo boolean DEFAULT true
);


ALTER TABLE public.cat_cie9_procedimientos OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 160215)
-- Name: cat_cie9_procedimientos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_cie9_procedimientos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_cie9_procedimientos_id_seq OWNER TO postgres;

--
-- TOC entry 4661 (class 0 OID 0)
-- Dependencies: 236
-- Name: cat_cie9_procedimientos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_cie9_procedimientos_id_seq OWNED BY public.cat_cie9_procedimientos.id;


--
-- TOC entry 258 (class 1259 OID 160494)
-- Name: cat_doc_clasificacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_doc_clasificacion (
    id integer NOT NULL,
    clave character varying(20) NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    activo boolean DEFAULT true
);


ALTER TABLE public.cat_doc_clasificacion OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 160493)
-- Name: cat_doc_clasificacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_doc_clasificacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_doc_clasificacion_id_seq OWNER TO postgres;

--
-- TOC entry 4662 (class 0 OID 0)
-- Dependencies: 257
-- Name: cat_doc_clasificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_doc_clasificacion_id_seq OWNED BY public.cat_doc_clasificacion.id;


--
-- TOC entry 229 (class 1259 OID 160166)
-- Name: cat_entidades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_entidades (
    id integer NOT NULL,
    clave character varying(5) NOT NULL,
    nombre character varying(100) NOT NULL,
    abreviatura character varying(10)
);


ALTER TABLE public.cat_entidades OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 160165)
-- Name: cat_entidades_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_entidades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_entidades_id_seq OWNER TO postgres;

--
-- TOC entry 4663 (class 0 OID 0)
-- Dependencies: 228
-- Name: cat_entidades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_entidades_id_seq OWNED BY public.cat_entidades.id;


--
-- TOC entry 244 (class 1259 OID 160265)
-- Name: cat_matriz_personal_servicio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_matriz_personal_servicio (
    tipo_personal_id integer NOT NULL,
    servicio_atencion_id integer NOT NULL
);


ALTER TABLE public.cat_matriz_personal_servicio OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 160175)
-- Name: cat_municipios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_municipios (
    id integer NOT NULL,
    entidad_id integer,
    clave character varying(10) NOT NULL,
    nombre character varying(150) NOT NULL
);


ALTER TABLE public.cat_municipios OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 160174)
-- Name: cat_municipios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_municipios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_municipios_id_seq OWNER TO postgres;

--
-- TOC entry 4664 (class 0 OID 0)
-- Dependencies: 230
-- Name: cat_municipios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_municipios_id_seq OWNED BY public.cat_municipios.id;


--
-- TOC entry 256 (class 1259 OID 160466)
-- Name: cat_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_roles (
    id integer NOT NULL,
    clave character varying(20) NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    activo boolean DEFAULT true
);


ALTER TABLE public.cat_roles OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 160465)
-- Name: cat_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_roles_id_seq OWNER TO postgres;

--
-- TOC entry 4665 (class 0 OID 0)
-- Dependencies: 255
-- Name: cat_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_roles_id_seq OWNED BY public.cat_roles.id;


--
-- TOC entry 243 (class 1259 OID 160257)
-- Name: cat_servicios_atencion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_servicios_atencion (
    id integer NOT NULL,
    clave character varying(10) NOT NULL,
    descripcion character varying(150) NOT NULL
);


ALTER TABLE public.cat_servicios_atencion OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 160256)
-- Name: cat_servicios_atencion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_servicios_atencion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_servicios_atencion_id_seq OWNER TO postgres;

--
-- TOC entry 4666 (class 0 OID 0)
-- Dependencies: 242
-- Name: cat_servicios_atencion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_servicios_atencion_id_seq OWNED BY public.cat_servicios_atencion.id;


--
-- TOC entry 241 (class 1259 OID 160248)
-- Name: cat_tipos_personal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cat_tipos_personal (
    id integer NOT NULL,
    clave character varying(10) NOT NULL,
    descripcion character varying(150) NOT NULL
);


ALTER TABLE public.cat_tipos_personal OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 160247)
-- Name: cat_tipos_personal_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cat_tipos_personal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cat_tipos_personal_id_seq OWNER TO postgres;

--
-- TOC entry 4667 (class 0 OID 0)
-- Dependencies: 240
-- Name: cat_tipos_personal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cat_tipos_personal_id_seq OWNED BY public.cat_tipos_personal.id;


--
-- TOC entry 249 (class 1259 OID 160362)
-- Name: clin_atenciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clin_atenciones (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    paciente_id uuid NOT NULL,
    cita_id uuid,
    unidad_medica_id integer NOT NULL,
    personal_salud_id uuid NOT NULL,
    fecha_atencion date NOT NULL,
    datos_atencion jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
)
PARTITION BY RANGE (fecha_atencion);


ALTER TABLE public.clin_atenciones OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 160381)
-- Name: clin_atenciones_2026; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clin_atenciones_2026 (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    paciente_id uuid NOT NULL,
    cita_id uuid,
    unidad_medica_id integer NOT NULL,
    personal_salud_id uuid NOT NULL,
    fecha_atencion date NOT NULL,
    datos_atencion jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.clin_atenciones_2026 OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 160336)
-- Name: clin_citas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clin_citas (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    paciente_id uuid NOT NULL,
    unidad_medica_id integer NOT NULL,
    personal_salud_id uuid,
    fecha_hora_cita timestamp without time zone NOT NULL,
    estatus_cita character varying(50) DEFAULT 'PROGRAMADA'::character varying,
    motivo_cita text,
    notas_adicionales text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.clin_citas OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 160312)
-- Name: clin_pacientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clin_pacientes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    numero_expediente_global character varying(50) NOT NULL,
    curp character varying(18) NOT NULL,
    nombre character varying(100) NOT NULL,
    primer_apellido character varying(100) NOT NULL,
    segundo_apellido character varying(100),
    fecha_nacimiento date NOT NULL,
    sexo_id integer,
    asentamiento_id integer,
    datos_clinicos jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    es_identidad_desconocida boolean DEFAULT false
);


ALTER TABLE public.clin_pacientes OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 160505)
-- Name: doc_expediente_digital; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doc_expediente_digital (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    paciente_id uuid NOT NULL,
    atencion_id uuid,
    clasificacion_id integer NOT NULL,
    nombre_archivo character varying(255) NOT NULL,
    ruta_almacenamiento text NOT NULL,
    tipo_mime character varying(100) NOT NULL,
    tamano_bytes bigint,
    hash_integridad character varying(256) NOT NULL,
    subido_por_usuario_id uuid NOT NULL,
    fecha_subida timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    observaciones text,
    activo boolean DEFAULT true
);


ALTER TABLE public.doc_expediente_digital OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 160129)
-- Name: gui_diccionario_opciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gui_diccionario_opciones (
    id integer NOT NULL,
    diccionario_id integer,
    parent_id integer,
    clave character varying(50) NOT NULL,
    valor text NOT NULL,
    metadatos jsonb,
    activo boolean DEFAULT true,
    orden integer DEFAULT 0
);


ALTER TABLE public.gui_diccionario_opciones OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 160128)
-- Name: gui_diccionario_opciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gui_diccionario_opciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gui_diccionario_opciones_id_seq OWNER TO postgres;

--
-- TOC entry 4668 (class 0 OID 0)
-- Dependencies: 225
-- Name: gui_diccionario_opciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gui_diccionario_opciones_id_seq OWNED BY public.gui_diccionario_opciones.id;


--
-- TOC entry 224 (class 1259 OID 160118)
-- Name: gui_diccionarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gui_diccionarios (
    id integer NOT NULL,
    codigo character varying(100) NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion text,
    es_sistema boolean DEFAULT false
);


ALTER TABLE public.gui_diccionarios OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 160117)
-- Name: gui_diccionarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.gui_diccionarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gui_diccionarios_id_seq OWNER TO postgres;

--
-- TOC entry 4669 (class 0 OID 0)
-- Dependencies: 223
-- Name: gui_diccionarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.gui_diccionarios_id_seq OWNED BY public.gui_diccionarios.id;


--
-- TOC entry 227 (class 1259 OID 160150)
-- Name: rel_normatividad_opciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rel_normatividad_opciones (
    normatividad_id integer NOT NULL,
    opcion_id integer NOT NULL
);


ALTER TABLE public.rel_normatividad_opciones OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 160098)
-- Name: sys_adopcion_catalogos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_adopcion_catalogos (
    id integer NOT NULL,
    normatividad_id integer,
    catalogo_nombre character varying(100),
    registro_importacion_id integer,
    fecha_adopcion date DEFAULT CURRENT_DATE,
    comentarios text
);


ALTER TABLE public.sys_adopcion_catalogos OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 160097)
-- Name: sys_adopcion_catalogos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_adopcion_catalogos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_adopcion_catalogos_id_seq OWNER TO postgres;

--
-- TOC entry 4670 (class 0 OID 0)
-- Dependencies: 221
-- Name: sys_adopcion_catalogos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_adopcion_catalogos_id_seq OWNED BY public.sys_adopcion_catalogos.id;


--
-- TOC entry 260 (class 1259 OID 160537)
-- Name: sys_bitacora_auditoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_bitacora_auditoria (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    usuario_id uuid,
    accion character varying(20) NOT NULL,
    tabla_afectada character varying(100) NOT NULL,
    registro_id character varying(100) NOT NULL,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    fecha_accion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    direccion_ip character varying(50),
    user_agent text
);


ALTER TABLE public.sys_bitacora_auditoria OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 160416)
-- Name: sys_giis_campos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_giis_campos (
    id integer NOT NULL,
    normatividad_id integer,
    orden integer NOT NULL,
    nombre_campo character varying(100) NOT NULL,
    descripcion text,
    tipo_dato character varying(30) NOT NULL,
    longitud_maxima integer,
    obligatorio boolean DEFAULT false,
    confidencial boolean DEFAULT false,
    catalogo_asociado character varying(100),
    tipo_validacion character varying(20) DEFAULT 'CATALOGO'::character varying,
    fuente_catalogo character varying(50)
);


ALTER TABLE public.sys_giis_campos OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 160415)
-- Name: sys_giis_campos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_giis_campos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_giis_campos_id_seq OWNER TO postgres;

--
-- TOC entry 4671 (class 0 OID 0)
-- Dependencies: 251
-- Name: sys_giis_campos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_giis_campos_id_seq OWNED BY public.sys_giis_campos.id;


--
-- TOC entry 254 (class 1259 OID 160435)
-- Name: sys_giis_restricciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_giis_restricciones (
    id integer NOT NULL,
    normatividad_id integer,
    campo_id integer,
    nombre_regla character varying(100) NOT NULL,
    tipo_regla character varying(50) NOT NULL,
    expresion jsonb NOT NULL,
    mensaje_error text NOT NULL,
    nivel character varying(20) DEFAULT 'ERROR'::character varying,
    fecha_inicio date NOT NULL
);


ALTER TABLE public.sys_giis_restricciones OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 160434)
-- Name: sys_giis_restricciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_giis_restricciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_giis_restricciones_id_seq OWNER TO postgres;

--
-- TOC entry 4672 (class 0 OID 0)
-- Dependencies: 253
-- Name: sys_giis_restricciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_giis_restricciones_id_seq OWNED BY public.sys_giis_restricciones.id;


--
-- TOC entry 218 (class 1259 OID 160073)
-- Name: sys_normatividad_giis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_normatividad_giis (
    id integer NOT NULL,
    clave character varying(50),
    nombre_documento character varying(255),
    version character varying(20),
    fecha_publicacion date,
    url_pdf character varying(500),
    estatus character varying(20) DEFAULT 'ACTIVO'::character varying,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sys_normatividad_giis OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 160072)
-- Name: sys_normatividad_giis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_normatividad_giis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_normatividad_giis_id_seq OWNER TO postgres;

--
-- TOC entry 4673 (class 0 OID 0)
-- Dependencies: 217
-- Name: sys_normatividad_giis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_normatividad_giis_id_seq OWNED BY public.sys_normatividad_giis.id;


--
-- TOC entry 220 (class 1259 OID 160086)
-- Name: sys_registro_catalogos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sys_registro_catalogos (
    id integer NOT NULL,
    archivo_origen character varying(255),
    tabla_destino character varying(255),
    criterios_carga text,
    version character varying(50) DEFAULT '1.0 (Carga Inicial)'::character varying,
    estatus character varying(20) DEFAULT 'ACTIVO'::character varying,
    fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sys_registro_catalogos OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 160085)
-- Name: sys_registro_catalogos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sys_registro_catalogos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sys_registro_catalogos_id_seq OWNER TO postgres;

--
-- TOC entry 4674 (class 0 OID 0)
-- Dependencies: 219
-- Name: sys_registro_catalogos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sys_registro_catalogos_id_seq OWNED BY public.sys_registro_catalogos.id;


--
-- TOC entry 4259 (class 0 OID 0)
-- Name: clin_atenciones_2026; Type: TABLE ATTACH; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_atenciones ATTACH PARTITION public.clin_atenciones_2026 FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');


--
-- TOC entry 4285 (class 2604 OID 160231)
-- Name: adm_unidades_medicas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_unidades_medicas ALTER COLUMN id SET DEFAULT nextval('public.adm_unidades_medicas_id_seq'::regclass);


--
-- TOC entry 4276 (class 2604 OID 160192)
-- Name: cat_asentamientos_cp id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_asentamientos_cp ALTER COLUMN id SET DEFAULT nextval('public.cat_asentamientos_cp_id_seq'::regclass);


--
-- TOC entry 4277 (class 2604 OID 160205)
-- Name: cat_cie10_diagnosticos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie10_diagnosticos ALTER COLUMN id SET DEFAULT nextval('public.cat_cie10_diagnosticos_id_seq'::regclass);


--
-- TOC entry 4282 (class 2604 OID 160219)
-- Name: cat_cie9_procedimientos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie9_procedimientos ALTER COLUMN id SET DEFAULT nextval('public.cat_cie9_procedimientos_id_seq'::regclass);


--
-- TOC entry 4317 (class 2604 OID 160497)
-- Name: cat_doc_clasificacion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_doc_clasificacion ALTER COLUMN id SET DEFAULT nextval('public.cat_doc_clasificacion_id_seq'::regclass);


--
-- TOC entry 4274 (class 2604 OID 160169)
-- Name: cat_entidades id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_entidades ALTER COLUMN id SET DEFAULT nextval('public.cat_entidades_id_seq'::regclass);


--
-- TOC entry 4275 (class 2604 OID 160178)
-- Name: cat_municipios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_municipios ALTER COLUMN id SET DEFAULT nextval('public.cat_municipios_id_seq'::regclass);


--
-- TOC entry 4315 (class 2604 OID 160469)
-- Name: cat_roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_roles ALTER COLUMN id SET DEFAULT nextval('public.cat_roles_id_seq'::regclass);


--
-- TOC entry 4292 (class 2604 OID 160260)
-- Name: cat_servicios_atencion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_servicios_atencion ALTER COLUMN id SET DEFAULT nextval('public.cat_servicios_atencion_id_seq'::regclass);


--
-- TOC entry 4291 (class 2604 OID 160251)
-- Name: cat_tipos_personal id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_tipos_personal ALTER COLUMN id SET DEFAULT nextval('public.cat_tipos_personal_id_seq'::regclass);


--
-- TOC entry 4271 (class 2604 OID 160132)
-- Name: gui_diccionario_opciones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gui_diccionario_opciones ALTER COLUMN id SET DEFAULT nextval('public.gui_diccionario_opciones_id_seq'::regclass);


--
-- TOC entry 4269 (class 2604 OID 160121)
-- Name: gui_diccionarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gui_diccionarios ALTER COLUMN id SET DEFAULT nextval('public.gui_diccionarios_id_seq'::regclass);


--
-- TOC entry 4267 (class 2604 OID 160101)
-- Name: sys_adopcion_catalogos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_adopcion_catalogos ALTER COLUMN id SET DEFAULT nextval('public.sys_adopcion_catalogos_id_seq'::regclass);


--
-- TOC entry 4309 (class 2604 OID 160419)
-- Name: sys_giis_campos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_giis_campos ALTER COLUMN id SET DEFAULT nextval('public.sys_giis_campos_id_seq'::regclass);


--
-- TOC entry 4313 (class 2604 OID 160438)
-- Name: sys_giis_restricciones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_giis_restricciones ALTER COLUMN id SET DEFAULT nextval('public.sys_giis_restricciones_id_seq'::regclass);


--
-- TOC entry 4260 (class 2604 OID 160076)
-- Name: sys_normatividad_giis id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_normatividad_giis ALTER COLUMN id SET DEFAULT nextval('public.sys_normatividad_giis_id_seq'::regclass);


--
-- TOC entry 4263 (class 2604 OID 160089)
-- Name: sys_registro_catalogos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_registro_catalogos ALTER COLUMN id SET DEFAULT nextval('public.sys_registro_catalogos_id_seq'::regclass);


--
-- TOC entry 4635 (class 0 OID 160291)
-- Dependencies: 246
-- Data for Name: adm_personal_salud; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4628 (class 0 OID 160228)
-- Dependencies: 239
-- Data for Name: adm_unidades_medicas; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4634 (class 0 OID 160280)
-- Dependencies: 245
-- Data for Name: adm_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4622 (class 0 OID 160189)
-- Dependencies: 233
-- Data for Name: cat_asentamientos_cp; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4624 (class 0 OID 160202)
-- Dependencies: 235
-- Data for Name: cat_cie10_diagnosticos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4626 (class 0 OID 160216)
-- Dependencies: 237
-- Data for Name: cat_cie9_procedimientos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4646 (class 0 OID 160494)
-- Dependencies: 258
-- Data for Name: cat_doc_clasificacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cat_doc_clasificacion VALUES (1, 'DOC-CONSENTIMIENTO', 'Consentimiento Informado', 'Documentos firmados por el paciente aceptando procedimientos', true);
INSERT INTO public.cat_doc_clasificacion VALUES (2, 'DOC-LABORATORIO', 'Resultados de Laboratorio', 'Estudios de sangre, orina, patología (PDF)', true);
INSERT INTO public.cat_doc_clasificacion VALUES (3, 'DOC-IMAGENOLOGIA', 'Resultados de Imagenología', 'Rayos X, Ultrasonidos, Mastografías (PDF o DICOM)', true);
INSERT INTO public.cat_doc_clasificacion VALUES (4, 'DOC-IDENTIFICACION', 'Documento de Identidad', 'INE, Pasaporte, Acta de Nacimiento escaneada', true);
INSERT INTO public.cat_doc_clasificacion VALUES (5, 'DOC-REFERENCIA', 'Hoja de Referencia/Contrarreferencia', 'Documentos físicos escaneados de traslados a otros hospitales', true);
INSERT INTO public.cat_doc_clasificacion VALUES (6, 'DOC-OTROS', 'Otros Documentos Clínicos', 'Cualquier otro documento adjunto al expediente', true);


--
-- TOC entry 4618 (class 0 OID 160166)
-- Dependencies: 229
-- Data for Name: cat_entidades; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4633 (class 0 OID 160265)
-- Dependencies: 244
-- Data for Name: cat_matriz_personal_servicio; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4620 (class 0 OID 160175)
-- Dependencies: 231
-- Data for Name: cat_municipios; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4644 (class 0 OID 160466)
-- Dependencies: 256
-- Data for Name: cat_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cat_roles VALUES (1, 'SUPERADMIN', 'Super Administrador', 'Acceso total y configuración del sistema HIS', true);
INSERT INTO public.cat_roles VALUES (2, 'MEDICO', 'Médico Tratante', 'Acceso a consulta, expediente clínico y recetas', true);
INSERT INTO public.cat_roles VALUES (3, 'ENFERMERIA', 'Personal de Enfermería', 'Acceso a triage, somatometría y aplicación de medicamentos', true);
INSERT INTO public.cat_roles VALUES (4, 'TRABAJO_SOCIAL', 'Trabajo Social', 'Acceso a estudios socioeconómicos y referencias', true);
INSERT INTO public.cat_roles VALUES (5, 'RECEPCION', 'Recepción y Archivo', 'Acceso a agenda y registro demográfico de pacientes', true);


--
-- TOC entry 4632 (class 0 OID 160257)
-- Dependencies: 243
-- Data for Name: cat_servicios_atencion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4630 (class 0 OID 160248)
-- Dependencies: 241
-- Data for Name: cat_tipos_personal; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4638 (class 0 OID 160381)
-- Dependencies: 250
-- Data for Name: clin_atenciones_2026; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4637 (class 0 OID 160336)
-- Dependencies: 248
-- Data for Name: clin_citas; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4636 (class 0 OID 160312)
-- Dependencies: 247
-- Data for Name: clin_pacientes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4647 (class 0 OID 160505)
-- Dependencies: 259
-- Data for Name: doc_expediente_digital; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4615 (class 0 OID 160129)
-- Dependencies: 226
-- Data for Name: gui_diccionario_opciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.gui_diccionario_opciones VALUES (1, 1, NULL, '1', 'CURACION', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (2, 1, NULL, '2', 'MEJORIA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (3, 1, NULL, '3', 'VOLUNTAD PROPIA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (4, 1, NULL, '4', 'TRASLADO A OTRA UNIDAD', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (5, 1, NULL, '5', 'DEFUNCION', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (6, 1, NULL, '6', 'FUGA', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (7, 1, NULL, '7', 'OTRO', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (8, 2, NULL, '1', 'CONSULTA EXTERNA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (9, 2, NULL, '2', 'URGENCIAS', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (10, 2, NULL, '3', 'REFERIDO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (11, 2, NULL, '4', 'CUNERO PATOLOGICO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (12, 2, NULL, '5', 'OTRO', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (13, 3, NULL, '1', 'NORMAL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (14, 3, NULL, '2', 'CORTA ESTANCIA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (15, 4, NULL, '1', 'ABORTO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (16, 4, NULL, '2', 'PARTO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (17, 5, NULL, '1', 'EUTOCICO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (18, 5, NULL, '2', 'DISTOCICO VAGINAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (19, 5, NULL, '3', 'CESAREA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (20, 5, NULL, '9', 'NO ESPECIFICADO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (21, 6, NULL, '1', 'DENTRO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (22, 6, NULL, '2', 'FUERA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (23, 7, NULL, '1', 'SI', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (24, 7, NULL, '2', 'NO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (25, 7, NULL, '8', 'SE IGNORA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (26, 7, NULL, '9', 'NO ESPECIFICADO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (27, 8, NULL, '1', 'GENERAL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (28, 8, NULL, '2', 'REGIONAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (29, 8, NULL, '3', 'SEDACION', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (30, 8, NULL, '4', 'LOCAL', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (31, 8, NULL, '5', 'COMBINADA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (32, 8, NULL, '6', 'NO USO', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (33, 9, NULL, '1', 'EMBARAZO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (34, 9, NULL, '2', 'PUERPERIO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (35, 9, NULL, '3', 'NO ESTABA EMBARAZADA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (36, 10, NULL, '0', 'NINGUNO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (37, 10, NULL, '1', 'HORMONAL ORAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (38, 10, NULL, '2', 'INYECTABLE MENSUAL', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (39, 10, NULL, '4', 'IMPLANTE SUBDERMICO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (40, 10, NULL, '5', 'DIU', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (41, 10, NULL, '10', 'OTB', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (42, 10, NULL, '11', 'OTRO METODO', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (43, 11, NULL, '1', 'PRIMERA VEZ', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (44, 11, NULL, '2', 'SUBSECUENTE', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (45, 12, NULL, '1', 'NACIDO MUERTO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (46, 12, NULL, '2', 'NACIDO VIVO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (47, 13, NULL, '1', 'URGENCIA CALIFICADA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (48, 13, NULL, '2', 'URGENCIA NO CALIFICADA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (49, 14, NULL, '1', 'ACCIDENTES, ENVENENAMIENTO Y VIOLENCIAS', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (50, 14, NULL, '2', 'MEDICA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (51, 14, NULL, '3', 'GINECO-OBSTETRICA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (52, 14, NULL, '4', 'PEDIATRICA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (53, 15, NULL, '1', 'CAMA DE OBSERVACION', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (54, 15, NULL, '2', 'CAMA DE CHOQUE', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (55, 15, NULL, '3', 'SIN CAMA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (56, 15, NULL, '9', 'NO ESPECIFICADO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (57, 16, NULL, '1', 'HOSPITALIZACION', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (58, 16, NULL, '2', 'CONSULTA EXTERNA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (59, 16, NULL, '3', 'TRASLADO A OTRA UNIDAD', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (60, 16, NULL, '4', 'DOMICILIO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (61, 16, NULL, '5', 'DEFUNCION', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (62, 16, NULL, '6', 'FUGA', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (63, 16, NULL, '7', 'VOLUNTAD PROPIA', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (64, 17, NULL, '1', 'SINTOMATICO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (65, 17, NULL, '2', 'ANTIBIOTICO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (66, 17, NULL, '3', 'ANTIVIRALES', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (67, 18, NULL, '1', 'PLAN A', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (68, 18, NULL, '2', 'PLAN B', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (69, 18, NULL, '3', 'PLAN C', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (74, 20, NULL, '1', 'UNIDAD MEDICA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (75, 20, NULL, '2', 'PROCURACION DE JUSTICIA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (76, 20, NULL, '3', 'SECRETARIA DE EDUCACION', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (77, 20, NULL, '4', 'DESARROLLO SOCIAL', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (78, 20, NULL, '5', 'DIF', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (79, 20, NULL, '6', 'OTRAS INSTITUCIONES GUBERNAMENTALES', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (80, 20, NULL, '7', 'INSTITUCIONES NO GUBERNAMENTALES', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (81, 20, NULL, '8', 'SIN REFERENCIA (Iniciativa Propia)', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (82, 21, NULL, '1', 'ALCOHOL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (83, 21, NULL, '2', 'DROGA POR INDICACION MEDICA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (84, 21, NULL, '3', 'DROGAS ILEGALES', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (85, 21, NULL, '4', 'SE IGNORA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (86, 21, NULL, '5', 'NINGUNA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (87, 22, NULL, '1', 'ACCIDENTAL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (88, 22, NULL, '2', 'VIOLENCIA FAMILIAR', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (89, 22, NULL, '3', 'VIOLENCIA NO FAMILIAR', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (90, 22, NULL, '4', 'AUTO INFLIGIDO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (91, 22, NULL, '11', 'TRATA DE PERSONAS', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (92, 23, NULL, '1', 'UNICA VEZ', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (93, 23, NULL, '2', 'REPETIDO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (94, 24, NULL, '1', 'CONDUCTOR', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (95, 24, NULL, '2', 'OCUPANTE', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (96, 24, NULL, '3', 'PEATON', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (97, 24, NULL, '4', 'SE IGNORA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (98, 25, NULL, '1', 'CINTURON DE SEGURIDAD', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (99, 25, NULL, '2', 'CASCO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (100, 25, NULL, '3', 'SILLA PORTA INFANTE', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (101, 25, NULL, '4', 'OTRO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (102, 26, NULL, '6', 'VIOLENCIA FISICA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (103, 26, NULL, '7', 'VIOLENCIA SEXUAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (104, 26, NULL, '8', 'VIOLENCIA PSICOLOGICA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (105, 26, NULL, '9', 'VIOLENCIA ECONOMICA / PATRIMONIAL', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (106, 26, NULL, '10', 'ABANDONO Y/O NEGLIGENCIA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (107, 27, NULL, '1', 'UNICO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (108, 27, NULL, '2', 'MAS DE UNO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (109, 27, NULL, '3', 'NO ESPECIFICADO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (110, 28, NULL, '0', 'NO ESPECIFICADO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (111, 28, NULL, '1', 'PADRE', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (112, 28, NULL, '2', 'MADRE', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (113, 28, NULL, '3', 'CONYUGE/PAREJA/NOVIO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (114, 28, NULL, '4', 'OTRO PARIENTE', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (115, 28, NULL, '5', 'PADRASTRO', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (116, 28, NULL, '6', 'MADRASTRA', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (117, 28, NULL, '7', 'CONOCIDO SIN PARENTESCO', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (118, 28, NULL, '8', 'DESCONOCIDO', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (119, 28, NULL, '9', 'HIJA/HIJO', NULL, true, 10);
INSERT INTO public.gui_diccionario_opciones VALUES (120, 28, NULL, '10', 'OTRO', NULL, true, 11);
INSERT INTO public.gui_diccionario_opciones VALUES (121, 28, NULL, '99', 'SE IGNORA', NULL, true, 12);
INSERT INTO public.gui_diccionario_opciones VALUES (122, 29, NULL, '1', 'CONSULTA EXTERNA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (123, 29, NULL, '2', 'HOSPITALIZACION', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (124, 29, NULL, '3', 'URGENCIAS', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (125, 29, NULL, '4', 'SERVICIO ESPECIALIZADO DE ATENCION A LA VIOLENCIA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (126, 29, NULL, '5', 'OTRO SERVICIO', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (127, 30, NULL, '1', 'TRATAMIENTO MEDICO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (128, 30, NULL, '2', 'TRATAMIENTO PSICOLOGICO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (129, 30, NULL, '3', 'TRATAMIENTO QUIRURGICO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (130, 30, NULL, '4', 'TRATAMIENTO PSIQUIATRICO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (131, 30, NULL, '5', 'CONSEJERIA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (132, 30, NULL, '6', 'OTRO', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (133, 30, NULL, '7', 'PILDORA ANTICONCEPTIVA DE EMERGENCIA', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (134, 30, NULL, '8', 'PROFILAXIS VIH', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (135, 30, NULL, '9', 'PROFILAXIS OTRAS ITS', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (136, 31, NULL, '1', 'DOMICILIO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (137, 31, NULL, '2', 'TRASLADO A OTRA UNIDAD MEDICA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (138, 31, NULL, '3', 'SERVICIO ESPECIALIZADO ATENCION A LA VIOLENCIA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (139, 31, NULL, '4', 'CONSULTA EXTERNA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (140, 31, NULL, '5', 'DEFUNCION', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (141, 31, NULL, '6', 'REFUGIO O ALBERGUE', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (142, 31, NULL, '7', 'DIF', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (143, 31, NULL, '8', 'HOSPITALIZACION', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (144, 31, NULL, '9', 'MINISTERIO PUBLICO', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (145, 31, NULL, '10', 'GRUPO DE AYUDA MUTUA', NULL, true, 10);
INSERT INTO public.gui_diccionario_opciones VALUES (146, 31, NULL, '11', 'OTRO', NULL, true, 11);
INSERT INTO public.gui_diccionario_opciones VALUES (147, 32, NULL, '1', 'MEDICO TRATANTE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (148, 32, NULL, '2', 'PSICOLOGO TRATANTE', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (149, 32, NULL, '3', 'TRABAJADORA SOCIAL', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (150, 33, NULL, '12', 'PASANTE EN ODONTOLOGIA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (151, 33, NULL, '13', 'ODONTOLOGA (O)', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (152, 33, NULL, '14', 'ODONTOLOGA (O) ESPECIALISTA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (153, 33, NULL, '23', 'TECNICA(O) EN ODONTOLOGIA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (154, 34, NULL, '1', 'HOMBRE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (155, 34, NULL, '2', 'MUJER', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (156, 34, NULL, '3', 'NO BINARIO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (157, 35, NULL, '1', 'HOMBRE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (158, 35, NULL, '2', 'MUJER', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (159, 35, NULL, '3', 'INTERSEXUAL', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (160, 36, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (161, 36, NULL, '1', 'SI', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (162, 36, NULL, '2', 'NO RESPONDE', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (163, 36, NULL, '3', 'NO SABE', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (164, 37, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (165, 37, NULL, '1', 'NACIONAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (166, 37, NULL, '2', 'INTERNACIONAL', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (167, 37, NULL, '3', 'RETORNADO (Sólo nacional)', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (168, 38, NULL, '0', 'NO ESPECIFICADO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (169, 38, NULL, '1', 'MASCULINO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (170, 38, NULL, '2', 'FEMENINO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (171, 38, NULL, '3', 'TRANSGENERO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (172, 38, NULL, '4', 'TRANSEXUAL', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (173, 38, NULL, '5', 'TRAVESTI', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (174, 38, NULL, '6', 'INTERSEXUAL', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (175, 38, NULL, '88', 'OTRO', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (176, 39, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (177, 39, NULL, '1', 'SI', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (178, 40, NULL, '0', 'PRIMERA VEZ', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (179, 40, NULL, '1', 'SUBSECUENTE', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (180, 41, NULL, '1', 'USG', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (181, 41, NULL, '2', 'ECG', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (182, 41, NULL, '3', 'RAYOS X', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (183, 41, NULL, '4', 'TOMOGRAFIA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (184, 41, NULL, '5', 'RESONANCIA MAGNETICA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (185, 41, NULL, '6', 'MASTOGRAFIA', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (186, 41, NULL, '7', 'OTROS', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (187, 42, NULL, '1', 'EN TIEMPO REAL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (188, 42, NULL, '2', 'DIFERIDA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (228, 53, NULL, '15', 'PASANTE DE PSICOLOGÍA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (229, 53, NULL, '16', 'PSICÓLOGA (O)', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (230, 53, NULL, '17', 'RESIDENTE DE PSIQUIATRÍA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (231, 53, NULL, '18', 'PSIQUIATRA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (232, 53, NULL, '19', 'MÉDICA(O) GENERAL HABILITADO PARA SALUD MENTAL', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (233, 53, NULL, '24', 'MÉDICA(O) ESPECIALISTA HABILITADO PARA SALUD MENTAL', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (234, 53, NULL, '25', 'LICENCIADA(O) EN GERONTOLOGÍA', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (235, 53, NULL, '27', 'PASANTE EN GERONTOLOGÍA', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (236, 54, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (237, 54, NULL, '1', 'SI', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (238, 55, NULL, '1', 'ALCOHOL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (239, 55, NULL, '2', 'TABACO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (240, 55, NULL, '3', 'CANNABIS', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (241, 55, NULL, '4', 'COCAINA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (242, 55, NULL, '5', 'METANFETAMINAS', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (243, 55, NULL, '6', 'INHALABLES', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (244, 55, NULL, '7', 'OPIACEOS', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (245, 55, NULL, '8', 'ALUCINOGENOS', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (246, 55, NULL, '9', 'BENZODIACEPINAS', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (247, 55, NULL, '10', 'OTROS', NULL, true, 10);
INSERT INTO public.gui_diccionario_opciones VALUES (248, 56, NULL, '1', 'PRIMARIA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (249, 56, NULL, '2', 'COMORBILIDAD', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (250, 56, NULL, '3', 'DETECTADO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (251, 57, NULL, '1', 'EPISODIO UNICO DE CONSUMO NOCIVO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (252, 57, NULL, '2', 'CONSUMO PELIGROSO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (253, 57, NULL, '3', 'PATRON NOCIVO DE CONSUMO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (254, 57, NULL, '4', 'DEPENDENCIA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (255, 58, NULL, '1', 'FAMILIAR', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (256, 58, NULL, '2', 'COMUNITARIA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (257, 58, NULL, '3', 'COLECTIVA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (258, 59, NULL, '1', 'VIOLENCIA PSICOLOGICA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (259, 59, NULL, '2', 'VIOLENCIA FISICA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (260, 59, NULL, '3', 'VIOLENCIA PATRIMONIAL', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (261, 59, NULL, '4', 'VIOLENCIA ECONOMICA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (262, 59, NULL, '5', 'VIOLENCIA SEXUAL', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (263, 60, NULL, '1', 'AUTOLESION SIN RIESGO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (264, 60, NULL, '2', 'AUTOLESION CON RIESGO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (265, 60, NULL, '3', 'IDEACION', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (266, 60, NULL, '4', 'INTENTO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (267, 61, NULL, '1', 'APLICACION DE PRUEBAS', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (268, 61, NULL, '2', 'CALIFICACION DE PRUEBAS', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (269, 61, NULL, '3', 'INTEGRACION DE LA EVALUACION', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (270, 61, NULL, '4', 'ENTREGA DE RESULTADOS', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (271, 62, NULL, '1', 'INDIVIDUAL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (272, 62, NULL, '2', 'GRUPAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (273, 62, NULL, '3', 'PAREJA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (274, 62, NULL, '4', 'FAMILIAR', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (275, 62, NULL, '5', 'POSTVENCION', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (276, 63, NULL, '1', 'MÉDICA(O) PASANTE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (277, 63, NULL, '2', 'MÉDICA(O) GENERAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (278, 63, NULL, '3', 'MÉDICA(O) RESIDENTE', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (279, 63, NULL, '4', 'MÉDICA(O) ESPECIALISTA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (280, 63, NULL, '5', 'PASANTE DE ENFERMERÍA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (281, 63, NULL, '6', 'ENFERMERA(O)', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (282, 63, NULL, '9', 'HOMEÓPATA', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (283, 63, NULL, '10', 'MÉDICA(O) TRADICIONAL INDÍGENA', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (284, 63, NULL, '11', 'TAPS', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (285, 63, NULL, '15', 'PASANTE DE PSICOLOGÍA', NULL, true, 10);
INSERT INTO public.gui_diccionario_opciones VALUES (286, 63, NULL, '16', 'PSICÓLOGA(O)', NULL, true, 11);
INSERT INTO public.gui_diccionario_opciones VALUES (287, 63, NULL, '19', 'MÉDICA(O) GENERAL HABILITADA(O) PARA SM', NULL, true, 12);
INSERT INTO public.gui_diccionario_opciones VALUES (288, 63, NULL, '20', 'LICENCIADA(O) EN ENFERMERÍA Y OBSTETRICIA', NULL, true, 13);
INSERT INTO public.gui_diccionario_opciones VALUES (289, 63, NULL, '21', 'PARTERA (O) TÉCNICA', NULL, true, 14);
INSERT INTO public.gui_diccionario_opciones VALUES (290, 63, NULL, '22', 'PROMOTOR(A) DE SALUD', NULL, true, 15);
INSERT INTO public.gui_diccionario_opciones VALUES (291, 63, NULL, '24', 'MÉDICA(O) ESPECIALISTA HABILITADO PARA SM', NULL, true, 16);
INSERT INTO public.gui_diccionario_opciones VALUES (292, 64, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (293, 64, NULL, '1', 'SI', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (294, 65, NULL, '1', 'HOMBRE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (295, 65, NULL, '2', 'MUJER', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (296, 65, NULL, '3', 'NO BINARIO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (297, 66, NULL, '1', 'HOMBRE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (298, 66, NULL, '2', 'MUJER', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (299, 66, NULL, '3', 'INTERSEXUAL', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (300, 67, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (301, 67, NULL, '1', 'SI', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (302, 67, NULL, '2', 'NO RESPONDE', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (303, 67, NULL, '3', 'NO SABE', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (304, 68, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (305, 68, NULL, '1', 'NACIONAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (306, 68, NULL, '2', 'INTERNACIONAL', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (307, 68, NULL, '3', 'RETORNADO (Sólo nacional)', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (308, 69, NULL, '0', 'NO ESPECIFICADO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (309, 69, NULL, '1', 'MASCULINO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (310, 69, NULL, '2', 'FEMENINO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (311, 69, NULL, '3', 'TRANSGENERO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (312, 69, NULL, '4', 'TRANSEXUAL', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (313, 69, NULL, '5', 'TRAVESTI', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (314, 69, NULL, '6', 'INTERSEXUAL', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (315, 69, NULL, '88', 'OTRO', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (316, 70, NULL, '1', 'USG', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (317, 70, NULL, '2', 'ECG', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (318, 70, NULL, '3', 'RAYOS X', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (319, 70, NULL, '4', 'TOMOGRAFIA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (320, 70, NULL, '5', 'RESONANCIA MAGNETICA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (321, 70, NULL, '6', 'MASTOGRAFIA', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (322, 70, NULL, '7', 'OTROS', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (323, 71, NULL, '0', 'REVISION SIN COLOCACION DE METODO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (324, 71, NULL, '1', 'INSERCION DE METODO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (325, 72, NULL, '0', 'REVISION POSTERIOR A LA INTERVENCION', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (326, 72, NULL, '1', 'REALIZACION DE LA INTERVENCION', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (327, 73, NULL, '1', 'MÉDICA(O) PASANTE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (328, 73, NULL, '2', 'MÉDICA(O) GENERAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (329, 73, NULL, '3', 'MÉDICA(O) RESIDENTE', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (330, 73, NULL, '4', 'MÉDICA(O) ESPECIALISTA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (331, 73, NULL, '5', 'PASANTE DE ENFERMERÍA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (332, 73, NULL, '6', 'ENFERMERA(O)', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (333, 73, NULL, '7', 'PASANTE DE NUTRICIÓN', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (334, 73, NULL, '8', 'NUTRIÓLOGA(O)', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (335, 73, NULL, '9', 'HOMEÓPATA', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (336, 73, NULL, '10', 'MÉDICA(O) TRADICIONAL', NULL, true, 10);
INSERT INTO public.gui_diccionario_opciones VALUES (337, 73, NULL, '11', 'TAPS', NULL, true, 11);
INSERT INTO public.gui_diccionario_opciones VALUES (338, 73, NULL, '15', 'PASANTE DE PSICOLOGÍA', NULL, true, 12);
INSERT INTO public.gui_diccionario_opciones VALUES (339, 73, NULL, '16', 'PSICÓLOGA(O)', NULL, true, 13);
INSERT INTO public.gui_diccionario_opciones VALUES (340, 73, NULL, '17', 'RESIDENTE DE PSIQUIATRÍA', NULL, true, 14);
INSERT INTO public.gui_diccionario_opciones VALUES (341, 73, NULL, '18', 'PSIQUIATRA', NULL, true, 15);
INSERT INTO public.gui_diccionario_opciones VALUES (342, 73, NULL, '19', 'MÉDICA(O) GENERAL HABILITADO SM', NULL, true, 16);
INSERT INTO public.gui_diccionario_opciones VALUES (343, 73, NULL, '20', 'LICENCIADA EN ENFERMERÍA Y OBSTETRICIA', NULL, true, 17);
INSERT INTO public.gui_diccionario_opciones VALUES (344, 73, NULL, '21', 'PARTERA TÉCNICA', NULL, true, 18);
INSERT INTO public.gui_diccionario_opciones VALUES (345, 73, NULL, '22', 'PROMOTOR DE SALUD', NULL, true, 19);
INSERT INTO public.gui_diccionario_opciones VALUES (346, 73, NULL, '24', 'MÉDICA(O) ESPECIALISTA HABILITADO SM', NULL, true, 20);
INSERT INTO public.gui_diccionario_opciones VALUES (347, 73, NULL, '25', 'LICENCIADA(O) EN GERONTOLOGÍA', NULL, true, 21);
INSERT INTO public.gui_diccionario_opciones VALUES (348, 73, NULL, '27', 'PASANTE DE GERONTOLOGÍA', NULL, true, 22);
INSERT INTO public.gui_diccionario_opciones VALUES (349, 73, NULL, '30', 'TRABAJADORA(OR) SOCIAL', NULL, true, 23);
INSERT INTO public.gui_diccionario_opciones VALUES (350, 74, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (351, 74, NULL, '1', 'SI', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (352, 75, NULL, '0', 'POSITIVO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (353, 75, NULL, '1', 'NEGATIVO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (354, 76, NULL, '0', 'NORMAL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (355, 76, NULL, '1', 'ANORMAL', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (356, 77, NULL, '1', 'BAJO RIESGO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (357, 77, NULL, '2', 'MEDIANO RIESGO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (358, 77, NULL, '3', 'ALTO RIESGO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (359, 78, NULL, '1', '1A DETECCIÓN PRUEBA RÁPIDA REACTIVA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (360, 78, NULL, '2', '1A DETECCIÓN PRUEBA RÁPIDA NO REACTIVA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (361, 78, NULL, '3', '1A DETECCIÓN ELISA POSITIVA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (362, 78, NULL, '4', '1A DETECCIÓN ELISA NEGATIVA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (363, 78, NULL, '5', '2A DETECCIÓN PRUEBA RÁPIDA REACTIVA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (364, 78, NULL, '6', '2A DETECCIÓN PRUEBA RÁPIDA NO REACTIVA', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (365, 78, NULL, '7', '2A DETECCIÓN ELISA POSITIVA', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (366, 78, NULL, '8', '2A DETECCIÓN ELISA NEGATIVA', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (367, 78, NULL, '9', 'PRUEBA CONFIRMATORIA POSITIVA', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (368, 78, NULL, '10', 'PRUEBA CONFIRMATORIA NEGATIVA', NULL, true, 10);
INSERT INTO public.gui_diccionario_opciones VALUES (369, 79, NULL, '1', 'NORMAL CON RESPUESTA A BRONCODILATADOR', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (370, 79, NULL, '2', 'NORMAL SIN RESPUESTA A BRONCODILATADOR', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (371, 79, NULL, '3', 'OBSTRUIDO CON RESPUESTA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (372, 79, NULL, '4', 'OBSTRUIDO SIN RESPUESTA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (373, 79, NULL, '5', 'SUGIERE RESTRICCIÓN CON RESPUESTA', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (374, 79, NULL, '6', 'SUGIERE RESTRICCIÓN SIN RESPUESTA', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (375, 79, NULL, '7', 'SUGIERE PATRÓN MIXTO CON RESPUESTA', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (376, 79, NULL, '8', 'SUGIERE PATRÓN MIXTO SIN RESPUESTA', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (377, 79, NULL, '9', 'PATRÓN NO ESPECÍFICO CON RESPUESTA', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (378, 79, NULL, '10', 'PATRÓN NO ESPECÍFICO SIN RESPUESTA', NULL, true, 10);
INSERT INTO public.gui_diccionario_opciones VALUES (379, 80, NULL, '0', 'NO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (380, 80, NULL, '1', 'SI', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (381, 81, NULL, '0', 'PRIMERA VEZ', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (382, 81, NULL, '1', 'SUBSECUENTE', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (383, 82, NULL, '1', 'HOMBRE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (384, 82, NULL, '2', 'MUJER', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (385, 82, NULL, '3', 'NO BINARIO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (386, 83, NULL, '1', 'HOMBRE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (387, 83, NULL, '2', 'MUJER', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (388, 83, NULL, '3', 'INTERSEXUAL', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (389, 84, NULL, '0', 'NO ESPECIFICADO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (390, 84, NULL, '1', 'MASCULINO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (391, 84, NULL, '2', 'FEMENINO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (392, 84, NULL, '3', 'TRANSGENERO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (393, 84, NULL, '4', 'TRANSEXUAL', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (394, 84, NULL, '5', 'TRAVESTI', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (395, 84, NULL, '6', 'INTERSEXUAL', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (396, 84, NULL, '88', 'OTRO', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (397, 85, NULL, '1', 'PATOLOGIA CRONICA ORGANO FUNCIONAL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (398, 85, NULL, '2', 'PATOLOGIA CRONICA INFECCIOSA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (399, 85, NULL, '3', 'MORBILIDAD MATERNA EXTREMA', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (400, 85, NULL, '4', 'CON FACTORES DE RIESGO SOCIALES', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (401, 85, NULL, '5', 'ANTECEDENTES OBSTETRICOS DE RIESGO', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (402, 85, NULL, '9', 'SIN ANTECEDENTES', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (403, 86, NULL, '1', 'PRIMERO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (404, 86, NULL, '2', 'SEGUNDO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (405, 86, NULL, '3', 'TERCERO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (406, 87, NULL, '1', 'VERDE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (407, 87, NULL, '2', 'AMARILLO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (408, 87, NULL, '3', 'ROJO', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (409, 87, NULL, '4', 'RECUPERADO DE REZAGO', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (410, 87, NULL, '5', 'RECUPERADO DE RIESGO', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (411, 87, NULL, '6', 'EN SEGUIMIENTO', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (412, 88, NULL, '1', 'MAYOR O IGUAL A 90', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (413, 88, NULL, '2', 'DE 89 A 80', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (414, 88, NULL, '3', 'MENOR O IGUAL A 79', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (415, 89, NULL, '1', 'PLAN A', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (416, 89, NULL, '2', 'PLAN B', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (417, 89, NULL, '3', 'PLAN C', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (418, 90, NULL, '1', 'SINTOMATICO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (419, 90, NULL, '2', 'ANTIBIOTICO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (420, 91, NULL, '1', 'PREVENTIVA', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (421, 91, NULL, '2', 'TRATAMIENTO', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (422, 92, NULL, '1', 'EMBARAZO ALTO RIESGO', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (423, 92, NULL, '2', 'SOSPECHA CANCER < 18 AÑOS', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (424, 92, NULL, '3', 'POR IRAS', NULL, true, 3);
INSERT INTO public.gui_diccionario_opciones VALUES (425, 92, NULL, '4', 'POR NEUMONIA', NULL, true, 4);
INSERT INTO public.gui_diccionario_opciones VALUES (426, 92, NULL, '5', 'OTRAS', NULL, true, 5);
INSERT INTO public.gui_diccionario_opciones VALUES (427, 92, NULL, '6', 'CISTICERCOSIS', NULL, true, 6);
INSERT INTO public.gui_diccionario_opciones VALUES (428, 92, NULL, '7', 'EMERGENCIA OBSTETRICA-PREECLAMPSIA', NULL, true, 7);
INSERT INTO public.gui_diccionario_opciones VALUES (429, 92, NULL, '8', 'EMERGENCIA OBSTETRICA-HEMORRAGIA', NULL, true, 8);
INSERT INTO public.gui_diccionario_opciones VALUES (430, 92, NULL, '9', 'OTRA EMERGENCIA OBSTETRICA', NULL, true, 9);
INSERT INTO public.gui_diccionario_opciones VALUES (431, 93, NULL, '1', 'EN TIEMPO REAL', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (432, 93, NULL, '2', 'DIFERIDA', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (433, 94, NULL, '1', 'HOMBRE', NULL, true, 1);
INSERT INTO public.gui_diccionario_opciones VALUES (434, 94, NULL, '2', 'MUJER', NULL, true, 2);
INSERT INTO public.gui_diccionario_opciones VALUES (435, 94, NULL, '3', 'INTERSEXUAL', NULL, true, 3);


--
-- TOC entry 4613 (class 0 OID 160118)
-- Dependencies: 224
-- Data for Name: gui_diccionarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.gui_diccionarios VALUES (1, 'HOSP_MOTIVO_EGRESO', 'Motivo de Egreso Hospitalario', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (2, 'HOSP_PROCEDENCIA', 'Área de Procedencia', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (3, 'HOSP_TIPO_INGRESO', 'Tipo de Servicio de Ingreso', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (4, 'HOSP_ATENCION_OBST', 'Tipo de Atención Obstétrica', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (5, 'HOSP_TIPO_PARTO', 'Tipo de Parto', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (6, 'HOSP_USO_QUIROFANO', 'Uso de Quirófano', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (7, 'SIS_OPCION_SINO', 'Opciones Si / No', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (8, 'HOSP_TIPO_ANESTESIA', 'Tipo de Anestesia', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (9, 'HOSP_MUJER_FERTIL', 'Condición de Mujer Fértil', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (10, 'HOSP_PLANIFICACION_FAM', 'Planificación Familiar (Egreso)', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (11, 'HOSP_TIPO_ATENCION', 'Tipo de Atención Proporcionada', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (12, 'HOSP_CONDICION_NAC', 'Condición de Nacimiento', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (13, 'URG_TIPO_URGENCIA', 'Tipo de Urgencia', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (14, 'URG_MOTIVO_ATENCION', 'Motivo de Atención en Urgencias', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (15, 'URG_TIPO_CAMA', 'Tipo de Cama', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (16, 'URG_ALTA_POR', 'Motivo de Alta de Urgencias', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (17, 'URG_PLAN_IRAS', 'Plan Infecciones Respiratorias Agudas', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (18, 'URG_PLAN_EDAS', 'Plan Enfermedades Diarreicas Agudas', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (20, 'LES_USUARIO_REFERIDO', 'Institución que refiere al paciente', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (21, 'LES_SUSTANCIAS', 'Sospecha bajo efectos de sustancias', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (22, 'LES_INTENCIONALIDAD', 'Intencionalidad del evento', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (23, 'LES_EVENTO_REPETIDO', 'Identificación de evento repetido', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (24, 'LES_LESIONADO_VEHICULO', 'Lesionado en vehículo de motor', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (25, 'LES_EQUIPO_UTILIZADO', 'Equipo de seguridad utilizado', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (26, 'LES_TIPO_VIOLENCIA', 'Tipo de Violencia', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (27, 'LES_NUMERO_AGRESORES', 'Número de agresores', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (28, 'LES_PARENTESCO', 'Parentesco del agresor', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (29, 'LES_SERVICIO_ATENCION', 'Servicio que otorgo la atención', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (30, 'LES_TIPO_ATENCION', 'Tipo de Atención Brindada', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (31, 'LES_DESPUES_ATENCION', 'Destino después de la atención', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (32, 'LES_RESPONSABLE', 'Responsable de la atención', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (33, 'BUC_TIPO_PERSONAL', 'Tipo de Personal Odontológico', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (34, 'BUC_SEXO_CURP', 'Sexo CURP', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (35, 'BUC_SEXO_BIO', 'Sexo Biológico', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (36, 'BUC_AFRO_INDIGENA', 'Autodenominación Indígena / Afromexicano', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (37, 'BUC_MIGRANTE', 'Condición Migrante', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (38, 'BUC_GENERO', 'Identidad de Género', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (39, 'BUC_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (40, 'BUC_RELACION_TEMP', 'Relación Temporal', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (41, 'BUC_TELECONSULTA_ESTUDIOS', 'Estudios de Teleconsulta', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (42, 'BUC_MODALIDAD_TELE', 'Modalidad Teleconsulta', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (53, 'MEN_TIPO_PERSONAL', 'Tipo de Personal Salud Mental', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (54, 'MEN_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (55, 'MEN_SUSTANCIAS', 'Sustancias de Consumo', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (56, 'MEN_ATENCION_SUSTANCIA', 'Tipo de Atención por Sustancia', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (57, 'MEN_CONSUMO_SUSTANCIA', 'Patrón de Consumo de Sustancia', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (58, 'MEN_AMBITO_VIOLENCIA', 'Ámbito de las Violencias', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (59, 'MEN_TIPO_VIOLENCIA', 'Tipo de Violencia Específica', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (60, 'MEN_COMPORTAMIENTO_SUICIDA', 'Comportamiento Suicida', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (61, 'MEN_EVALUACION_PSICOLOGICA', 'Evaluación Psicológica', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (62, 'MEN_PSICOTERAPIA', 'Tipo de Psicoterapia', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (63, 'PLAN_TIPO_PERSONAL', 'Tipo de Personal Planificación', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (64, 'PLAN_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (65, 'PLAN_SEXO_CURP', 'Sexo CURP', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (66, 'PLAN_SEXO_BIO', 'Sexo Biológico', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (67, 'PLAN_AFRO_INDIGENA', 'Autodenominación Indígena / Afromexicano', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (68, 'PLAN_MIGRANTE', 'Condición Migrante', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (69, 'PLAN_GENERO', 'Identidad de Género', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (70, 'PLAN_ESTUDIOS_TELE', 'Estudios de Teleconsulta', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (71, 'PLAN_REVISION_DIU', 'Revisión o Inserción DIU', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (72, 'PLAN_REVISION_QUIRURGICA', 'Revisión o Realización Quirúrgica', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (73, 'DET_TIPO_PERSONAL', 'Tipo de Personal Detecciones', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (74, 'DET_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (75, 'DET_POS_NEG', 'Opciones Positivo/Negativo', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (76, 'DET_NORMAL_ANORMAL', 'Opciones Normal/Anormal', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (77, 'DET_RIESGO', 'Escala de Riesgo', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (78, 'DET_PRUEBAS_ITS', 'Resultados ITS (VIH/Sífilis)', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (79, 'DET_ESPIROMETRIA', 'Resultado Espirometría', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (80, 'CEX_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (81, 'CEX_RELACION_TEMP', 'Relación Temporal', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (82, 'CEX_SEXO_CURP', 'Sexo CURP', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (83, 'CEX_SEXO_BIO', 'Sexo Biológico', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (84, 'CEX_GENERO', 'Identidad de Género', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (85, 'CEX_RIESGO_PREGESTACIONAL', 'Riesgo Pregestacional', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (86, 'CEX_TRIMESTRE_GESTACIONAL', 'Trimestre Gestacional', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (87, 'CEX_RESULTADO_EDI', 'Resultado Prueba EDI', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (88, 'CEX_RESULTADO_BATTELLE', 'Resultado Prueba Battelle', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (89, 'CEX_PLAN_EDAS', 'Plan EDAS', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (90, 'CEX_PLAN_IRAS', 'Plan IRAS', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (91, 'CEX_GERONTOLOGIA', 'Intervención Gerontológica', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (92, 'CEX_MOTIVO_REFERIDO', 'Motivo de Referencia', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (93, 'CEX_MODALIDAD_TELE', 'Modalidad Teleconsulta', NULL, true);
INSERT INTO public.gui_diccionarios VALUES (94, 'SYS_SEXO_PACIENTE', 'Sexo Biológico (Expediente Paciente Maestro)', NULL, true);


--
-- TOC entry 4616 (class 0 OID 160150)
-- Dependencies: 227
-- Data for Name: rel_normatividad_opciones; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4258 (class 0 OID 159309)
-- Dependencies: 213
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4611 (class 0 OID 160098)
-- Dependencies: 222
-- Data for Name: sys_adopcion_catalogos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4648 (class 0 OID 160537)
-- Dependencies: 260
-- Data for Name: sys_bitacora_auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4640 (class 0 OID 160416)
-- Dependencies: 252
-- Data for Name: sys_giis_campos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sys_giis_campos VALUES (2, 1, 2, 'folio', 'Clave asignada por la Unidad Hospitalaria', 'texto', 8, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (3, 1, 3, 'curpPaciente', 'CURP del paciente', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (4, 1, 4, 'nombre', 'Nombre(s) del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (5, 1, 5, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (6, 1, 6, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (7, 1, 7, 'fechaNacimiento', 'Fecha de nacimiento del paciente', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (12, 1, 12, 'peso', 'Peso del paciente en kilogramos', 'numerico', 7, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (13, 1, 13, 'talla', 'Talla del paciente en centímetros', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (25, 1, 25, 'otraLocalidad', 'Especificación del nombre de la localidad', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (27, 1, 27, 'fechaIngreso', 'Fecha de ingreso', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (28, 1, 28, 'fechaEgreso', 'Fecha de egreso', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (31, 1, 31, 'numeroServiciosAdicional', 'Número de servicios adicionales', 'numerico', 1, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (34, 1, 34, 'terapiaIntensivaDias', 'Estancia en terapia intensiva en días', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (35, 1, 35, 'terapiaIntensivaHoras', 'Estancia en terapia intensiva en horas', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (36, 1, 36, 'terapiaIntermediaDias', 'Estancia en terapia intermedia en días', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (37, 1, 37, 'terapiaIntermediaHoras', 'Estancia en terapia intermedia en horas', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (39, 1, 39, 'especifiqueProcedencia', 'Especifique el lugar de procedencia', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (44, 1, 44, 'descripcionAfeccionPrincipal', 'Descripción de la afección principal', 'texto', 250, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (47, 1, 47, 'numeroComorbilidad', 'Número consecutivo de comorbilidad', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (48, 1, 48, 'descripcionComorbilidad', 'Descripción de comorbilidad', 'texto', 250, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (51, 1, 51, 'causaExterna', 'Descripción de causa externa', 'texto', 250, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (55, 1, 55, 'numeroProcedimiento', 'Número de procedimiento médico', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (56, 1, 56, 'descripcionProcedimiento', 'Descripción del procedimiento', 'texto', 250, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (60, 1, 60, 'tiempoQuirofano', 'Tiempo en el quirófano', 'texto', 5, false, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (61, 1, 61, 'cedulaProfesional', 'Cédula Profesional del médico', 'texto', 14, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (62, 1, 62, 'folioLesion', 'Folio atención violencia/lesión', 'texto', 8, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (64, 1, 64, 'folioCertificadoDefuncion', 'Folio del certificado de defunción', 'numerico', 9, false, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (65, 1, 65, 'gestas', 'Número de embarazos', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (66, 1, 66, 'partos', 'Número de partos', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (67, 1, 67, 'abortos', 'Número de abortos', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (68, 1, 68, 'cesareas', 'Número de cesáreas', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (69, 1, 69, 'edadGestacional', 'Semanas de gestación', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (72, 1, 72, 'tipoProcAborto', 'Procedimiento de aborto', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (73, 1, 73, 'productoEmbarazo', 'Tipo de productos extraídos', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (74, 1, 74, 'totalProductos', 'Total de los productos', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (76, 1, 76, 'otroMetodo', 'Otro método planificacion', 'texto', 250, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (77, 1, 77, 'numeroProducto', 'Número consecutivo del producto', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (79, 1, 79, 'condicionNacidoVivo', 'Condición del nacido vivo al egresar', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (80, 1, 80, 'folioCertificado', 'Folio del certificado de nacimiento', 'texto', 14, false, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (81, 1, 81, 'apgar5Minutos', 'APGAR a los 5 min', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (85, 1, 85, 'tipoUnidad', 'Tipo de Unidad (Psiquiátricos)', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (86, 1, 86, 'tipoServicio', 'Tipo de servicio (Psiquiátricos)', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (88, 1, 88, 'curpResponsable', 'CURP del profesional', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (89, 1, 89, 'nombreResponsable', 'Nombre del profesional', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (90, 1, 90, 'primerApellidoResponsable', 'Primer apellido del profesional', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (91, 1, 91, 'segundoApellidoResponsable', 'Segundo apellido del profesional', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (92, 1, 92, 'cedulaResponsable', 'Cédula profesional del médico', 'texto', 14, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (94, 2, 2, 'folio', 'Clave asignada por la Unidad Médica', 'texto', 8, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (95, 2, 3, 'curpPaciente', 'Clave Única de Registro de Población del paciente', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (96, 2, 4, 'nombre', 'Nombre(s) del Paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (97, 2, 5, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (98, 2, 6, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (99, 2, 7, 'fechaNacimiento', 'Fecha de nacimiento del paciente', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (111, 2, 19, 'otraLocalidad', 'Especificación del nombre de la localidad', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (114, 2, 22, 'tiempoTraslado', 'Tiempo transcurrido en traslado', 'texto', 5, false, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (115, 2, 23, 'fechaIngreso', 'Fecha de ingreso correspondiente', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (116, 2, 24, 'horaIngreso', 'Hora en que ingreso el paciente', 'texto', 5, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (122, 2, 30, 'fechaAlta', 'Fecha de alta del paciente', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (123, 2, 31, 'horaAlta', 'Hora del alta del paciente', 'texto', 5, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (127, 2, 35, 'folioCertificadoDefuncion', 'Folio del certificado de defunción', 'numerico', 9, false, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (129, 2, 37, 'edadGestacional', 'Semanas de gestación', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (130, 2, 38, 'descripcionAfeccionPrincipal', 'Descripción de la afección principal', 'texto', 250, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (132, 2, 40, 'numeroComorbilidad', 'Número consecutivo de la comorbilidad', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (133, 2, 41, 'descripcionComorbilidad', 'Descripción de comorbilidad tratada', 'texto', 250, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (137, 2, 45, 'especifiqueEspecialidad', 'Especifique otra especialidad', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (139, 2, 47, 'curpEspecialista', 'CURP del médico especialista', 'texto', 18, false, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (140, 2, 48, 'nombreMedico', 'Nombre del Médico Especialista', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (141, 2, 49, 'primerApellidoMedico', 'Primer Apellido del Especialista', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (142, 2, 50, 'segundoApellidoMedico', 'Segundo Apellido del Especialista', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (143, 2, 51, 'cedulaEsp', 'Cédula Profesional del Médico Especialista', 'texto', 14, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (144, 2, 52, 'numeroProcedimiento', 'Número de procedimiento utilizado', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (146, 2, 54, 'numeroMedicamento', 'Número consecutivo de medicamentos', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (150, 2, 58, 'numeroSobres', 'Número de sobres de vida suero oral', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (152, 2, 60, 'curpResponsable', 'Clave Única de Registro del profesional', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (153, 2, 61, 'nombreResponsable', 'Nombre del profesional responsable', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (154, 2, 62, 'primerApellidoResponsable', 'Primer apellido del responsable', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (155, 2, 63, 'segundoApellidoResponsable', 'Segundo apellido del responsable', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (156, 2, 64, 'cedulaResponsable', 'Cédula profesional del responsable', 'texto', 14, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (158, 3, 2, 'folio', 'Clave asignada por la Unidad Médica', 'texto', 8, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (159, 3, 3, 'curpPaciente', 'Clave Única de Registro de Población', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (160, 3, 4, 'nombre', 'Nombre(s) del Paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (161, 3, 5, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (162, 3, 6, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (163, 3, 7, 'fechaNacimiento', 'Fecha de nacimiento del paciente', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (176, 3, 20, 'edadGestacional', 'Semanas de gestación', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (180, 3, 24, 'fechaEvento', 'Fecha en la que ocurrió el evento', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (181, 3, 25, 'horaEvento', 'Hora en la que ocurrió el evento', 'texto', 5, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (187, 3, 31, 'otraLocalidad', 'Especificación de la localidad', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (190, 3, 34, 'nombreVialidad', 'Nombre de la vialidad', 'texto', 100, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (191, 3, 35, 'numeroExterior', 'Número exterior', 'texto', 15, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (193, 3, 37, 'nombreAsentamiento', 'Nombre del asentamiento', 'texto', 100, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (195, 3, 39, 'tiempoTrasladoUH', 'Tiempo transcurrido en traslado', 'texto', 5, false, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (200, 3, 44, 'especifique', 'Especifique el agente causal', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (204, 3, 48, 'especifiqueEquipo', 'Especifique otro equipo', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (209, 3, 53, 'edadAgresor', 'Edad del agresor', 'numerico', 3, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (211, 3, 55, 'fechaAtencion', 'Fecha de la atención', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (212, 3, 56, 'horaAtencion', 'Hora de la atención', 'texto', 5, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (214, 3, 58, 'especifiqueServicio', 'Especifique servicio', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (217, 3, 61, 'especifiqueArea', 'Otra área anatómica', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (219, 3, 63, 'especifiqueConsecuencia', 'Otro tipo de consecuencia', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (220, 3, 64, 'descripcionAfeccionPrincipal', 'Descripción de afección principal', 'texto', 250, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (222, 3, 66, 'numeroAfeccion', 'Número de afección', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (223, 3, 67, 'descripcionAfeccion', 'Descripción de afección tratada', 'texto', 250, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (226, 3, 70, 'causaExterna', 'Descripción causa externa', 'texto', 250, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (229, 3, 73, 'especifiqueDestino', 'Especifica destino', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (231, 3, 75, 'folioCertificadoDefuncion', 'Folio Certificado de defunción', 'numerico', 9, false, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (234, 3, 78, 'curpResponsable', 'CURP responsable', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (235, 3, 79, 'nombreResponsable', 'Nombre responsable', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (236, 3, 80, 'primerApellidoResponsable', 'Primer apellido responsable', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (237, 3, 81, 'segundoApellidoResponsable', 'Segundo apellido responsable', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (238, 3, 82, 'cedulaResponsable', 'Cédula profesional', 'texto', 14, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (241, 4, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (242, 4, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (243, 4, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (244, 4, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (247, 4, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (248, 4, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (249, 4, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (250, 4, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (251, 4, 13, 'fechaNacimiento', 'Fecha de nacimiento del paciente', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (262, 4, 24, 'fechaConsulta', 'Fecha de la consulta', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (264, 4, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (265, 4, 27, 'talla', 'Talla del paciente (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (266, 4, 28, 'circunferenciaCintura', 'Circunferencia de cintura (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (267, 4, 29, 'sistolica', 'Presión arterial sistólica (mm/Hg)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (268, 4, 30, 'diastolica', 'Presión arterial diastólica (mm/Hg)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (269, 4, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (270, 4, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (271, 4, 33, 'temperatura', 'Temperatura corporal (C)', 'numerico', 4, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (272, 4, 34, 'saturacionOxigeno', 'Saturación de oxígeno (SpO2)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (273, 4, 35, 'glucemia', 'Glucosa en sangre mg/dl', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (292, 4, 54, 'fosetasFisuras', 'Fosetas y fisuras selladas', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (293, 4, 55, 'amalgamas', 'Obturaciones con amalgamas', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (294, 4, 56, 'resinas', 'Obturaciones con resinas', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (295, 4, 57, 'ionomeroVidrio', 'Obturaciones con Ionómero de vidrio', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (296, 4, 58, 'alcasite', 'Obturaciones con alcasite', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (297, 4, 59, 'obturacionTemporal', 'Obturaciones temporales', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (298, 4, 60, 'dienteTemp', 'Extracciones de dientes temporales', 'numerico', 1, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (299, 4, 61, 'dientePerm', 'Extracciones de dientes permanentes', 'numerico', 1, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (300, 4, 62, 'pulpar', 'Piezas tratadas con terapia pulpar', 'numerico', 1, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (303, 4, 65, 'otrasAtenciones', 'Atenciones adicionales', 'numerico', 1, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (304, 4, 66, 'radiografias', 'Radiografías dentales tomadas', 'numerico', 1, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (310, 4, 72, 'referidoPor', 'Motivo de referencia', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (395, 6, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (396, 6, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (397, 6, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (398, 6, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (401, 6, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (402, 6, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (403, 6, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (404, 6, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (405, 6, 13, 'fechaNacimiento', 'Fecha de nacimiento', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (408, 6, 16, 'sexoCURP', 'Sexo registrado ante RENAPO', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (409, 6, 17, 'sexoBiologico', 'Sexo biológico/fisiológico', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (410, 6, 18, 'seAutodenominaAfromexicano', 'Afromexicano', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (411, 6, 19, 'seConsideraIndigena', 'Indígena', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (412, 6, 20, 'migrante', 'Migrante', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (414, 6, 22, 'genero', 'Identidad de género', 'numerico', 2, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (416, 6, 24, 'fechaConsulta', 'Fecha de la consulta', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (418, 6, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (419, 6, 27, 'talla', 'Talla (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (420, 6, 28, 'circunferenciaCintura', 'Circunferencia cintura (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (421, 6, 29, 'sistolica', 'Presión arterial sistólica', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (422, 6, 30, 'diastolica', 'Presión arterial diastólica', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (423, 6, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (424, 6, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (425, 6, 33, 'temperatura', 'Temperatura corporal', 'numerico', 4, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (426, 6, 34, 'saturacionOxigeno', 'SpO2', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (427, 6, 35, 'glucemia', 'Glucosa en sangre', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (431, 6, 39, 'relacionTemporal', 'Primera vez o subsecuente', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (437, 6, 45, 'derivacionPreconsulta', 'Derivación de preconsulta', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (467, 6, 75, 'usuarioConflictoLey', 'Caso médico legal', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (472, 6, 80, 'referidoPor', 'Referido a unidad mayor', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (476, 6, 84, 'estudiosTeleconsulta', 'Estudios teleconsulta', 'texto', 15, false, false, NULL, 'ARREGLO', NULL);
INSERT INTO public.sys_giis_campos VALUES (477, 6, 85, 'modalidadConsulDist', 'Modalidad a distancia', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (480, 7, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (481, 7, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (482, 7, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (483, 7, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (486, 7, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (487, 7, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (488, 7, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (489, 7, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (490, 7, 13, 'fechaNacimiento', 'Fecha de nacimiento', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (501, 7, 24, 'fechaConsulta', 'Fecha de la consulta', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (503, 7, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (504, 7, 27, 'talla', 'Talla (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (505, 7, 28, 'circunferenciaCintura', 'Circunferencia cintura (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (506, 7, 29, 'sistolica', 'Presión arterial sistólica', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (507, 7, 30, 'diastolica', 'Presión arterial diastólica', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (508, 7, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (509, 7, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (510, 7, 33, 'temperatura', 'Temperatura corporal', 'numerico', 4, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (511, 7, 34, 'saturacionOxigeno', 'SpO2', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (512, 7, 35, 'glucemia', 'Glucosa en sangre', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (522, 7, 45, 'oral', 'Ciclos método oral', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (523, 7, 46, 'inyectableMensual', 'Ciclos inyectable mensual', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (524, 7, 47, 'inyectableBimestral', 'Ciclos inyectable bimestral', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (525, 7, 48, 'inyectableTrimestral', 'Ciclos inyectable trimestral', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (528, 7, 51, 'parcheDermico', 'Ciclos parche dérmico', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (532, 7, 55, 'preservativo', 'Preservativos masculinos', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (533, 7, 56, 'preservativoFemenino', 'Preservativos femeninos', 'numerico', 2, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (534, 7, 57, 'otroMetodo', 'Otros métodos entregados', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (544, 7, 67, 'referidoPor', 'Referido a unidad mayor', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (549, 7, 72, 'modalidadConsulDist', 'Modalidad a distancia', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (552, 8, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (553, 8, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (554, 8, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (555, 8, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (558, 8, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (559, 8, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (560, 8, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (561, 8, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (562, 8, 13, 'fechaNacimiento', 'Fecha de nacimiento', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (565, 8, 16, 'sexoCURP', 'Sexo registrado ante RENAPO', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (566, 8, 17, 'sexoBiologico', 'Sexo biológico/fisiológico', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (573, 8, 24, 'fechaDeteccion', 'Fecha de las detecciones', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (575, 8, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (576, 8, 27, 'talla', 'Talla (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (577, 8, 28, 'circunferenciaCintura', 'Circunferencia cintura (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (578, 8, 29, 'sistolica', 'Presión arterial sistólica', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (579, 8, 30, 'diastolica', 'Presión arterial diastólica', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (580, 8, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (581, 8, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (582, 8, 33, 'temperatura', 'Temperatura corporal', 'numerico', 4, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (583, 8, 34, 'saturacionOxigeno', 'SpO2', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (584, 8, 35, 'glucemia', 'Glucosa en sangre', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (586, 8, 37, 'tirasDeteccion', 'Número de tiras usadas', 'numerico', 1, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (604, 8, 55, 'edadCuidador', 'Edad del cuidador', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (605, 8, 56, 'sexoCuidador', 'Sexo del cuidador', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (624, 8, 75, 'gonorrea', 'Detección Gonorrea', 'numerico', 2, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (626, 8, 77, 'herpesGenital', 'Detección Herpes', 'numerico', 2, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (627, 8, 78, 'chlamydia', 'Detección Chlamydia', 'numerico', 2, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (629, 8, 80, 'cancerCervicoUterino', 'Citología cervical', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (636, 8, 87, 'reactivosAntigenoProstatico', 'Reactivos PSA usados', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (638, 8, 89, 'espirometriaVEFI_CVF', 'Resultado VEFI/CVF', 'numerico', 3, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (639, 8, 90, 'LIN', 'Límite Inferior Normalidad', 'numerico', 4, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (644, 9, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (645, 9, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (646, 9, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, true, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (647, 9, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, false, false, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (650, 9, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, true, true, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (651, 9, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (652, 9, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, true, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (653, 9, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, false, true, NULL, 'TEXTO_LIBRE', NULL);
INSERT INTO public.sys_giis_campos VALUES (654, 9, 13, 'fechaNacimiento', 'Fecha de nacimiento', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (661, 9, 20, 'migrante', 'Migrante', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (665, 9, 24, 'fechaConsulta', 'Fecha de la consulta', 'fecha', NULL, true, false, NULL, 'FORMATO', NULL);
INSERT INTO public.sys_giis_campos VALUES (667, 9, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (668, 9, 27, 'talla', 'Talla (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (669, 9, 28, 'circunferenciaCintura', 'Circunferencia cintura (cm)', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (670, 9, 29, 'sistolica', 'Presión arterial sistólica', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (671, 9, 30, 'diastolica', 'Presión arterial diastólica', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (672, 9, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (673, 9, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (674, 9, 33, 'temperatura', 'Temperatura corporal', 'numerico', 4, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (675, 9, 34, 'saturacionOxigeno', 'SpO2', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (676, 9, 35, 'glucemia', 'Glucosa en sangre', 'numerico', 3, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (678, 9, 37, 'resultadoObtenidoaTravesde', 'Origen glucosa', 'numerico', 1, true, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (679, 9, 38, 'embarazadaSinDiabetes', 'Tiras usadas embarazo', 'numerico', 1, true, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (692, 9, 51, 'intervencionesSMyA', 'Acciones Salud Mental', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (696, 9, 55, 'planSeguridad', 'Plan de seguridad embarazo', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (719, 9, 78, 'pruebaEDI', 'Aplicación prueba EDI', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (725, 9, 84, 'numeroSobresVSOTratamiento', 'Sobres VSO', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (729, 9, 88, 'aplicacionCedulaCancer', 'Cédula cáncer <18', 'numerico', 1, false, false, NULL, 'CATALOGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (738, 9, 97, 'numeroSobresVSOPromocion', 'VSO Promoción', 'numerico', 1, false, false, NULL, 'RANGO', NULL);
INSERT INTO public.sys_giis_campos VALUES (746, 9, 105, 'estudiosTeleconsulta', 'Estudios teleconsulta', 'texto', 15, false, false, NULL, 'ARREGLO', NULL);
INSERT INTO public.sys_giis_campos VALUES (45, 1, 45, 'codigoCIEAfeccionPrincipal', 'Código CIE afección principal', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (49, 1, 49, 'codigoCieComorbilidad', 'Código CIE de comorbilidad', 'texto', 4, false, false, 'DIAGNOSTICOS', 'ARREGLO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (50, 1, 50, 'afeccionPrincipalReseleccionada', 'Código CIE afección principal reseleccionada', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (52, 1, 52, 'codigoCieCausaExterna', 'Código CIE de Causa Externa', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (53, 1, 53, 'morfologia', 'Código morfología de tumores', 'texto', 10, false, false, 'MORFOLOGIA', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (131, 2, 39, 'codigoCIEAfeccionPrincipal', 'Código CIE Afección principal', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (134, 2, 42, 'codigoCieComorbilidad', 'Código CIE comorbilidad', 'texto', 4, false, false, 'DIAGNOSTICOS', 'ARREGLO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (135, 2, 43, 'afeccionPrincipalReseleccionada', 'Código CIE afección principal reseleccionada', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (221, 3, 65, 'codigoCIEAfeccionPrincipal', 'Código CIE Afección principal', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (224, 3, 68, 'codigoCIEAfeccion', 'CIE Afección tratada', 'texto', 4, false, false, 'DIAGNOSTICOS', 'ARREGLO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (225, 3, 69, 'afeccionPrincipalReseleccionada', 'CIE principal reseleccionada', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (227, 3, 71, 'codigoCIECausaExterna', 'Código CIE Causa Externa', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (277, 4, 39, 'codigoCIEDiagnostico1', 'Código CIE del diagnóstico 1', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (279, 4, 41, 'codigoCIEDiagnostico2', 'Código CIE del diagnóstico 2', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (281, 4, 43, 'codigoCIEDiagnostico3', 'Código CIE del diagnóstico 3', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (432, 6, 40, 'codigoCIEDiagnostico1', 'Diagnóstico principal', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (434, 6, 42, 'codigoCIEDiagnostico2', 'Diagnóstico secundario', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (436, 6, 44, 'codigoCIEDiagnostico3', 'Tercer diagnóstico', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (516, 7, 39, 'codigoCIEDiagnostico1', 'Diagnóstico principal', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (518, 7, 41, 'codigoCIEDiagnostico2', 'Diagnóstico secundario', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (520, 7, 43, 'codigoCIEDiagnostico3', 'Tercer diagnóstico', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (684, 9, 43, 'codigoCIEDiagnostico1', 'Diagnóstico principal', 'texto', 4, true, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (687, 9, 46, 'codigoCIEDiagnostico2', 'Diagnóstico secundario', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (690, 9, 49, 'codigoCIEDiagnostico3', 'Tercer diagnóstico', 'texto', 4, false, false, 'DIAGNOSTICOS', 'CATALOGO', 'TABLA_CIE10');
INSERT INTO public.sys_giis_campos VALUES (57, 1, 57, 'codigoCieProcedimiento', 'Código CIE-9MC del procedimiento', 'texto', 4, false, false, 'PROCEDIMIENTO', 'ARREGLO', 'TABLA_CIE9');
INSERT INTO public.sys_giis_campos VALUES (145, 2, 53, 'codigoCieProcedimiento', 'Código CIE-9MC del procedimiento', 'texto', 4, false, false, 'PROCEDIMIENTO', 'ARREGLO', 'TABLA_CIE9');
INSERT INTO public.sys_giis_campos VALUES (8, 1, 8, 'paisOrigen', 'Identificador del país de nacimiento', 'texto', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (9, 1, 9, 'entidadNacimiento', 'Entidad federativa de nacimiento', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (21, 1, 21, 'paisResidencia', 'País de residencia del paciente', 'texto', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (22, 1, 22, 'entidadResidencia', 'Entidad de residencia', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (23, 1, 23, 'municipioResidencia', 'Municipio de residencia', 'texto', 3, true, false, 'MUNICIPIOS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (24, 1, 24, 'localidadResidencia', 'Localidad de residencia', 'texto', 4, true, false, 'LOCALIDADES', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (26, 1, 26, 'codigoPostal', 'Código Postal del lugar de residencia', 'texto', 5, true, false, 'CODIGO_POSTAL', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (87, 1, 87, 'paisNacimiento', 'País de nacimiento del prestador', 'texto', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (100, 2, 8, 'paisOrigen', 'Identifica el país de nacimiento del paciente', 'texto', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (101, 2, 9, 'entidadNacimiento', 'Entidad federativa de nacimiento del paciente', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (107, 2, 15, 'paisResidencia', 'Identifica el país de residencia del paciente', 'texto', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (108, 2, 16, 'entidadResidencia', 'Entidad de residencia del paciente', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (109, 2, 17, 'municipioResidencia', 'Municipio o delegación de residencia', 'texto', 3, true, false, 'MUNICIPIOS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (110, 2, 18, 'localidadResidencia', 'Localidad de residencia del paciente', 'texto', 4, true, false, 'LOCALIDADES', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (112, 2, 20, 'codigoPostal', 'Código Postal del lugar de residencia', 'texto', 5, true, false, 'CODIGO_POSTAL', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (138, 2, 46, 'paisNacimientoEspecialista', 'País de nacimiento del especialista', 'numerico', 3, false, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (151, 2, 59, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (164, 3, 8, 'paisOrigen', 'País de nacimiento del paciente', 'texto', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (165, 3, 9, 'entidadNacimiento', 'Entidad federativa de nacimiento', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (166, 3, 10, 'escolaridad', 'Nivel de escolaridad', 'numerico', 3, false, false, 'ESCOLARIDAD', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (184, 3, 28, 'entidadOcurrencia', 'Entidad de la ocurrencia', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (185, 3, 29, 'municipioOcurrencia', 'Municipio de la ocurrencia', 'texto', 3, true, false, 'MUNICIPIOS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (186, 3, 30, 'localidadOcurrencia', 'Localidad de ocurrencia', 'texto', 4, true, false, 'LOCALIDADES', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (188, 3, 32, 'codigoPostal', 'Código Postal de ocurrencia', 'texto', 5, true, false, 'CODIGO_POSTAL', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (189, 3, 33, 'tipoVialidad', 'Clasificación de vialidad', 'numerico', 2, true, false, 'TIPO_VIALIDAD', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (192, 3, 36, 'tipoAsentamiento', 'Tipo de asentamiento', 'numerico', 2, true, false, 'TIPO_ASENTAMIENTO', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (233, 3, 77, 'paisNacimiento', 'País nacimiento prestador', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (240, 4, 2, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (252, 4, 14, 'paisNacPaciente', 'País de nacimiento del paciente', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (253, 4, 15, 'entidadNacimiento', 'Entidad de nacimiento del paciente', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (259, 4, 21, 'paisProcedencia', 'País de procedencia (Migrante)', 'numerico', 3, false, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (394, 6, 2, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (406, 6, 14, 'paisNacPaciente', 'País de nacimiento del paciente', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (407, 6, 15, 'entidadNacimiento', 'Entidad de nacimiento del paciente', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (413, 6, 21, 'paisProcedencia', 'País de procedencia', 'numerico', 3, false, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (479, 7, 2, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (491, 7, 14, 'paisNacPaciente', 'País de nacimiento del paciente', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (492, 7, 15, 'entidadNacimiento', 'Entidad de nacimiento del paciente', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (498, 7, 21, 'paisProcedencia', 'País de procedencia', 'numerico', 3, false, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (551, 8, 2, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (563, 8, 14, 'paisNacPaciente', 'País de nacimiento del paciente', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (564, 8, 15, 'entidadNacimiento', 'Entidad de nacimiento del paciente', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (570, 8, 21, 'paisProcedencia', 'País de procedencia', 'numerico', 3, false, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (643, 9, 2, 'paisNacimiento', 'País nacimiento prestador', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (655, 9, 14, 'paisNacPaciente', 'País nacimiento paciente', 'numerico', 3, true, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (656, 9, 15, 'entidadNacimiento', 'Entidad de nacimiento', 'texto', 2, true, false, 'ENTIDAD_FEDERATIVA', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (662, 9, 21, 'paisProcedencia', 'País de procedencia', 'numerico', 3, false, false, 'PAIS', 'CATALOGO', 'TABLA_SEPOMEX');
INSERT INTO public.sys_giis_campos VALUES (1, 1, 1, 'clues', 'Clave Única de Establecimientos en Salud', 'texto', 11, true, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (40, 1, 40, 'cluesProcedencia', 'CLUES de procedencia', 'texto', 11, false, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (42, 1, 42, 'cluesReferido', 'CLUES de la unidad médica de Referencia', 'texto', 11, false, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (93, 2, 1, 'clues', 'Clave Única de Establecimientos en Salud', 'texto', 11, true, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (121, 2, 29, 'cluesTraslado', 'CLUES de la unidad médica de traslado', 'texto', 11, false, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (125, 2, 33, 'cluesReferido', 'CLUES de la unidad a la cual es referido el paciente', 'texto', 11, false, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (157, 3, 1, 'clues', 'Clave Única de Establecimientos en Salud', 'texto', 11, true, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (179, 3, 23, 'cluesReferido', 'CLUES de la Unidad que refiere', 'texto', 11, false, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (239, 4, 1, 'clues', 'Clave Única de Establecimiento', 'texto', 11, true, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (393, 6, 1, 'clues', 'Clave Única de Establecimientos', 'texto', 11, true, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (478, 7, 1, 'clues', 'Clave Única de Establecimientos', 'texto', 11, true, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (550, 8, 1, 'clues', 'Clave Única de Establecimientos', 'texto', 11, true, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (642, 9, 1, 'clues', 'Clave Única de Establecimientos', 'texto', 11, true, false, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO', 'TABLA_UNIDADES');
INSERT INTO public.sys_giis_campos VALUES (30, 1, 30, 'claveServicioIngreso', 'Clave del servicio de ingreso', 'texto', 4, true, false, 'ESPECIALIDADES', 'CATALOGO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (32, 1, 32, 'claveServicioAdicional', 'Clave del servicio adicional', 'texto', 4, false, false, 'ESPECIALIDADES', 'ARREGLO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (33, 1, 33, 'claveServicioEgreso', 'Clave del servicio de egreso', 'texto', 4, true, false, 'ESPECIALIDADES', 'CATALOGO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (136, 2, 44, 'tipoEspecialidad', 'Tipo de especialidad interconsultante', 'numerico', 3, false, false, 'ESPECIALIDADES', 'ARREGLO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (263, 4, 25, 'servicioAtencion', 'Tipo de servicio otorgado', 'numerico', 2, true, false, 'ESPECIALIDADES', 'CATALOGO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (417, 6, 25, 'servicioAtencion', 'Servicio de atención', 'numerico', 2, true, false, 'ESPECIALIDADES', 'CATALOGO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (502, 7, 25, 'servicioAtencion', 'Servicio de atención', 'numerico', 2, true, false, 'ESPECIALIDADES', 'CATALOGO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (574, 8, 25, 'servicioAtencion', 'Servicio de atención', 'numerico', 2, true, false, 'ESPECIALIDADES', 'CATALOGO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (666, 9, 25, 'servicioAtencion', 'Servicio de atención', 'numerico', 2, true, false, 'ESPECIALIDADES', 'CATALOGO', 'TABLA_ESPECIALIDADES');
INSERT INTO public.sys_giis_campos VALUES (10, 1, 10, 'nacioHospital', 'Nació en el hospital', 'texto', 1, false, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (11, 1, 11, 'sexo', 'Sexo del paciente', 'texto', 1, true, false, 'SEXO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (14, 1, 14, 'derechohabiencia', 'Afiliación', 'texto', 2, true, false, 'AFILIACION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (15, 1, 15, 'gratuidad', 'Programa de Salud de la Ciudad de México', 'texto', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (16, 1, 16, 'estadoConyugal', 'Estado conyugal del paciente', 'texto', 1, true, false, 'ESTADO_CONYUGAL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (17, 1, 17, 'seConsideraIndigena', '¿Se considera Indígena?', 'texto', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (18, 1, 18, 'hablaLenguaIndigena', '¿Habla alguna lengua Indígena?', 'texto', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (19, 1, 19, 'cualLengua', '¿Cuál lengua Indígena habla?', 'texto', 4, true, false, 'LENGUA_INDIGENA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (20, 1, 20, 'seConsideraAfromexicano', '¿Se considera Afromexicano?', 'texto', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (29, 1, 29, 'tipoServicioIngreso', 'Clave del tipo de servicio de ingreso', 'texto', 1, true, false, 'HOSP_TIPO_INGRESO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (38, 1, 38, 'procedencia', 'Área de procedencia del paciente', 'texto', 1, true, false, 'HOSP_PROCEDENCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (41, 1, 41, 'motivoEgreso', 'Motivo del egreso', 'texto', 1, true, false, 'HOSP_MOTIVO_EGRESO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (43, 1, 43, 'mujerFertil', 'Mujer en edad fértil', 'texto', 1, true, false, 'HOSP_MUJER_FERTIL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (46, 1, 46, 'tipoAtencion', 'Tipo de atención proporcionada', 'texto', 1, true, false, 'HOSP_TIPO_ATENCION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (54, 1, 54, 'infeccionIntraHospitalaria', 'Existió Infección intrahospitalaria', 'texto', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (58, 1, 58, 'tipoAnestesia', 'Tipo de Anestesia', 'texto', 1, false, false, 'HOSP_TIPO_ANESTESIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (59, 1, 59, 'quirofanoDentroFuera', 'Uso del quirófano', 'texto', 1, false, false, 'HOSP_USO_QUIROFANO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (63, 1, 63, 'ministerioPublico', 'Envió al MP al fallecido', 'texto', 1, false, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (70, 1, 70, 'tipoAtencionObstetrica', 'Tipo de Atención Obstétrica', 'texto', 1, false, false, 'HOSP_ATENCION_OBST', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (71, 1, 71, 'tipoParto', 'Tipo de parto', 'texto', 1, false, false, 'HOSP_TIPO_PARTO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (75, 1, 75, 'planificacionFamiliar', 'Método de planificación familiar', 'texto', 2, false, false, 'HOSP_PLANIFICACION_FAM', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (78, 1, 78, 'condicionNacimiento', 'Condición de nacimiento', 'texto', 1, false, false, 'HOSP_CONDICION_NAC', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (82, 1, 82, 'reanimacionNeonatal', 'Uso de reanimación', 'texto', 1, false, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (83, 1, 83, 'alojamientoConjunto', 'Alojamiento conjunto con madre', 'texto', 1, false, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (84, 1, 84, 'lactanciaExclusiva', 'Lactancia exclusiva', 'texto', 1, false, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (102, 2, 10, 'sexo', 'Registre el sexo del paciente', 'numerico', 1, true, false, 'SEXO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (103, 2, 11, 'derechohabiencia', 'Institución del SNS en la cual se encuentran afiliados', 'numerico', 2, true, false, 'AFILIACION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (104, 2, 12, 'gratuidad', 'Programa de Salud de la Ciudad de México', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (105, 2, 13, 'seConsideraIndigena', '¿Se considera Indígena?', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (106, 2, 14, 'seConsideraAfromexicano', '¿Se considera Afromexicano?', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (113, 2, 21, 'atencionPreHospitalaria', 'Atención prehospitalaria al paciente', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (117, 2, 25, 'tipoUrgencia', 'Tipo de urgencia', 'numerico', 1, true, false, 'URG_TIPO_URGENCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (118, 2, 26, 'motivoAtencion', 'Motivo de la atención proporcionada', 'numerico', 1, true, false, 'URG_MOTIVO_ATENCION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (119, 2, 27, 'tipoCama', 'Tipo de cama en la que se encuentra el paciente', 'numerico', 1, true, false, 'URG_TIPO_CAMA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (120, 2, 28, 'trasladoTransitorio', 'Traslado transitorio a otro hospital', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (124, 2, 32, 'altaPor', 'Motivo de alta del servicio de urgencias', 'numerico', 1, true, false, 'URG_ALTA_POR', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (126, 2, 34, 'ministerioPublico', 'Envió al Ministerio Publico el Certificado', 'numerico', 1, false, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (128, 2, 36, 'mujerFertil', 'Mujer embarazada o puérpera', 'numerico', 1, false, false, 'HOSP_MUJER_FERTIL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (147, 2, 55, 'codigoMedicamento', 'Código del medicamento', 'texto', 20, false, false, 'MEDICAMENTOS', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (148, 2, 56, 'planIras', 'Plan Infecciones respiratorias', 'numerico', 1, false, false, 'URG_PLAN_IRAS', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (149, 2, 57, 'planEdas', 'Plan enfermedades diarreicas', 'numerico', 1, false, false, 'URG_PLAN_EDAS', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (167, 3, 11, 'sabeLeerEscribir', 'Habilidad del paciente para leer y escribir', 'numerico', 1, false, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (168, 3, 12, 'sexo', 'Sexo del paciente', 'numerico', 1, true, false, 'SEXO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (169, 3, 13, 'derechohabiencia', 'Afiliación', 'numerico', 2, true, false, 'AFILIACION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (170, 3, 14, 'gratuidad', 'Programa de Salud CDMX', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (171, 3, 15, 'seConsideraIndigena', '¿Se considera Indígena?', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (172, 3, 16, 'hablaLenguaIndigena', '¿Habla lengua Indígena?', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (173, 3, 17, 'cualLengua', '¿Cuál lengua Indígena habla?', 'texto', 4, true, false, 'LENGUA_INDIGENA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (174, 3, 18, 'seConsideraAfromexicano', '¿Se considera Afromexicano?', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (175, 3, 19, 'mujerFertil', '¿Se encuentra embarazada?', 'numerico', 1, true, false, 'HOSP_MUJER_FERTIL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (177, 3, 21, 'discapacidad', 'Discapacidad preexistente', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (178, 3, 22, 'usuarioReferido', 'Institución que refiere al paciente', 'numerico', 1, true, false, 'LES_USUARIO_REFERIDO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (182, 3, 26, 'diaFestivo', '¿Día festivo o fin de semana?', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (183, 3, 27, 'sitioOcurrencia', 'Sitio de ocurrencia del evento', 'numerico', 3, true, false, 'SITIO_OCURRENCIA_LESION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (194, 3, 38, 'atencionPreHospitalaria', 'Atención prehospitalaria', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (196, 3, 40, 'sospechaBajoEfectosDe', '¿Bajo efecto de alcohol o droga?', 'texto', 5, true, false, 'LES_SUSTANCIAS', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (197, 3, 41, 'intencionalidad', 'Intencionalidad del evento', 'numerico', 2, true, false, 'LES_INTENCIONALIDAD', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (198, 3, 42, 'eventoRepetido', 'Identificación de evento repetido', 'numerico', 1, true, false, 'LES_EVENTO_REPETIDO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (199, 3, 43, 'agenteLesion', 'Agente que produjo la lesión', 'numerico', 3, true, false, 'AGENTE_LESION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (201, 3, 45, 'lesionadoVehiculoMotor', 'Lesionado vehículo motor', 'numerico', 1, false, false, 'LES_LESIONADO_VEHICULO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (202, 3, 46, 'usoEquipoSeguridad', 'Uso equipo de seguridad', 'numerico', 1, false, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (203, 3, 47, 'equipoUtilizado', 'Equipo utilizado', 'numerico', 1, false, false, 'LES_EQUIPO_UTILIZADO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (205, 3, 49, 'tipoViolencia', 'Tipo de violencia', 'texto', 15, false, false, 'LES_TIPO_VIOLENCIA', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (206, 3, 50, 'numeroAgresores', 'Número de agresores', 'numerico', 1, false, false, 'LES_NUMERO_AGRESORES', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (207, 3, 51, 'parentescoAfectado', 'Parentesco del agresor', 'numerico', 2, false, false, 'LES_PARENTESCO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (208, 3, 52, 'sexoAgresor', 'Sexo del agresor', 'numerico', 1, false, false, 'SEXO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (210, 3, 54, 'agresorBajoEfectos', 'Agresor bajo efectos de sustancia', 'texto', 5, false, false, 'LES_SUSTANCIAS', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (213, 3, 57, 'servicioAtencion', 'Servicio que otorgo la atención', 'numerico', 1, true, false, 'LES_SERVICIO_ATENCION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (215, 3, 59, 'tipoAtencion', 'Tipo de atención', 'texto', 20, true, false, 'LES_TIPO_ATENCION', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (216, 3, 60, 'areaAnatomica', 'Área anatómica de mayor gravedad', 'numerico', 2, true, false, 'AREA_ANATOMICA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (218, 3, 62, 'consecuenciaGravedad', 'Consecuencia resultante', 'numerico', 2, true, false, 'CONSECUENCIA_LESION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (228, 3, 72, 'despuesAtencion', 'Destino después de atención', 'numerico', 2, true, false, 'LES_DESPUES_ATENCION', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (230, 3, 74, 'ministerioPublico', 'Dio aviso al MP', 'numerico', 1, true, false, 'SIS_OPCION_SINO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (232, 3, 76, 'responsableAtencion', 'Responsable de atención', 'numerico', 1, true, false, 'LES_RESPONSABLE', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (245, 4, 7, 'tipoPersonal', 'Tipo de profesional de la salud', 'numerico', 2, true, false, 'BUC_TIPO_PERSONAL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (246, 4, 8, 'programaSMYMG', 'Contratado para Prog. U013', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (254, 4, 16, 'sexoCURP', 'Sexo registrado ante RENAPO', 'numerico', 1, true, false, 'BUC_SEXO_CURP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (255, 4, 17, 'sexoBiologico', 'Sexo biológico/fisiológico', 'numerico', 1, true, false, 'BUC_SEXO_BIO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (256, 4, 18, 'seAutodenominaAfromexicano', 'Autodenominación Afromexicano', 'numerico', 1, true, false, 'BUC_AFRO_INDIGENA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (257, 4, 19, 'seConsideraIndigena', 'Identifica si se considera indígena', 'numerico', 1, true, false, 'BUC_AFRO_INDIGENA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (258, 4, 20, 'migrante', 'Identifica si es migrante', 'numerico', 1, true, false, 'BUC_MIGRANTE', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (260, 4, 22, 'genero', 'Identidad de género', 'numerico', 2, true, false, 'BUC_GENERO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (261, 4, 23, 'derechohabiencia', 'Afiliación(es) del SNS', 'texto', 20, true, false, 'AFILIACION', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (274, 4, 36, 'tipoMedicion', 'Medición de glucosa en ayunas', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (275, 4, 37, 'primeraVezAnio', 'Primera consulta en el año (cobertura)', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (276, 4, 38, 'relacionTemporal', 'Relación temporal por motivo', 'numerico', 1, true, false, 'BUC_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (278, 4, 40, 'primeraVezDiagnostico2', 'Primera vez del diagnóstico 2', 'numerico', 1, false, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (280, 4, 42, 'primeraVezDiagnostico3', 'Primera vez del diagnóstico 3', 'numerico', 1, false, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (282, 4, 44, 'placaBacteriana', 'Detección de placa bacteriana', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (283, 4, 45, 'cepillado', 'Instrucción en Técnica de Cepillado', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (284, 4, 46, 'hiloDental', 'Instrucción de uso de Hilo Dental', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (285, 4, 47, 'limpiezaDental', 'Realización de limpieza dental', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (286, 4, 48, 'protesis', 'Revisión/Higiene de prótesis bucales', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (287, 4, 49, 'tejidosBucales', 'Examen de tejidos bucales', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (288, 4, 50, 'autoExamen', 'Autoexamen de cavidad bucal', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (289, 4, 51, 'fluor', 'Aplicación tópica de Flúor', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (290, 4, 52, 'raspadoAlisadoPeriodontal', 'Raspado y alisado periodontal', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (291, 4, 53, 'barnizFluor', 'Aplicación de Barniz de Flúor', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (301, 4, 63, 'cirugiaBucal', 'Actividad quirúrgica menor', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (302, 4, 64, 'farmacoTerapia', 'Prescripción de fármacos', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (305, 4, 67, 'orientacionSaludBucal', 'Orientación de Salud Bucal', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (306, 4, 68, 'tratamientoIntegral', 'Conclusión integral del tratamiento', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (307, 4, 69, 'lineaVida', 'Programa Línea de Vida', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (308, 4, 70, 'cartillaSalud', 'Presenta cartilla de salud', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (309, 4, 71, 'esquemaVacunacion', 'Esquema de vacunación completo', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (311, 4, 73, 'contrarreferido', 'Paciente contrarreferido', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (312, 4, 74, 'telemedicina', 'Solicita telemedicina', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (313, 4, 75, 'teleconsulta', 'Consulta a distancia', 'numerico', 1, true, false, 'BUC_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (314, 4, 76, 'estudiosTeleconsulta', 'Estudios valorados a distancia', 'texto', 15, false, false, 'BUC_TELECONSULTA_ESTUDIOS', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (315, 4, 77, 'modalidadConsulDist', 'Modalidad de teleconsulta', 'numerico', 1, false, false, 'BUC_MODALIDAD_TELE', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (399, 6, 7, 'tipoPersonal', 'Tipo de profesional de la salud', 'numerico', 2, true, false, 'MEN_TIPO_PERSONAL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (400, 6, 8, 'programaSMyMG', 'Programa U013', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (415, 6, 23, 'derechohabiencia', 'Afiliación', 'texto', 20, true, false, 'AFILIACION', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (428, 6, 36, 'tipoMedicion', 'Glucosa en ayunas', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (429, 6, 37, 'primeraVezAnio', 'Primera consulta en el año', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (430, 6, 38, 'primeraVezUneme', 'Seguimiento en UNEME', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (433, 6, 41, 'primeraVezDiagnostico2', 'Primera vez diag 2', 'numerico', 1, false, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (435, 6, 43, 'primeraVezDiagnostico3', 'Primera vez diag 3', 'numerico', 1, false, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (438, 6, 46, 'evaluacionPsicologica', 'Evaluación psicológica', 'numerico', 1, false, false, 'MEN_EVALUACION_PSICOLOGICA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (439, 6, 47, 'psicoTerapia', 'Tipo de psicoterapia', 'numerico', 1, false, false, 'MEN_PSICOTERAPIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (440, 6, 48, 'psicoEducacion', 'Psicoeducación otorgada', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (441, 6, 49, 'sustanciaDeConsumo', 'Sustancia(s) de consumo', 'texto', 20, true, false, 'MEN_SUSTANCIAS', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (442, 6, 50, 'tipoAtencionAlcohol', 'Atención por Alcohol', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (443, 6, 51, 'tipoConsumoAlcohol', 'Consumo de Alcohol', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (444, 6, 52, 'tipoAtencionTabaco', 'Atención por Tabaco', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (445, 6, 53, 'tipoConsumoTabaco', 'Consumo de Tabaco', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (446, 6, 54, 'tipoAtencionCannabis', 'Atención por Cannabis', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (447, 6, 55, 'tipoConsumoCannabis', 'Consumo de Cannabis', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (448, 6, 56, 'tipoAtencionCocaina', 'Atención por Cocaína', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (449, 6, 57, 'tipoConsumoCocaina', 'Consumo de Cocaína', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (450, 6, 58, 'tipoAtencionMetanfetaminas', 'Atención Metanfetaminas', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (451, 6, 59, 'tipoConsumoMetanfetaminas', 'Consumo Metanfetaminas', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (452, 6, 60, 'tipoAtencionInhalables', 'Atención Inhalables', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (453, 6, 61, 'tipoConsumoInhalables', 'Consumo Inhalables', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (454, 6, 62, 'tipoAtencionOpiaceos', 'Atención Opiáceos', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (455, 6, 63, 'tipoConsumoOpiaceos', 'Consumo Opiáceos', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (456, 6, 64, 'tipoAtencionAlucinogenos', 'Atención Alucinógenos', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (457, 6, 65, 'tipoConsumoAlucinogenos', 'Consumo Alucinógenos', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (458, 6, 66, 'tipoAtencionBenzodiacepinas', 'Atención Benzodiacepinas', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (459, 6, 67, 'tipoConsumoBenzodiacepinas', 'Consumo Benzodiacepinas', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (460, 6, 68, 'tipoAtencionOtros', 'Atención Otras sustancias', 'numerico', 1, false, false, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (461, 6, 69, 'tipoConsumoOtros', 'Consumo Otras sustancias', 'numerico', 1, false, false, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (462, 6, 70, 'ambitoViolencias', 'Ámbito de violencias', 'texto', 5, false, false, 'MEN_AMBITO_VIOLENCIA', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (463, 6, 71, 'tipoViolenciaFamiliar', 'Tipo de violencia familiar', 'texto', 10, false, false, 'MEN_TIPO_VIOLENCIA', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (464, 6, 72, 'tipoViolenciaComunitaria', 'Tipo de violencia comunitaria', 'texto', 10, false, false, 'MEN_TIPO_VIOLENCIA', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (465, 6, 73, 'tipoViolenciaColectiva', 'Tipo de violencia colectiva', 'texto', 10, false, false, 'MEN_TIPO_VIOLENCIA', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (466, 6, 74, 'comportamientoSuicida', 'Comportamiento suicida', 'numerico', 1, false, false, 'MEN_COMPORTAMIENTO_SUICIDA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (468, 6, 76, 'pacienteRehabilitado', 'Remisión o recuperación', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (469, 6, 77, 'lineaVida', 'Programa Línea de Vida', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (470, 6, 78, 'cartillaSalud', 'Presenta cartilla', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (471, 6, 79, 'esquemaVacunacion', 'Esquema de vacunación', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (473, 6, 81, 'contrarreferido', 'Paciente contrarreferido', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (474, 6, 82, 'telemedicina', 'Solicita telemedicina', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (475, 6, 83, 'teleconsulta', 'Consulta a distancia', 'numerico', 1, true, false, 'MEN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (484, 7, 7, 'tipoPersonal', 'Tipo de profesional de la salud', 'numerico', 2, true, false, 'PLAN_TIPO_PERSONAL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (485, 7, 8, 'programaSMyMG', 'Programa U013', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (493, 7, 16, 'sexoCURP', 'Sexo registrado ante RENAPO', 'numerico', 1, true, false, 'PLAN_SEXO_CURP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (494, 7, 17, 'sexoBiologico', 'Sexo biológico/fisiológico', 'numerico', 1, true, false, 'PLAN_SEXO_BIO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (495, 7, 18, 'seAutodenominaAfromexicano', 'Afromexicano', 'numerico', 1, true, false, 'PLAN_AFRO_INDIGENA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (496, 7, 19, 'seConsideraIndigena', 'Indígena', 'numerico', 1, true, false, 'PLAN_AFRO_INDIGENA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (497, 7, 20, 'migrante', 'Migrante', 'numerico', 1, true, false, 'PLAN_MIGRANTE', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (499, 7, 22, 'genero', 'Identidad de género', 'numerico', 2, true, false, 'PLAN_GENERO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (500, 7, 23, 'derechohabiencia', 'Afiliación', 'texto', 20, true, false, 'AFILIACION', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (513, 7, 36, 'tipoMedicion', 'Glucosa en ayunas', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (514, 7, 37, 'primeraVezAnio', 'Primera consulta en el año', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (515, 7, 38, 'relacionTemporal', 'Primera vez o subsecuente', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (517, 7, 40, 'primeraVezDiagnostico2', 'Primera vez diag 2', 'numerico', 1, false, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (519, 7, 42, 'primeraVezDiagnostico3', 'Primera vez diag 3', 'numerico', 1, false, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (521, 7, 44, 'puerperaAceptaPF', 'Aceptó PF en puerperio', 'numerico', 1, false, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (526, 7, 49, 'implanteSubdermico1Var', 'Implante 1 varilla', 'numerico', 1, false, false, 'PLAN_REVISION_DIU', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (527, 7, 50, 'implanteSubdermico2Var', 'Implante 2 varillas', 'numerico', 1, false, false, 'PLAN_REVISION_DIU', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (529, 7, 52, 'diu', 'Revisión o colocación DIU', 'numerico', 1, false, false, 'PLAN_REVISION_DIU', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (530, 7, 53, 'diuMedicado', 'Revisión/colocación DIU medicado', 'numerico', 1, false, false, 'PLAN_REVISION_DIU', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (531, 7, 54, 'quirurgico', 'Método quirúrgico (OTB/Vasectomía)', 'numerico', 1, false, false, 'PLAN_REVISION_QUIRURGICA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (535, 7, 58, 'anticoncepcionEmergencia', 'Píldora de emergencia', 'numerico', 1, false, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (536, 7, 59, 'altaConAzoospermia', 'Alta con azoospermia (Vasectomía)', 'numerico', 1, false, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (537, 7, 60, 'OycPlanificacionF', 'Orientación de PF', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (538, 7, 61, 'OycPrevencionITS', 'Orientación ITS', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (539, 7, 62, 'OycPrevencionEmb', 'Orientación prev. Embarazo', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (540, 7, 63, 'OycOtrasSSRA', 'Salud Sexual en Adolescencia', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (541, 7, 64, 'lineaVida', 'Programa Línea de Vida', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (542, 7, 65, 'cartillaSalud', 'Presenta cartilla', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (543, 7, 66, 'esquemaVacunacion', 'Esquema de vacunación', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (545, 7, 68, 'contrarreferido', 'Paciente contrarreferido', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (546, 7, 69, 'telemedicina', 'Solicita telemedicina', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (547, 7, 70, 'teleconsulta', 'Consulta a distancia', 'numerico', 1, true, false, 'PLAN_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (548, 7, 71, 'estudiosTeleconsulta', 'Estudios teleconsulta', 'texto', 15, false, false, 'PLAN_ESTUDIOS_TELE', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (556, 8, 7, 'tipoPersonal', 'Tipo de profesional de la salud', 'numerico', 2, true, false, 'DET_TIPO_PERSONAL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (557, 8, 8, 'programaSMyMG', 'Programa U013', 'numerico', 1, true, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (567, 8, 18, 'seAutodenominaAfromexicano', 'Afromexicano', 'numerico', 1, true, false, 'DET_AFRO_INDIGENA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (568, 8, 19, 'seConsideraIndigena', 'Indígena', 'numerico', 1, true, false, 'DET_AFRO_INDIGENA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (569, 8, 20, 'migrante', 'Migrante', 'numerico', 1, true, false, 'DET_MIGRANTE', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (571, 8, 22, 'genero', 'Identidad de género', 'numerico', 2, true, false, 'DET_GENERO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (572, 8, 23, 'derechohabiencia', 'Afiliación', 'texto', 20, true, false, 'AFILIACION', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (585, 8, 36, 'tipoMedicion', 'Glucosa en ayunas', 'numerico', 1, true, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (587, 8, 38, 'primeraVezAnio', 'Primera consulta en el año', 'numerico', 1, true, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (588, 8, 39, 'depresionTamizaje', 'Tamizaje de depresión', 'numerico', 1, false, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (589, 8, 40, 'depresion', 'Detección de depresión', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (590, 8, 41, 'ansiedad', 'Detección de ansiedad', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (591, 8, 42, 'haOlvidadoMasCosas', 'Tamizaje olvido de cosas', 'numerico', 1, false, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (592, 8, 43, 'alteracionesDeMemoria', 'Detección alteración memoria', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (593, 8, 44, 'demencia', 'Riesgo de demencia', 'numerico', 1, false, false, 'DET_RIESGO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (594, 8, 45, 'tamizajeFugaDeOrina', 'Tamizaje fuga de orina', 'numerico', 1, false, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (595, 8, 46, 'incontinenciaUrinaria', 'Detección incontinencia', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (596, 8, 47, 'tamizajeCaidas', 'Tamizaje de caídas', 'numerico', 1, false, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (597, 8, 48, 'caida60yMas', 'Detección síndrome de caídas', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (598, 8, 49, 'marcha', 'Evaluación de la marcha', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (599, 8, 50, 'estadoNutricional', 'Evaluación estado nutricional', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (600, 8, 51, 'abvdTamizaje', 'Tamizaje ABVD', 'numerico', 1, false, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (601, 8, 52, 'abvdEvaluacion', 'Evaluación ABVD', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (602, 8, 53, 'aivdTamizaje', 'Tamizaje AIVD', 'numerico', 1, false, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (603, 8, 54, 'aivdEvaluacion', 'Evaluación AIVD', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (606, 8, 57, 'sobrecargaCuidador', 'Sobrecarga del cuidador', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (607, 8, 58, 'riesgoFractura', 'Riesgo fractura osteoporosis', 'numerico', 1, false, false, 'DET_RIESGO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (608, 8, 59, 'diabetesMellitus', 'Detección Diabetes Mellitus', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (609, 8, 60, 'hipertensionArterial', 'Detección Hipertensión', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (610, 8, 61, 'obesidad', 'Detección Obesidad', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (611, 8, 62, 'dislipidemias', 'Detección Dislipidemias', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (612, 8, 63, 'alcohol', 'Consumo Alcohol', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (613, 8, 64, 'tabaco', 'Consumo Tabaco', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (614, 8, 65, 'cannabis', 'Consumo Cannabis', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (615, 8, 66, 'cocaina', 'Consumo Cocaína', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (616, 8, 67, 'metanfetaminas', 'Consumo Metanfetaminas', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (617, 8, 68, 'inhalables', 'Consumo Inhalables', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (618, 8, 69, 'opiaceos', 'Consumo Opiáceos', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (619, 8, 70, 'alucinogenos', 'Consumo Alucinógenos', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (620, 8, 71, 'tranquilizantes', 'Consumo Tranquilizantes', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (621, 8, 72, 'otrasSubstancias', 'Otras Sustancias', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (622, 8, 73, 'B24X', 'Detección VIH', 'numerico', 2, false, false, 'DET_PRUEBAS_ITS', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (623, 8, 74, 'A539', 'Detección Sífilis', 'numerico', 2, false, false, 'DET_PRUEBAS_ITS', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (625, 8, 76, 'hepatitisB', 'Detección Hepatitis B', 'numerico', 2, false, false, 'DET_PRUEBAS_ITS', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (628, 8, 79, 'resultadoVPH', 'Resultado VPH', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (630, 8, 81, 'resultadoCancerCervicoUterino', 'Resultado Citología', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (631, 8, 82, 'cancerMama', 'Detección Cáncer Mama', 'numerico', 1, false, false, 'DET_NORMAL_ANORMAL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (632, 8, 83, 'violenciaSexual', 'Violencia sexual no pareja', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (633, 8, 84, 'violenciaMujer15yMas', 'Violencia por pareja', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (634, 8, 85, 'sospechaSindromeTurner', 'Sospecha de Turner', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (635, 8, 86, 'hiperplasiaProstatica', 'Próstata/Cuestionario PSA', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (637, 8, 88, 'sintomaticoRespiratorio', 'Probable TB', 'numerico', 1, false, false, 'DET_POS_NEG', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (640, 8, 91, 'espirometriaResultado', 'Resultado Espirometría', 'numerico', 2, false, false, 'DET_ESPIROMETRIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (641, 8, 92, 'cartillaSalud', 'Presenta cartilla', 'numerico', 1, false, false, 'DET_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (648, 9, 7, 'tipoPersonal', 'Tipo de profesional', 'numerico', 2, true, false, 'TIPO PERSONAL - SIS', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (649, 9, 8, 'programaSMyMG', 'Programa U013', 'numerico', 1, true, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (657, 9, 16, 'sexoCURP', 'Sexo según CURP', 'numerico', 1, true, false, 'CEX_SEXO_CURP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (658, 9, 17, 'sexoBiologico', 'Sexo biológico', 'numerico', 1, true, false, 'CEX_SEXO_BIO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (659, 9, 18, 'seAutodenominaAfromexicano', 'Afromexicano', 'numerico', 1, true, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (660, 9, 19, 'seConsideraIndigena', 'Indígena', 'numerico', 1, true, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (663, 9, 22, 'genero', 'Identidad de género', 'numerico', 2, true, false, 'CEX_GENERO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (664, 9, 23, 'derechohabiencia', 'Afiliación', 'texto', 20, true, false, 'AFILIACION', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (677, 9, 36, 'tipoMedicion', 'Glucosa en ayunas', 'numerico', 1, true, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (680, 9, 39, 'sintomaticoRespiratorioTb', 'Probable TB', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (681, 9, 40, 'primeraVezAnio', 'Primera consulta año', 'numerico', 1, true, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (682, 9, 41, 'primeraVezUneme', 'Seguimiento UNEME', 'numerico', 1, true, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (683, 9, 42, 'relacionTemporal', 'Relación temporal', 'numerico', 1, true, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (685, 9, 44, 'confirmacionDiagnostica1', 'Confirma Dx1', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (686, 9, 45, 'primeraVezDiagnostico2', 'Primera vez Dx2', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (688, 9, 47, 'confirmacionDiagnostica2', 'Confirma Dx2', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (689, 9, 48, 'primeraVezDiagnostico3', 'Primera vez Dx3', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (691, 9, 50, 'confirmacionDiagnostica3', 'Confirma Dx3', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (693, 9, 52, 'atencionPregestacionalRT', 'Atención pregestacional', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (694, 9, 53, 'riesgo', 'Riesgos detectados', 'texto', 10, false, false, 'CEX_RIESGO_PREGESTACIONAL', 'ARREGLO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (695, 9, 54, 'relacionTemporalEmbarazo', 'Relación temporal embarazo', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (697, 9, 56, 'trimestreGestacional', 'Trimestre gestacional', 'numerico', 1, false, false, 'CEX_TRIMESTRE_GESTACIONAL', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (698, 9, 57, 'primeraVezAltoRiesgo', 'Alto riesgo primera vez', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (699, 9, 58, 'complicacionPorDiabetes', 'Complicación Diabetes', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (700, 9, 59, 'complicacionPorInfeccionUrinaria', 'Complicación IVU', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (701, 9, 60, 'complicacionPorPreeclampsiaEclampsia', 'Complicación Preeclampsia', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (702, 9, 61, 'complicacionPorHemorragia', 'Complicación hemorragia', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (703, 9, 62, 'sospechaCovid19', 'Sospecha COVID Embarazo', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (704, 9, 63, 'covid19Confirmado', 'COVID confirmado', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (705, 9, 64, 'hipertensionarterialprexistente', 'HTA preexistente', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (706, 9, 65, 'otrasAccPrescAcidoFolico', 'Acido fólico', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (707, 9, 66, 'otrasAccApoyoTranslado', 'Apoyo traslado obstétrico', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (708, 9, 67, 'otrasACCApoyoTransladoAME', 'Transporte AME', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (709, 9, 68, 'puerpera', 'Puerperio', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (710, 9, 69, 'infeccionPuerperal', 'Infección puerperal', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (711, 9, 70, 'terapiaHormonal', 'Terapia Hormonal', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (712, 9, 71, 'periPostMenopausia', 'Menopausia', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (713, 9, 72, 'its', 'Infección transmisión sexual', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (714, 9, 73, 'patologiaMamariaBenigna', 'Patología mamaria', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (715, 9, 74, 'cancerMamario', 'Cáncer mamario', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (716, 9, 75, 'colposcopia', 'Realizó colposcopia', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (717, 9, 76, 'cancerCervicouterino', 'Cáncer cervicouterino', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (718, 9, 77, 'ninoSanoRT', 'Consulta niño sano', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (720, 9, 79, 'resultadoEDI', 'Resultado EDI', 'numerico', 1, false, false, 'CEX_RESULTADO_EDI', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (721, 9, 80, 'resultadoBattelle', 'Resultado Battelle', 'numerico', 1, false, false, 'CEX_RESULTADO_BATTELLE', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (722, 9, 81, 'edasRT', 'EDAS relación temporal', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (723, 9, 82, 'edasPlanTratamiento', 'Plan tratamiento EDAS', 'numerico', 1, false, false, 'CEX_PLAN_EDAS', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (724, 9, 83, 'recuperadoDeshidratacion', 'Recuperado deshidratación', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (726, 9, 85, 'irasRT', 'IRAS relación temporal', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (727, 9, 86, 'irasPlanTratamiento', 'Plan tratamiento IRAS', 'numerico', 1, false, false, 'CEX_PLAN_IRAS', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (728, 9, 87, 'neumoniaRT', 'Neumonía temporalidad', 'numerico', 1, false, false, 'CEX_RELACION_TEMP', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (730, 9, 89, 'informaPrevencionAccidentes', 'Prevención accidentes <10', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (731, 9, 90, 'sintomaDepresiva', 'Sintomatología depresiva', 'numerico', 1, false, false, 'CEX_GERONTOLOGIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (732, 9, 91, 'alteracionMemoria', 'Alteración memoria', 'numerico', 1, false, false, 'CEX_GERONTOLOGIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (733, 9, 92, 'aivd_ABVD', 'Actividades vida diaria', 'numerico', 1, false, false, 'CEX_GERONTOLOGIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (734, 9, 93, 'sindromeCaidas', 'Síndrome caídas', 'numerico', 1, false, false, 'CEX_GERONTOLOGIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (735, 9, 94, 'incontinenciaUrinaria', 'Incontinencia', 'numerico', 1, false, false, 'CEX_GERONTOLOGIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (736, 9, 95, 'motricidad', 'Motricidad', 'numerico', 1, false, false, 'CEX_GERONTOLOGIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (737, 9, 96, 'asesoriaNutricional', 'Asesoría nutricional', 'numerico', 1, false, false, 'CEX_GERONTOLOGIA', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (739, 9, 98, 'lineaVida', 'Programa Línea de Vida', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (740, 9, 99, 'cartillaSalud', 'Presenta cartilla', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (741, 9, 100, 'esquemaVacunacion', 'Esquema de vacunación', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (742, 9, 101, 'referidoPor', 'Referido a unidad mayor', 'numerico', 1, false, false, 'CEX_MOTIVO_REFERIDO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (743, 9, 102, 'contrarreferido', 'Contrarreferido', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (744, 9, 103, 'telemedicina', 'Solicita telemedicina', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (745, 9, 104, 'teleconsulta', 'Consulta a distancia', 'numerico', 1, false, false, 'CEX_SINO_CERO_UNO', 'CATALOGO', 'DICCIONARIO_GUI');
INSERT INTO public.sys_giis_campos VALUES (747, 9, 106, 'modalidadConsulDist', 'Modalidad teleconsulta', 'numerico', 1, false, false, 'CEX_MODALIDAD_TELE', 'CATALOGO', 'DICCIONARIO_GUI');


--
-- TOC entry 4642 (class 0 OID 160435)
-- Dependencies: 254
-- Data for Name: sys_giis_restricciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sys_giis_restricciones VALUES (1, 1, 12, 'LIMITE_PESO', 'RANGO_VALOR', '{"max": 400, "min": 1, "operador": "between"}', 'El peso debe estar entre 1 y 400 kg.', 'ERROR', '2022-07-15');
INSERT INTO public.sys_giis_restricciones VALUES (2, 1, 29, 'REQ_CLAVE_SERVICIO', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "claveServicioIngreso"}, "operador": "if_then", "condicion": {"campo": "tipoServicioIngreso", "valor": "1"}}', 'Si el ingreso es Normal (1), la Especialidad de Ingreso es obligatoria.', 'ERROR', '2022-07-15');
INSERT INTO public.sys_giis_restricciones VALUES (3, 1, 69, 'LIMITE_EDAD_GESTACIONAL', 'RANGO_VALOR', '{"max": 45, "min": 1, "operador": "between"}', 'La edad gestacional no puede ser mayor a 45 semanas.', 'ERROR', '2022-07-15');
INSERT INTO public.sys_giis_restricciones VALUES (4, 1, NULL, 'COHERENCIA_PARTO_ABORTO', 'LOGICA_CRUZADA', '{"operador": "not_and", "condiciones": [{"campo": "codigoCIEAfeccionPrincipal", "startsWith": "O8"}, {"campo": "codigoCIEAfeccionPrincipal", "startsWith": "O0"}]}', 'No se puede mezclar diagnósticos de parto con aborto en la misma atención.', 'ERROR', '2022-07-15');
INSERT INTO public.sys_giis_restricciones VALUES (5, 1, 59, 'REQ_CEDULA_MEDICO', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "cedulaProfesional"}, "operador": "if_then", "condicion": {"campo": "quirofanoDentroFuera", "valor": "1"}}', 'Si se utilizó el quirófano (DENTRO), la Cédula Profesional del médico es obligatoria.', 'ERROR', '2022-07-15');
INSERT INTO public.sys_giis_restricciones VALUES (6, 1, 62, 'REQ_FOLIO_LESION', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "folioLesion"}, "operador": "if_then", "condicion": {"campo": "codigoCIEAfeccionPrincipal", "startsWith_any": ["S", "T"]}}', 'Si el diagnóstico principal corresponde al Capítulo XIX (Lesiones S00-T98), el folio de lesión es obligatorio.', 'ERROR', '2022-07-15');
INSERT INTO public.sys_giis_restricciones VALUES (7, 1, 81, 'REQ_APGAR', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "apgar5Minutos"}, "operador": "if_then", "condicion": {"campo": "tipoAtencionObstetrica", "valor": "2"}}', 'Si el tipo de atención obstétrica es PARTO (2), se debe registrar la valoración del APGAR a los 5 minutos.', 'ERROR', '2022-07-15');
INSERT INTO public.sys_giis_restricciones VALUES (8, 2, 121, 'REQ_CLUES_TRASLADO', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "cluesTraslado"}, "operador": "if_then", "condicion": {"campo": "trasladoTransitorio", "valor": "1"}}', 'Si hay traslado transitorio, la CLUES de la unidad receptora es obligatoria.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (9, 2, 125, 'REQ_CLUES_REFERENCIA', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "cluesReferido"}, "operador": "if_then", "condicion": {"campo": "altaPor", "valor": "3"}}', 'Si el alta es por Traslado a Otra Unidad, la CLUES de destino es obligatoria.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (10, 2, 127, 'REQ_CERTIFICADO_DEFUNCION', 'LOGICA_COMPLEJA', '{"accion": {"requerido": "folioCertificadoDefuncion"}, "operador": "if_then", "condicion": {"and": [{"campo": "altaPor", "valor": "5"}, {"campo": "ministerioPublico", "valor": "2"}]}}', 'Si el alta es por Defunción y NO se envió al Ministerio Público, el Folio del Certificado de Defunción es obligatorio.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (11, 2, 122, 'LOGICA_FECHAS_URGENCIA', 'COMPARACION_CAMPOS', '{"campo1": "fechaAlta", "campo2": "fechaIngreso", "operador": "greater_than_or_equal"}', 'La fecha de alta de urgencias no puede ser anterior a la fecha de ingreso.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (12, 2, 116, 'FORMATO_HORA_INGRESO', 'REGEX', '{"patron": "^([01]?[0-9]|2[0-3]):[0-5][0-9]$", "operador": "match"}', 'La hora de ingreso debe tener un formato válido de 24 horas (HH:MM).', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (13, 2, 129, 'REQ_EDAD_GESTACIONAL', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "edadGestacional"}, "operador": "if_then", "condicion": {"campo": "mujerFertil", "valor": "1"}}', 'Si la mujer está embarazada, el registro de semanas de gestación es obligatorio.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (14, 3, 181, 'FORMATO_HORA', 'REGEX', '{"patron": "^([01]?[0-9]|2[0-3]):[0-5][0-9]$", "operador": "match"}', 'La hora debe tener un formato válido (HH:MM).', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (15, 3, 180, 'LOGICA_FECHA_EVENTO', 'COMPARACION_CAMPOS', '{"campo1": "fechaEvento", "campo2": "fechaAtencion", "operador": "less_than_or_equal"}', 'La fecha del evento no puede ser posterior a la fecha de atención.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (16, 3, 205, 'REQ_TIPO_VIOLENCIA', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "tipoViolencia"}, "operador": "if_then", "condicion": {"in": ["2", "3"], "campo": "intencionalidad"}}', 'Si la lesión fue por violencia, especificar el tipo de violencia es obligatorio.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (17, 3, 206, 'REQ_AGRESORES', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "numeroAgresores"}, "operador": "if_then", "condicion": {"in": ["2", "3"], "campo": "intencionalidad"}}', 'En casos de violencia, se debe especificar el número de agresores.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (18, 3, 207, 'REQ_PARENTESCO', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "parentescoAfectado"}, "operador": "if_then", "condicion": {"campo": "numeroAgresores", "valor": "1"}}', 'Si el agresor es ÚNICO, especificar el parentesco es obligatorio.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (19, 3, 201, 'REQ_VEHICULO_MOTOR', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "lesionadoVehiculoMotor"}, "operador": "if_then", "condicion": {"campo": "agenteLesion", "valor": "20"}}', 'Si el agente de lesión es VEHÍCULO DE MOTOR, debe especificar la condición del lesionado (Conductor/Ocupante/Peatón).', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (20, 3, 231, 'REQ_CERT_DEFUNCION', 'LOGICA_COMPLEJA', '{"accion": {"requerido": "folioCertificadoDefuncion"}, "operador": "if_then", "condicion": {"and": [{"campo": "despuesAtencion", "valor": "5"}, {"campo": "ministerioPublico", "valor": "2"}]}}', 'Si el destino es Defunción y NO se dio aviso al MP, registrar el folio de certificado de defunción es obligatorio.', 'ERROR', '2022-03-15');
INSERT INTO public.sys_giis_restricciones VALUES (21, 4, 264, 'LIMITE_PESO', 'RANGO_VALOR', '{"max": 400, "min": 1, "operador": "between"}', 'El peso debe estar entre 1 y 400 kg.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (22, 4, 267, 'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"campo1": "sistolica", "campo2": "diastolica", "operador": "greater_than_or_equal"}', 'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (23, 4, 284, 'REQ_HILODENTAL_EDAD', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido_valor": "-1"}, "operador": "if_then", "condicion": {"campo": "edadCalculada", "less_than": 6}}', 'La instrucción de hilo dental no aplica (debe ser -1) para menores de 6 años.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (24, 4, NULL, 'ERRATA_ACCIONES_BUCALES_MINIMAS', 'LOGICA_COMPLEJA', '{"campos": ["placaBacteriana", "cepillado", "limpiezaDental", "protesis", "tejidosBucales", "autoExamen", "fluor", "raspadoAlisadoPeriodontal", "barnizFluor"], "operador": "al_menos_uno_diferente_cero", "condicion_hilo_dental": "!= 0 y != -1"}', 'De acuerdo a la Fe de Erratas (18/04/2024), se debe validar que al menos una de las acciones realizadas tenga un valor diferente de 0. Para hiloDental, diferente de 0 y -1.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (25, 4, 264, 'LIMITE_PESO', 'RANGO_VALOR', '{"max": 400, "min": 1, "operador": "between"}', 'El peso debe estar entre 1 y 400 kg.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (26, 4, 267, 'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"campo1": "sistolica", "campo2": "diastolica", "operador": "greater_than_or_equal"}', 'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (27, 4, 284, 'REQ_HILODENTAL_EDAD', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido_valor": "-1"}, "operador": "if_then", "condicion": {"campo": "edadCalculada", "less_than": 6}}', 'La instrucción de hilo dental no aplica (debe ser -1) para menores de 6 años.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (28, 4, NULL, 'ERRATA_ACCIONES_BUCALES_MINIMAS', 'LOGICA_COMPLEJA', '{"campos": ["placaBacteriana", "cepillado", "limpiezaDental", "protesis", "tejidosBucales", "autoExamen", "fluor", "raspadoAlisadoPeriodontal", "barnizFluor"], "operador": "al_menos_uno_diferente_cero", "condicion_hilo_dental": "!= 0 y != -1"}', 'De acuerdo a la Fe de Erratas (18/04/2024), se debe validar que al menos una de las acciones realizadas tenga un valor diferente de 0. Para hiloDental, diferente de 0 y -1.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (29, 6, 418, 'LIMITE_PESO', 'RANGO_VALOR', '{"max": 400, "min": 1, "operador": "between"}', 'El peso debe estar entre 1 y 400 kg.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (30, 6, 421, 'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"campo1": "sistolica", "campo2": "diastolica", "operador": "greater_than_or_equal"}', 'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (31, 6, 432, 'ERRATA_VALIDACION_DIAGNOSTICO_TERAPIA', 'LOGICA_COMPLEJA', '{"accion": {"ignorar_validacion_edad_sexo": true}, "operador": "if_then", "condicion": {"in": ["2", "3", "4"], "campo": "psicoTerapia"}}', 'Fe de erratas: Si la psicoterapia es Grupal, de Pareja o Familiar, se omite la validación de Edad y Sexo del diagnóstico.', 'ADVERTENCIA', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (32, 7, 503, 'LIMITE_PESO', 'RANGO_VALOR', '{"max": 400, "min": 1, "operador": "between"}', 'El peso debe estar entre 1 y 400 kg.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (33, 7, 506, 'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"campo1": "sistolica", "campo2": "diastolica", "operador": "greater_than_or_equal"}', 'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (34, 7, NULL, 'VALIDACION_EDAD_HOMBRES', 'LOGICA_COMPLEJA', '{"accion": {"rango_edad": {"max": 70, "min": 10}}, "operador": "if_then", "condicion": {"in": ["1", "3"], "campo": "sexoBiologico"}}', 'Si el paciente es hombre o intersexual, la edad permitida para atención de planificación familiar es entre 10 y 70 años.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (35, 7, NULL, 'VALIDACION_EDAD_MUJERES', 'LOGICA_COMPLEJA', '{"accion": {"rango_edad": {"max": 59, "min": 10}}, "operador": "if_then", "condicion": {"campo": "sexoBiologico", "valor": "2"}}', 'Si la paciente es mujer, la edad permitida para atención de planificación familiar es entre 10 y 59 años.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (36, 7, 531, 'BLOQUEO_CIRUGIA_HOMBRES', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"max_value": 0}, "operador": "if_then", "condicion": {"campo": "sexoBiologico", "valor": "2"}}', 'Si el sexo biológico es mujer, para el método quirúrgico solo se debe registrar la opción "0 - Revisión posterior a la intervención".', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (37, 8, 575, 'LIMITE_PESO', 'RANGO_VALOR', '{"max": 400, "min": 1, "operador": "between"}', 'El peso debe estar entre 1 y 400 kg.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (38, 8, 578, 'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"campo1": "sistolica", "campo2": "diastolica", "operador": "greater_than_or_equal"}', 'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (39, 8, 635, 'BLOQUEO_PROSTATA_MUJER', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido_valor": "-1"}, "operador": "if_then", "condicion": {"campo": "sexoBiologico", "valor": "2"}}', 'La detección de hiperplasia prostática no aplica en mujeres.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (40, 9, 667, 'LIMITE_PESO', 'RANGO_VALOR', '{"max": 400, "min": 1, "operador": "between"}', 'El peso debe estar entre 1 y 400 kg.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (41, 9, 670, 'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"campo1": "sistolica", "campo2": "diastolica", "operador": "greater_than_or_equal"}', 'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (42, 9, 665, 'LOGICA_FECHAS_CONSULTA', 'COMPARACION_CAMPOS', '{"campo1": "fechaConsulta", "campo2": "fechaNacimiento", "operador": "greater_than_or_equal"}', 'La fecha de consulta no puede ser anterior a la fecha de nacimiento.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (43, 9, 723, 'REQ_PLAN_EDAS', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "edasPlanTratamiento"}, "operador": "if_then", "condicion": {"in": ["0", "1"], "campo": "edasRT"}}', 'Si se reporta Enfermedad Diarreica Aguda (EDAS), es obligatorio especificar el Plan de Tratamiento (A, B o C).', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (44, 9, 727, 'REQ_PLAN_IRAS', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido": "irasPlanTratamiento"}, "operador": "if_then", "condicion": {"in": ["0", "1"], "campo": "irasRT"}}', 'Si se reporta Infección Respiratoria Aguda (IRAS), es obligatorio especificar el Plan de Tratamiento.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (45, 9, 747, 'REQ_MODALIDAD_TELE', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido_valor": "1"}, "operador": "if_then", "condicion": {"campo": "teleconsulta", "valor": "1"}}', 'Si se realizó teleconsulta, la modalidad debe ser EN TIEMPO REAL (1).', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (46, 9, 695, 'BLOQUEO_EMBARAZO_HOMBRES', 'LOGICA_CRUZADA', '{"operador": "not_and", "condiciones": [{"in": ["1", "3"], "campo": "sexoBiologico"}, {"in": ["0", "1"], "campo": "relacionTemporalEmbarazo"}]}', 'Incongruencia: No se puede registrar control de embarazo en pacientes con sexo biológico masculino o intersexual.', 'ERROR', '2024-11-01');
INSERT INTO public.sys_giis_restricciones VALUES (47, 9, 719, 'REQ_EDI_EDAD', 'DEPENDENCIA_CONDICIONAL', '{"accion": {"requerido_valor": "-1"}, "operador": "if_then", "condicion": {"campo": "edadCalculada", "greater_than_or_equal": 6}}', 'La prueba EDI (Evaluación del Desarrollo Infantil) solo aplica para menores de 6 años.', 'ERROR', '2024-11-01');


--
-- TOC entry 4607 (class 0 OID 160073)
-- Dependencies: 218
-- Data for Name: sys_normatividad_giis; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sys_normatividad_giis VALUES (1, 'GIIS-B002-04-05', 'Egresos Hospitalarios', '4.5', '2022-07-15', NULL, 'ACTIVO', '2026-02-27 19:15:27.445578');
INSERT INTO public.sys_normatividad_giis VALUES (2, 'GIIS-B014-02-03', 'Urgencias Médicas', '2.3', '2022-03-15', NULL, 'ACTIVO', '2026-02-27 19:18:05.51617');
INSERT INTO public.sys_normatividad_giis VALUES (3, 'GIIS-B013-02-03', 'Lesiones y Causas de Violencia', '2.3', '2022-03-15', NULL, 'ACTIVO', '2026-02-27 19:20:26.930343');
INSERT INTO public.sys_normatividad_giis VALUES (4, 'GIIS-B016-04-08', 'Consulta Externa de Salud Bucal', '4.8', '2024-11-01', NULL, 'ACTIVO', '2026-02-27 19:24:14.878972');
INSERT INTO public.sys_normatividad_giis VALUES (6, 'GIIS-B017-04-09', 'Consulta Externa de Salud Mental', '4.9', '2024-11-01', NULL, 'ACTIVO', '2026-02-27 20:08:06.152925');
INSERT INTO public.sys_normatividad_giis VALUES (7, 'GIIS-B018-04-09', 'Consulta Externa y Atención de Planificación Familiar', '4.9', '2024-11-01', NULL, 'ACTIVO', '2026-02-27 20:11:48.594609');
INSERT INTO public.sys_normatividad_giis VALUES (8, 'GIIS-B019-04-09', 'Detecciones', '4.9', '2024-11-01', NULL, 'ACTIVO', '2026-02-27 20:14:16.685308');
INSERT INTO public.sys_normatividad_giis VALUES (9, 'GIIS-B015-04-11', 'Consulta Externa', '4.11', '2024-11-01', NULL, 'ACTIVO', '2026-02-27 20:20:03.324726');


--
-- TOC entry 4609 (class 0 OID 160086)
-- Dependencies: 220
-- Data for Name: sys_registro_catalogos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4675 (class 0 OID 0)
-- Dependencies: 238
-- Name: adm_unidades_medicas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adm_unidades_medicas_id_seq', 1, false);


--
-- TOC entry 4676 (class 0 OID 0)
-- Dependencies: 232
-- Name: cat_asentamientos_cp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_asentamientos_cp_id_seq', 1, false);


--
-- TOC entry 4677 (class 0 OID 0)
-- Dependencies: 234
-- Name: cat_cie10_diagnosticos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_cie10_diagnosticos_id_seq', 1, false);


--
-- TOC entry 4678 (class 0 OID 0)
-- Dependencies: 236
-- Name: cat_cie9_procedimientos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_cie9_procedimientos_id_seq', 1, false);


--
-- TOC entry 4679 (class 0 OID 0)
-- Dependencies: 257
-- Name: cat_doc_clasificacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_doc_clasificacion_id_seq', 6, true);


--
-- TOC entry 4680 (class 0 OID 0)
-- Dependencies: 228
-- Name: cat_entidades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_entidades_id_seq', 1, false);


--
-- TOC entry 4681 (class 0 OID 0)
-- Dependencies: 230
-- Name: cat_municipios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_municipios_id_seq', 1, false);


--
-- TOC entry 4682 (class 0 OID 0)
-- Dependencies: 255
-- Name: cat_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_roles_id_seq', 5, true);


--
-- TOC entry 4683 (class 0 OID 0)
-- Dependencies: 242
-- Name: cat_servicios_atencion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_servicios_atencion_id_seq', 1, false);


--
-- TOC entry 4684 (class 0 OID 0)
-- Dependencies: 240
-- Name: cat_tipos_personal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cat_tipos_personal_id_seq', 1, false);


--
-- TOC entry 4685 (class 0 OID 0)
-- Dependencies: 225
-- Name: gui_diccionario_opciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gui_diccionario_opciones_id_seq', 435, true);


--
-- TOC entry 4686 (class 0 OID 0)
-- Dependencies: 223
-- Name: gui_diccionarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gui_diccionarios_id_seq', 94, true);


--
-- TOC entry 4687 (class 0 OID 0)
-- Dependencies: 221
-- Name: sys_adopcion_catalogos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_adopcion_catalogos_id_seq', 1, false);


--
-- TOC entry 4688 (class 0 OID 0)
-- Dependencies: 251
-- Name: sys_giis_campos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_giis_campos_id_seq', 747, true);


--
-- TOC entry 4689 (class 0 OID 0)
-- Dependencies: 253
-- Name: sys_giis_restricciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_giis_restricciones_id_seq', 47, true);


--
-- TOC entry 4690 (class 0 OID 0)
-- Dependencies: 217
-- Name: sys_normatividad_giis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_normatividad_giis_id_seq', 9, true);


--
-- TOC entry 4691 (class 0 OID 0)
-- Dependencies: 219
-- Name: sys_registro_catalogos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sys_registro_catalogos_id_seq', 1, false);


--
-- TOC entry 4383 (class 2606 OID 160296)
-- Name: adm_personal_salud adm_personal_salud_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_personal_salud
    ADD CONSTRAINT adm_personal_salud_pkey PRIMARY KEY (id);


--
-- TOC entry 4363 (class 2606 OID 160240)
-- Name: adm_unidades_medicas adm_unidades_medicas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_unidades_medicas
    ADD CONSTRAINT adm_unidades_medicas_pkey PRIMARY KEY (id);


--
-- TOC entry 4377 (class 2606 OID 160288)
-- Name: adm_usuarios adm_usuarios_curp_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_usuarios
    ADD CONSTRAINT adm_usuarios_curp_key UNIQUE (curp);


--
-- TOC entry 4379 (class 2606 OID 160290)
-- Name: adm_usuarios adm_usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_usuarios
    ADD CONSTRAINT adm_usuarios_email_key UNIQUE (email);


--
-- TOC entry 4381 (class 2606 OID 160286)
-- Name: adm_usuarios adm_usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_usuarios
    ADD CONSTRAINT adm_usuarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4354 (class 2606 OID 160194)
-- Name: cat_asentamientos_cp cat_asentamientos_cp_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_asentamientos_cp
    ADD CONSTRAINT cat_asentamientos_cp_pkey PRIMARY KEY (id);


--
-- TOC entry 4357 (class 2606 OID 160213)
-- Name: cat_cie10_diagnosticos cat_cie10_diagnosticos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie10_diagnosticos
    ADD CONSTRAINT cat_cie10_diagnosticos_pkey PRIMARY KEY (id);


--
-- TOC entry 4360 (class 2606 OID 160225)
-- Name: cat_cie9_procedimientos cat_cie9_procedimientos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_cie9_procedimientos
    ADD CONSTRAINT cat_cie9_procedimientos_pkey PRIMARY KEY (id);


--
-- TOC entry 4413 (class 2606 OID 160504)
-- Name: cat_doc_clasificacion cat_doc_clasificacion_clave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_doc_clasificacion
    ADD CONSTRAINT cat_doc_clasificacion_clave_key UNIQUE (clave);


--
-- TOC entry 4415 (class 2606 OID 160502)
-- Name: cat_doc_clasificacion cat_doc_clasificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_doc_clasificacion
    ADD CONSTRAINT cat_doc_clasificacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4346 (class 2606 OID 160173)
-- Name: cat_entidades cat_entidades_clave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_entidades
    ADD CONSTRAINT cat_entidades_clave_key UNIQUE (clave);


--
-- TOC entry 4348 (class 2606 OID 160171)
-- Name: cat_entidades cat_entidades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_entidades
    ADD CONSTRAINT cat_entidades_pkey PRIMARY KEY (id);


--
-- TOC entry 4375 (class 2606 OID 160269)
-- Name: cat_matriz_personal_servicio cat_matriz_personal_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_matriz_personal_servicio
    ADD CONSTRAINT cat_matriz_personal_servicio_pkey PRIMARY KEY (tipo_personal_id, servicio_atencion_id);


--
-- TOC entry 4350 (class 2606 OID 160182)
-- Name: cat_municipios cat_municipios_entidad_id_clave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_municipios
    ADD CONSTRAINT cat_municipios_entidad_id_clave_key UNIQUE (entidad_id, clave);


--
-- TOC entry 4352 (class 2606 OID 160180)
-- Name: cat_municipios cat_municipios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_municipios
    ADD CONSTRAINT cat_municipios_pkey PRIMARY KEY (id);


--
-- TOC entry 4409 (class 2606 OID 160476)
-- Name: cat_roles cat_roles_clave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_roles
    ADD CONSTRAINT cat_roles_clave_key UNIQUE (clave);


--
-- TOC entry 4411 (class 2606 OID 160474)
-- Name: cat_roles cat_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_roles
    ADD CONSTRAINT cat_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4371 (class 2606 OID 160264)
-- Name: cat_servicios_atencion cat_servicios_atencion_clave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_servicios_atencion
    ADD CONSTRAINT cat_servicios_atencion_clave_key UNIQUE (clave);


--
-- TOC entry 4373 (class 2606 OID 160262)
-- Name: cat_servicios_atencion cat_servicios_atencion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_servicios_atencion
    ADD CONSTRAINT cat_servicios_atencion_pkey PRIMARY KEY (id);


--
-- TOC entry 4367 (class 2606 OID 160255)
-- Name: cat_tipos_personal cat_tipos_personal_clave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_tipos_personal
    ADD CONSTRAINT cat_tipos_personal_clave_key UNIQUE (clave);


--
-- TOC entry 4369 (class 2606 OID 160253)
-- Name: cat_tipos_personal cat_tipos_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_tipos_personal
    ADD CONSTRAINT cat_tipos_personal_pkey PRIMARY KEY (id);


--
-- TOC entry 4397 (class 2606 OID 160368)
-- Name: clin_atenciones clin_atenciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_pkey PRIMARY KEY (id, fecha_atencion);


--
-- TOC entry 4399 (class 2606 OID 160387)
-- Name: clin_atenciones_2026 clin_atenciones_2026_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_atenciones_2026
    ADD CONSTRAINT clin_atenciones_2026_pkey PRIMARY KEY (id, fecha_atencion);


--
-- TOC entry 4394 (class 2606 OID 160346)
-- Name: clin_citas clin_citas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_citas
    ADD CONSTRAINT clin_citas_pkey PRIMARY KEY (id);


--
-- TOC entry 4385 (class 2606 OID 160325)
-- Name: clin_pacientes clin_pacientes_curp_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_curp_key UNIQUE (curp);


--
-- TOC entry 4387 (class 2606 OID 160323)
-- Name: clin_pacientes clin_pacientes_numero_expediente_global_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_numero_expediente_global_key UNIQUE (numero_expediente_global);


--
-- TOC entry 4389 (class 2606 OID 160321)
-- Name: clin_pacientes clin_pacientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_pkey PRIMARY KEY (id);


--
-- TOC entry 4417 (class 2606 OID 160514)
-- Name: doc_expediente_digital doc_expediente_digital_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doc_expediente_digital
    ADD CONSTRAINT doc_expediente_digital_pkey PRIMARY KEY (id);


--
-- TOC entry 4340 (class 2606 OID 160139)
-- Name: gui_diccionario_opciones gui_diccionario_opciones_diccionario_id_clave_valor_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gui_diccionario_opciones
    ADD CONSTRAINT gui_diccionario_opciones_diccionario_id_clave_valor_key UNIQUE (diccionario_id, clave, valor);


--
-- TOC entry 4342 (class 2606 OID 160137)
-- Name: gui_diccionario_opciones gui_diccionario_opciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gui_diccionario_opciones
    ADD CONSTRAINT gui_diccionario_opciones_pkey PRIMARY KEY (id);


--
-- TOC entry 4336 (class 2606 OID 160127)
-- Name: gui_diccionarios gui_diccionarios_codigo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gui_diccionarios
    ADD CONSTRAINT gui_diccionarios_codigo_key UNIQUE (codigo);


--
-- TOC entry 4338 (class 2606 OID 160125)
-- Name: gui_diccionarios gui_diccionarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gui_diccionarios
    ADD CONSTRAINT gui_diccionarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4344 (class 2606 OID 160154)
-- Name: rel_normatividad_opciones rel_normatividad_opciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_normatividad_opciones
    ADD CONSTRAINT rel_normatividad_opciones_pkey PRIMARY KEY (normatividad_id, opcion_id);


--
-- TOC entry 4334 (class 2606 OID 160106)
-- Name: sys_adopcion_catalogos sys_adopcion_catalogos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_adopcion_catalogos
    ADD CONSTRAINT sys_adopcion_catalogos_pkey PRIMARY KEY (id);


--
-- TOC entry 4424 (class 2606 OID 160545)
-- Name: sys_bitacora_auditoria sys_bitacora_auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_bitacora_auditoria
    ADD CONSTRAINT sys_bitacora_auditoria_pkey PRIMARY KEY (id);


--
-- TOC entry 4402 (class 2606 OID 160428)
-- Name: sys_giis_campos sys_giis_campos_normatividad_id_nombre_campo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_giis_campos
    ADD CONSTRAINT sys_giis_campos_normatividad_id_nombre_campo_key UNIQUE (normatividad_id, nombre_campo);


--
-- TOC entry 4404 (class 2606 OID 160426)
-- Name: sys_giis_campos sys_giis_campos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_giis_campos
    ADD CONSTRAINT sys_giis_campos_pkey PRIMARY KEY (id);


--
-- TOC entry 4407 (class 2606 OID 160443)
-- Name: sys_giis_restricciones sys_giis_restricciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_giis_restricciones
    ADD CONSTRAINT sys_giis_restricciones_pkey PRIMARY KEY (id);


--
-- TOC entry 4328 (class 2606 OID 160084)
-- Name: sys_normatividad_giis sys_normatividad_giis_clave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_normatividad_giis
    ADD CONSTRAINT sys_normatividad_giis_clave_key UNIQUE (clave);


--
-- TOC entry 4330 (class 2606 OID 160082)
-- Name: sys_normatividad_giis sys_normatividad_giis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_normatividad_giis
    ADD CONSTRAINT sys_normatividad_giis_pkey PRIMARY KEY (id);


--
-- TOC entry 4332 (class 2606 OID 160096)
-- Name: sys_registro_catalogos sys_registro_catalogos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_registro_catalogos
    ADD CONSTRAINT sys_registro_catalogos_pkey PRIMARY KEY (id);


--
-- TOC entry 4420 (class 1259 OID 160553)
-- Name: idx_auditoria_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auditoria_fecha ON public.sys_bitacora_auditoria USING btree (fecha_accion);


--
-- TOC entry 4421 (class 1259 OID 160551)
-- Name: idx_auditoria_tabla_registro; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auditoria_tabla_registro ON public.sys_bitacora_auditoria USING btree (tabla_afectada, registro_id);


--
-- TOC entry 4422 (class 1259 OID 160552)
-- Name: idx_auditoria_usuario; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auditoria_usuario ON public.sys_bitacora_auditoria USING btree (usuario_id);


--
-- TOC entry 4358 (class 1259 OID 160214)
-- Name: idx_cie10_activo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cie10_activo ON public.cat_cie10_diagnosticos USING btree (catalog_key) WHERE (activo = true);


--
-- TOC entry 4361 (class 1259 OID 160226)
-- Name: idx_cie9_activo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cie9_activo ON public.cat_cie9_procedimientos USING btree (catalog_key) WHERE (activo = true);


--
-- TOC entry 4395 (class 1259 OID 160490)
-- Name: idx_citas_paciente; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_citas_paciente ON public.clin_citas USING btree (paciente_id, fecha_hora_cita);


--
-- TOC entry 4364 (class 1259 OID 160246)
-- Name: idx_clues_activo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_clues_activo ON public.adm_unidades_medicas USING btree (clues) WHERE (activo = true);


--
-- TOC entry 4355 (class 1259 OID 160200)
-- Name: idx_cp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cp ON public.cat_asentamientos_cp USING btree (codigo_postal);


--
-- TOC entry 4418 (class 1259 OID 160536)
-- Name: idx_doc_clasificacion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_doc_clasificacion ON public.doc_expediente_digital USING btree (clasificacion_id);


--
-- TOC entry 4419 (class 1259 OID 160535)
-- Name: idx_doc_paciente; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_doc_paciente ON public.doc_expediente_digital USING btree (paciente_id);


--
-- TOC entry 4400 (class 1259 OID 160488)
-- Name: idx_giis_campos_orden; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_giis_campos_orden ON public.sys_giis_campos USING btree (normatividad_id, orden);


--
-- TOC entry 4405 (class 1259 OID 160489)
-- Name: idx_giis_restricciones_campo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_giis_restricciones_campo ON public.sys_giis_restricciones USING btree (campo_id);


--
-- TOC entry 4390 (class 1259 OID 160485)
-- Name: idx_paciente_apellidos; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_paciente_apellidos ON public.clin_pacientes USING btree (primer_apellido, segundo_apellido);


--
-- TOC entry 4391 (class 1259 OID 160487)
-- Name: idx_paciente_fecha_nac; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_paciente_fecha_nac ON public.clin_pacientes USING btree (fecha_nacimiento);


--
-- TOC entry 4392 (class 1259 OID 160486)
-- Name: idx_paciente_nombre; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_paciente_nombre ON public.clin_pacientes USING btree (nombre);


--
-- TOC entry 4365 (class 1259 OID 160484)
-- Name: idx_unidades_medicas_geom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_unidades_medicas_geom ON public.adm_unidades_medicas USING gist (geom);


--
-- TOC entry 4425 (class 0 OID 0)
-- Name: clin_atenciones_2026_pkey; Type: INDEX ATTACH; Schema: public; Owner: postgres
--

ALTER INDEX public.clin_atenciones_pkey ATTACH PARTITION public.clin_atenciones_2026_pkey;


--
-- TOC entry 4461 (class 2620 OID 160555)
-- Name: sys_bitacora_auditoria trg_prevent_audit_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_prevent_audit_update BEFORE DELETE OR UPDATE ON public.sys_bitacora_auditoria FOR EACH ROW EXECUTE FUNCTION public.prevent_audit_tampering();


--
-- TOC entry 4460 (class 2620 OID 160404)
-- Name: clin_citas trigger_upd_citas; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_upd_citas BEFORE UPDATE ON public.clin_citas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4459 (class 2620 OID 160403)
-- Name: clin_pacientes trigger_upd_pacientes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_upd_pacientes BEFORE UPDATE ON public.clin_pacientes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4458 (class 2620 OID 160402)
-- Name: adm_unidades_medicas trigger_upd_unidades; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_upd_unidades BEFORE UPDATE ON public.adm_unidades_medicas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4438 (class 2606 OID 160307)
-- Name: adm_personal_salud adm_personal_salud_tipo_personal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_personal_salud
    ADD CONSTRAINT adm_personal_salud_tipo_personal_id_fkey FOREIGN KEY (tipo_personal_id) REFERENCES public.cat_tipos_personal(id);


--
-- TOC entry 4439 (class 2606 OID 160302)
-- Name: adm_personal_salud adm_personal_salud_unidad_medica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_personal_salud
    ADD CONSTRAINT adm_personal_salud_unidad_medica_id_fkey FOREIGN KEY (unidad_medica_id) REFERENCES public.adm_unidades_medicas(id);


--
-- TOC entry 4440 (class 2606 OID 160297)
-- Name: adm_personal_salud adm_personal_salud_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_personal_salud
    ADD CONSTRAINT adm_personal_salud_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.adm_usuarios(id);


--
-- TOC entry 4434 (class 2606 OID 160241)
-- Name: adm_unidades_medicas adm_unidades_medicas_asentamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_unidades_medicas
    ADD CONSTRAINT adm_unidades_medicas_asentamiento_id_fkey FOREIGN KEY (asentamiento_id) REFERENCES public.cat_asentamientos_cp(id);


--
-- TOC entry 4437 (class 2606 OID 160477)
-- Name: adm_usuarios adm_usuarios_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adm_usuarios
    ADD CONSTRAINT adm_usuarios_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.cat_roles(id);


--
-- TOC entry 4433 (class 2606 OID 160195)
-- Name: cat_asentamientos_cp cat_asentamientos_cp_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_asentamientos_cp
    ADD CONSTRAINT cat_asentamientos_cp_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.cat_municipios(id) ON DELETE CASCADE;


--
-- TOC entry 4435 (class 2606 OID 160275)
-- Name: cat_matriz_personal_servicio cat_matriz_personal_servicio_servicio_atencion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_matriz_personal_servicio
    ADD CONSTRAINT cat_matriz_personal_servicio_servicio_atencion_id_fkey FOREIGN KEY (servicio_atencion_id) REFERENCES public.cat_servicios_atencion(id) ON DELETE CASCADE;


--
-- TOC entry 4436 (class 2606 OID 160270)
-- Name: cat_matriz_personal_servicio cat_matriz_personal_servicio_tipo_personal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_matriz_personal_servicio
    ADD CONSTRAINT cat_matriz_personal_servicio_tipo_personal_id_fkey FOREIGN KEY (tipo_personal_id) REFERENCES public.cat_tipos_personal(id) ON DELETE CASCADE;


--
-- TOC entry 4432 (class 2606 OID 160183)
-- Name: cat_municipios cat_municipios_entidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cat_municipios
    ADD CONSTRAINT cat_municipios_entidad_id_fkey FOREIGN KEY (entidad_id) REFERENCES public.cat_entidades(id) ON DELETE CASCADE;


--
-- TOC entry 4446 (class 2606 OID 160372)
-- Name: clin_atenciones clin_atenciones_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.clin_citas(id);


--
-- TOC entry 4447 (class 2606 OID 160369)
-- Name: clin_atenciones clin_atenciones_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.clin_pacientes(id);


--
-- TOC entry 4448 (class 2606 OID 160378)
-- Name: clin_atenciones clin_atenciones_personal_salud_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_personal_salud_id_fkey FOREIGN KEY (personal_salud_id) REFERENCES public.adm_personal_salud(id);


--
-- TOC entry 4449 (class 2606 OID 160375)
-- Name: clin_atenciones clin_atenciones_unidad_medica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_unidad_medica_id_fkey FOREIGN KEY (unidad_medica_id) REFERENCES public.adm_unidades_medicas(id);


--
-- TOC entry 4443 (class 2606 OID 160347)
-- Name: clin_citas clin_citas_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_citas
    ADD CONSTRAINT clin_citas_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.clin_pacientes(id) ON DELETE CASCADE;


--
-- TOC entry 4444 (class 2606 OID 160357)
-- Name: clin_citas clin_citas_personal_salud_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_citas
    ADD CONSTRAINT clin_citas_personal_salud_id_fkey FOREIGN KEY (personal_salud_id) REFERENCES public.adm_personal_salud(id);


--
-- TOC entry 4445 (class 2606 OID 160352)
-- Name: clin_citas clin_citas_unidad_medica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_citas
    ADD CONSTRAINT clin_citas_unidad_medica_id_fkey FOREIGN KEY (unidad_medica_id) REFERENCES public.adm_unidades_medicas(id);


--
-- TOC entry 4441 (class 2606 OID 160331)
-- Name: clin_pacientes clin_pacientes_asentamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_asentamiento_id_fkey FOREIGN KEY (asentamiento_id) REFERENCES public.cat_asentamientos_cp(id);


--
-- TOC entry 4442 (class 2606 OID 160326)
-- Name: clin_pacientes clin_pacientes_sexo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_sexo_id_fkey FOREIGN KEY (sexo_id) REFERENCES public.gui_diccionario_opciones(id);


--
-- TOC entry 4453 (class 2606 OID 160520)
-- Name: doc_expediente_digital doc_expediente_digital_atencion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doc_expediente_digital
    ADD CONSTRAINT doc_expediente_digital_atencion_id_fkey FOREIGN KEY (atencion_id) REFERENCES public.clin_citas(id) ON DELETE SET NULL;


--
-- TOC entry 4454 (class 2606 OID 160525)
-- Name: doc_expediente_digital doc_expediente_digital_clasificacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doc_expediente_digital
    ADD CONSTRAINT doc_expediente_digital_clasificacion_id_fkey FOREIGN KEY (clasificacion_id) REFERENCES public.cat_doc_clasificacion(id);


--
-- TOC entry 4455 (class 2606 OID 160515)
-- Name: doc_expediente_digital doc_expediente_digital_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doc_expediente_digital
    ADD CONSTRAINT doc_expediente_digital_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.clin_pacientes(id) ON DELETE CASCADE;


--
-- TOC entry 4456 (class 2606 OID 160530)
-- Name: doc_expediente_digital doc_expediente_digital_subido_por_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doc_expediente_digital
    ADD CONSTRAINT doc_expediente_digital_subido_por_usuario_id_fkey FOREIGN KEY (subido_por_usuario_id) REFERENCES public.adm_usuarios(id);


--
-- TOC entry 4428 (class 2606 OID 160140)
-- Name: gui_diccionario_opciones gui_diccionario_opciones_diccionario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gui_diccionario_opciones
    ADD CONSTRAINT gui_diccionario_opciones_diccionario_id_fkey FOREIGN KEY (diccionario_id) REFERENCES public.gui_diccionarios(id) ON DELETE CASCADE;


--
-- TOC entry 4429 (class 2606 OID 160145)
-- Name: gui_diccionario_opciones gui_diccionario_opciones_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gui_diccionario_opciones
    ADD CONSTRAINT gui_diccionario_opciones_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.gui_diccionario_opciones(id);


--
-- TOC entry 4430 (class 2606 OID 160155)
-- Name: rel_normatividad_opciones rel_normatividad_opciones_normatividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_normatividad_opciones
    ADD CONSTRAINT rel_normatividad_opciones_normatividad_id_fkey FOREIGN KEY (normatividad_id) REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE;


--
-- TOC entry 4431 (class 2606 OID 160160)
-- Name: rel_normatividad_opciones rel_normatividad_opciones_opcion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rel_normatividad_opciones
    ADD CONSTRAINT rel_normatividad_opciones_opcion_id_fkey FOREIGN KEY (opcion_id) REFERENCES public.gui_diccionario_opciones(id) ON DELETE CASCADE;


--
-- TOC entry 4426 (class 2606 OID 160107)
-- Name: sys_adopcion_catalogos sys_adopcion_catalogos_normatividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_adopcion_catalogos
    ADD CONSTRAINT sys_adopcion_catalogos_normatividad_id_fkey FOREIGN KEY (normatividad_id) REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE;


--
-- TOC entry 4427 (class 2606 OID 160112)
-- Name: sys_adopcion_catalogos sys_adopcion_catalogos_registro_importacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_adopcion_catalogos
    ADD CONSTRAINT sys_adopcion_catalogos_registro_importacion_id_fkey FOREIGN KEY (registro_importacion_id) REFERENCES public.sys_registro_catalogos(id) ON DELETE CASCADE;


--
-- TOC entry 4457 (class 2606 OID 160546)
-- Name: sys_bitacora_auditoria sys_bitacora_auditoria_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_bitacora_auditoria
    ADD CONSTRAINT sys_bitacora_auditoria_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.adm_usuarios(id) ON DELETE SET NULL;


--
-- TOC entry 4450 (class 2606 OID 160429)
-- Name: sys_giis_campos sys_giis_campos_normatividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_giis_campos
    ADD CONSTRAINT sys_giis_campos_normatividad_id_fkey FOREIGN KEY (normatividad_id) REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE;


--
-- TOC entry 4451 (class 2606 OID 160449)
-- Name: sys_giis_restricciones sys_giis_restricciones_campo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_giis_restricciones
    ADD CONSTRAINT sys_giis_restricciones_campo_id_fkey FOREIGN KEY (campo_id) REFERENCES public.sys_giis_campos(id) ON DELETE CASCADE;


--
-- TOC entry 4452 (class 2606 OID 160444)
-- Name: sys_giis_restricciones sys_giis_restricciones_normatividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sys_giis_restricciones
    ADD CONSTRAINT sys_giis_restricciones_normatividad_id_fkey FOREIGN KEY (normatividad_id) REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE;


--
-- TOC entry 4654 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2026-02-27 20:50:16

--
-- PostgreSQL database dump complete
--

