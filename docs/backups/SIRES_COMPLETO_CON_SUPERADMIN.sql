--
-- PostgreSQL database dump
--

\restrict QdfLL5EY2dFaQOp9O0A5pu8avPiPOCdfIyaqRKunTIU0q5ypPYRvsZiZcCfQGae

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: fn_set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adm_personal_salud; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adm_personal_salud (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    usuario_id uuid NOT NULL,
    tipo_personal_id integer NOT NULL,
    cedula_profesional character varying(20),
    nombre_completo character varying(255) NOT NULL
);


--
-- Name: adm_unidades_medicas; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: adm_unidades_medicas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.adm_unidades_medicas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: adm_unidades_medicas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.adm_unidades_medicas_id_seq OWNED BY public.adm_unidades_medicas.id;


--
-- Name: adm_usuario_unidad_rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adm_usuario_unidad_rol (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    usuario_id uuid NOT NULL,
    unidad_medica_id integer NOT NULL,
    rol_id integer NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin date,
    motivo_cambio text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: TABLE adm_usuario_unidad_rol; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.adm_usuario_unidad_rol IS 'Tabla puente N:M entre usuarios y unidades médicas con rol por asignación. Las filas inactivas (activo=FALSE) conservan el historial completo de asignaciones.';


--
-- Name: COLUMN adm_usuario_unidad_rol.activo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.adm_usuario_unidad_rol.activo IS 'TRUE = asignación vigente. FALSE = asignación cerrada (historial).';


--
-- Name: COLUMN adm_usuario_unidad_rol.fecha_fin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.adm_usuario_unidad_rol.fecha_fin IS 'Fecha en que se cerró la asignación. NULL si sigue vigente.';


--
-- Name: COLUMN adm_usuario_unidad_rol.motivo_cambio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.adm_usuario_unidad_rol.motivo_cambio IS 'Motivo de alta, baja o cambio de rol — requerido para trazabilidad NOM-024.';


--
-- Name: adm_usuarios; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: cat_asentamientos_cp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cat_asentamientos_cp (
    id integer NOT NULL,
    municipio_id integer,
    codigo_postal character varying(5) NOT NULL,
    nombre_colonia character varying(255) NOT NULL,
    tipo_asentamiento character varying(100),
    zona character varying(50)
);


--
-- Name: cat_asentamientos_cp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cat_asentamientos_cp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cat_asentamientos_cp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cat_asentamientos_cp_id_seq OWNED BY public.cat_asentamientos_cp.id;


--
-- Name: cat_cie10_diagnosticos; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: cat_cie10_diagnosticos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cat_cie10_diagnosticos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cat_cie10_diagnosticos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cat_cie10_diagnosticos_id_seq OWNED BY public.cat_cie10_diagnosticos.id;


--
-- Name: cat_cie9_procedimientos; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: cat_cie9_procedimientos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cat_cie9_procedimientos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cat_cie9_procedimientos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cat_cie9_procedimientos_id_seq OWNED BY public.cat_cie9_procedimientos.id;


--
-- Name: cat_entidades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cat_entidades (
    id integer NOT NULL,
    clave character varying(5) NOT NULL,
    nombre character varying(100) NOT NULL,
    abreviatura character varying(10)
);


--
-- Name: cat_entidades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cat_entidades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cat_entidades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cat_entidades_id_seq OWNED BY public.cat_entidades.id;


--
-- Name: cat_matriz_personal_servicio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cat_matriz_personal_servicio (
    tipo_personal_id integer NOT NULL,
    servicio_atencion_id integer NOT NULL
);


--
-- Name: cat_municipios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cat_municipios (
    id integer NOT NULL,
    entidad_id integer,
    clave character varying(10) NOT NULL,
    nombre character varying(150) NOT NULL
);


--
-- Name: cat_municipios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cat_municipios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cat_municipios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cat_municipios_id_seq OWNED BY public.cat_municipios.id;


--
-- Name: cat_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cat_roles (
    id integer NOT NULL,
    clave character varying(20) NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    activo boolean DEFAULT true
);


--
-- Name: cat_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cat_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cat_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cat_roles_id_seq OWNED BY public.cat_roles.id;


--
-- Name: cat_servicios_atencion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cat_servicios_atencion (
    id integer NOT NULL,
    clave character varying(10) NOT NULL,
    descripcion character varying(150) NOT NULL
);


--
-- Name: cat_servicios_atencion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cat_servicios_atencion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cat_servicios_atencion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cat_servicios_atencion_id_seq OWNED BY public.cat_servicios_atencion.id;


--
-- Name: cat_tipos_personal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cat_tipos_personal (
    id integer NOT NULL,
    clave character varying(10) NOT NULL,
    descripcion character varying(150) NOT NULL
);


--
-- Name: cat_tipos_personal_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cat_tipos_personal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cat_tipos_personal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cat_tipos_personal_id_seq OWNED BY public.cat_tipos_personal.id;


--
-- Name: clin_atenciones; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: clin_atenciones_2026; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: clin_citas; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: clin_pacientes; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: gui_diccionario_opciones; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: gui_diccionario_opciones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gui_diccionario_opciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gui_diccionario_opciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gui_diccionario_opciones_id_seq OWNED BY public.gui_diccionario_opciones.id;


--
-- Name: gui_diccionarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gui_diccionarios (
    id integer NOT NULL,
    codigo character varying(100) NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion text,
    es_sistema boolean DEFAULT false
);


--
-- Name: gui_diccionarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gui_diccionarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gui_diccionarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gui_diccionarios_id_seq OWNED BY public.gui_diccionarios.id;


--
-- Name: rel_normatividad_opciones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rel_normatividad_opciones (
    normatividad_id integer NOT NULL,
    opcion_id integer NOT NULL
);


--
-- Name: sys_adopcion_catalogos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_adopcion_catalogos (
    id integer NOT NULL,
    normatividad_id integer,
    catalogo_nombre character varying(100),
    registro_importacion_id integer,
    fecha_adopcion date DEFAULT CURRENT_DATE,
    comentarios text
);


--
-- Name: sys_adopcion_catalogos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_adopcion_catalogos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_adopcion_catalogos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_adopcion_catalogos_id_seq OWNED BY public.sys_adopcion_catalogos.id;


--
-- Name: sys_giis_campos; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sys_giis_campos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_giis_campos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_giis_campos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_giis_campos_id_seq OWNED BY public.sys_giis_campos.id;


--
-- Name: sys_giis_restricciones; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sys_giis_restricciones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_giis_restricciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_giis_restricciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_giis_restricciones_id_seq OWNED BY public.sys_giis_restricciones.id;


--
-- Name: sys_normatividad_giis; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sys_normatividad_giis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_normatividad_giis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_normatividad_giis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_normatividad_giis_id_seq OWNED BY public.sys_normatividad_giis.id;


--
-- Name: sys_registro_catalogos; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: sys_registro_catalogos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_registro_catalogos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_registro_catalogos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_registro_catalogos_id_seq OWNED BY public.sys_registro_catalogos.id;


--
-- Name: clin_atenciones_2026; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_atenciones ATTACH PARTITION public.clin_atenciones_2026 FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');


--
-- Name: adm_unidades_medicas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_unidades_medicas ALTER COLUMN id SET DEFAULT nextval('public.adm_unidades_medicas_id_seq'::regclass);


--
-- Name: cat_asentamientos_cp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_asentamientos_cp ALTER COLUMN id SET DEFAULT nextval('public.cat_asentamientos_cp_id_seq'::regclass);


--
-- Name: cat_cie10_diagnosticos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_cie10_diagnosticos ALTER COLUMN id SET DEFAULT nextval('public.cat_cie10_diagnosticos_id_seq'::regclass);


--
-- Name: cat_cie9_procedimientos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_cie9_procedimientos ALTER COLUMN id SET DEFAULT nextval('public.cat_cie9_procedimientos_id_seq'::regclass);


--
-- Name: cat_entidades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_entidades ALTER COLUMN id SET DEFAULT nextval('public.cat_entidades_id_seq'::regclass);


--
-- Name: cat_municipios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_municipios ALTER COLUMN id SET DEFAULT nextval('public.cat_municipios_id_seq'::regclass);


--
-- Name: cat_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_roles ALTER COLUMN id SET DEFAULT nextval('public.cat_roles_id_seq'::regclass);


--
-- Name: cat_servicios_atencion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_servicios_atencion ALTER COLUMN id SET DEFAULT nextval('public.cat_servicios_atencion_id_seq'::regclass);


--
-- Name: cat_tipos_personal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_tipos_personal ALTER COLUMN id SET DEFAULT nextval('public.cat_tipos_personal_id_seq'::regclass);


--
-- Name: gui_diccionario_opciones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gui_diccionario_opciones ALTER COLUMN id SET DEFAULT nextval('public.gui_diccionario_opciones_id_seq'::regclass);


--
-- Name: gui_diccionarios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gui_diccionarios ALTER COLUMN id SET DEFAULT nextval('public.gui_diccionarios_id_seq'::regclass);


--
-- Name: sys_adopcion_catalogos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_adopcion_catalogos ALTER COLUMN id SET DEFAULT nextval('public.sys_adopcion_catalogos_id_seq'::regclass);


--
-- Name: sys_giis_campos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_giis_campos ALTER COLUMN id SET DEFAULT nextval('public.sys_giis_campos_id_seq'::regclass);


--
-- Name: sys_giis_restricciones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_giis_restricciones ALTER COLUMN id SET DEFAULT nextval('public.sys_giis_restricciones_id_seq'::regclass);


--
-- Name: sys_normatividad_giis id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_normatividad_giis ALTER COLUMN id SET DEFAULT nextval('public.sys_normatividad_giis_id_seq'::regclass);


--
-- Name: sys_registro_catalogos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_registro_catalogos ALTER COLUMN id SET DEFAULT nextval('public.sys_registro_catalogos_id_seq'::regclass);


--
-- Data for Name: adm_personal_salud; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.adm_personal_salud (id, usuario_id, tipo_personal_id, cedula_profesional, nombre_completo) FROM stdin;
\.


--
-- Data for Name: adm_unidades_medicas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.adm_unidades_medicas (id, clues, nombre, asentamiento_id, tipo_unidad, estatus_operacion, tiene_espirometro, es_servicio_amigable, activo, geom, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: adm_usuario_unidad_rol; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.adm_usuario_unidad_rol (id, usuario_id, unidad_medica_id, rol_id, activo, fecha_inicio, fecha_fin, motivo_cambio, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: adm_usuarios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.adm_usuarios (id, curp, email, password_hash, activo, rol_id, ultimo_acceso, intentos_fallidos, bloqueado_hasta) FROM stdin;
cf0c104f-b9f3-4f67-a1f2-8fdfcbf262cf	SIRA800101HDFXXX01	admin@eceglobal.mx	$2b$12$4PyKCnklxsIYM86hQEze3u02x.PHe7CCFY/TGDy43ct5NyOCCffye	t	1	2026-02-28 20:02:42.629078	0	\N
\.


--
-- Data for Name: cat_asentamientos_cp; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_asentamientos_cp (id, municipio_id, codigo_postal, nombre_colonia, tipo_asentamiento, zona) FROM stdin;
\.


--
-- Data for Name: cat_cie10_diagnosticos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_cie10_diagnosticos (id, catalog_key, nombre, lsex, linf, lsup, es_suive_morb, metadatos, activo, created_at) FROM stdin;
\.


--
-- Data for Name: cat_cie9_procedimientos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_cie9_procedimientos (id, catalog_key, nombre, sex_type, procedimiento_type, metadatos, activo) FROM stdin;
\.


--
-- Data for Name: cat_entidades; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_entidades (id, clave, nombre, abreviatura) FROM stdin;
\.


--
-- Data for Name: cat_matriz_personal_servicio; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_matriz_personal_servicio (tipo_personal_id, servicio_atencion_id) FROM stdin;
\.


--
-- Data for Name: cat_municipios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_municipios (id, entidad_id, clave, nombre) FROM stdin;
\.


--
-- Data for Name: cat_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_roles (id, clave, nombre, descripcion, activo) FROM stdin;
1	SUPERADMIN	Super Administrador	Acceso total y configuración del sistema HIS	t
2	MEDICO	Médico Tratante	Acceso a consulta, expediente clínico y recetas	t
3	ENFERMERIA	Personal de Enfermería	Acceso a triage, somatometría y aplicación de medicamentos	t
4	TRABAJO_SOCIAL	Trabajo Social	Acceso a estudios socioeconómicos y referencias	t
5	RECEPCION	Recepción y Archivo	Acceso a agenda y registro demográfico de pacientes	t
\.


--
-- Data for Name: cat_servicios_atencion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_servicios_atencion (id, clave, descripcion) FROM stdin;
\.


--
-- Data for Name: cat_tipos_personal; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cat_tipos_personal (id, clave, descripcion) FROM stdin;
\.


--
-- Data for Name: clin_atenciones_2026; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clin_atenciones_2026 (id, paciente_id, cita_id, unidad_medica_id, personal_salud_id, fecha_atencion, datos_atencion, created_at) FROM stdin;
\.


--
-- Data for Name: clin_citas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clin_citas (id, paciente_id, unidad_medica_id, personal_salud_id, fecha_hora_cita, estatus_cita, motivo_cita, notas_adicionales, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: clin_pacientes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.clin_pacientes (id, numero_expediente_global, curp, nombre, primer_apellido, segundo_apellido, fecha_nacimiento, sexo_id, asentamiento_id, datos_clinicos, created_at, updated_at, es_identidad_desconocida) FROM stdin;
\.


--
-- Data for Name: gui_diccionario_opciones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.gui_diccionario_opciones (id, diccionario_id, parent_id, clave, valor, metadatos, activo, orden) FROM stdin;
1	1	\N	1	HOMBRE	\N	t	1
2	1	\N	2	MUJER	\N	t	2
3	1	\N	3	INTERSEXUAL	\N	t	3
\.


--
-- Data for Name: gui_diccionarios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.gui_diccionarios (id, codigo, nombre, descripcion, es_sistema) FROM stdin;
1	SYS_SEXO_PACIENTE	Sexo Biológico (Expediente Paciente Maestro)	\N	t
\.


--
-- Data for Name: rel_normatividad_opciones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rel_normatividad_opciones (normatividad_id, opcion_id) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: sys_adopcion_catalogos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_adopcion_catalogos (id, normatividad_id, catalogo_nombre, registro_importacion_id, fecha_adopcion, comentarios) FROM stdin;
\.


--
-- Data for Name: sys_giis_campos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_giis_campos (id, normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion, fuente_catalogo) FROM stdin;
\.


--
-- Data for Name: sys_giis_restricciones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_giis_restricciones (id, normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) FROM stdin;
\.


--
-- Data for Name: sys_normatividad_giis; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_normatividad_giis (id, clave, nombre_documento, version, fecha_publicacion, url_pdf, estatus, fecha_registro) FROM stdin;
\.


--
-- Data for Name: sys_registro_catalogos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sys_registro_catalogos (id, archivo_origen, tabla_destino, criterios_carga, version, estatus, fecha_registro) FROM stdin;
\.


--
-- Name: adm_unidades_medicas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.adm_unidades_medicas_id_seq', 1, false);


--
-- Name: cat_asentamientos_cp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cat_asentamientos_cp_id_seq', 1, false);


--
-- Name: cat_cie10_diagnosticos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cat_cie10_diagnosticos_id_seq', 1, false);


--
-- Name: cat_cie9_procedimientos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cat_cie9_procedimientos_id_seq', 1, false);


--
-- Name: cat_entidades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cat_entidades_id_seq', 1, false);


--
-- Name: cat_municipios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cat_municipios_id_seq', 1, false);


--
-- Name: cat_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cat_roles_id_seq', 5, true);


--
-- Name: cat_servicios_atencion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cat_servicios_atencion_id_seq', 1, false);


--
-- Name: cat_tipos_personal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cat_tipos_personal_id_seq', 1, false);


--
-- Name: gui_diccionario_opciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.gui_diccionario_opciones_id_seq', 3, true);


--
-- Name: gui_diccionarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.gui_diccionarios_id_seq', 1, true);


--
-- Name: sys_adopcion_catalogos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_adopcion_catalogos_id_seq', 1, false);


--
-- Name: sys_giis_campos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_giis_campos_id_seq', 1, false);


--
-- Name: sys_giis_restricciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_giis_restricciones_id_seq', 1, false);


--
-- Name: sys_normatividad_giis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_normatividad_giis_id_seq', 1, false);


--
-- Name: sys_registro_catalogos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sys_registro_catalogos_id_seq', 1, false);


--
-- Name: adm_personal_salud adm_personal_salud_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_personal_salud
    ADD CONSTRAINT adm_personal_salud_pkey PRIMARY KEY (id);


--
-- Name: adm_unidades_medicas adm_unidades_medicas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_unidades_medicas
    ADD CONSTRAINT adm_unidades_medicas_pkey PRIMARY KEY (id);


--
-- Name: adm_usuario_unidad_rol adm_usuario_unidad_rol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuario_unidad_rol
    ADD CONSTRAINT adm_usuario_unidad_rol_pkey PRIMARY KEY (id);


--
-- Name: adm_usuarios adm_usuarios_curp_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuarios
    ADD CONSTRAINT adm_usuarios_curp_key UNIQUE (curp);


--
-- Name: adm_usuarios adm_usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuarios
    ADD CONSTRAINT adm_usuarios_email_key UNIQUE (email);


--
-- Name: adm_usuarios adm_usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuarios
    ADD CONSTRAINT adm_usuarios_pkey PRIMARY KEY (id);


--
-- Name: cat_asentamientos_cp cat_asentamientos_cp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_asentamientos_cp
    ADD CONSTRAINT cat_asentamientos_cp_pkey PRIMARY KEY (id);


--
-- Name: cat_cie10_diagnosticos cat_cie10_diagnosticos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_cie10_diagnosticos
    ADD CONSTRAINT cat_cie10_diagnosticos_pkey PRIMARY KEY (id);


--
-- Name: cat_cie9_procedimientos cat_cie9_procedimientos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_cie9_procedimientos
    ADD CONSTRAINT cat_cie9_procedimientos_pkey PRIMARY KEY (id);


--
-- Name: cat_entidades cat_entidades_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_entidades
    ADD CONSTRAINT cat_entidades_clave_key UNIQUE (clave);


--
-- Name: cat_entidades cat_entidades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_entidades
    ADD CONSTRAINT cat_entidades_pkey PRIMARY KEY (id);


--
-- Name: cat_matriz_personal_servicio cat_matriz_personal_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_matriz_personal_servicio
    ADD CONSTRAINT cat_matriz_personal_servicio_pkey PRIMARY KEY (tipo_personal_id, servicio_atencion_id);


--
-- Name: cat_municipios cat_municipios_entidad_id_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_municipios
    ADD CONSTRAINT cat_municipios_entidad_id_clave_key UNIQUE (entidad_id, clave);


--
-- Name: cat_municipios cat_municipios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_municipios
    ADD CONSTRAINT cat_municipios_pkey PRIMARY KEY (id);


--
-- Name: cat_roles cat_roles_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_roles
    ADD CONSTRAINT cat_roles_clave_key UNIQUE (clave);


--
-- Name: cat_roles cat_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_roles
    ADD CONSTRAINT cat_roles_pkey PRIMARY KEY (id);


--
-- Name: cat_servicios_atencion cat_servicios_atencion_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_servicios_atencion
    ADD CONSTRAINT cat_servicios_atencion_clave_key UNIQUE (clave);


--
-- Name: cat_servicios_atencion cat_servicios_atencion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_servicios_atencion
    ADD CONSTRAINT cat_servicios_atencion_pkey PRIMARY KEY (id);


--
-- Name: cat_tipos_personal cat_tipos_personal_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_tipos_personal
    ADD CONSTRAINT cat_tipos_personal_clave_key UNIQUE (clave);


--
-- Name: cat_tipos_personal cat_tipos_personal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_tipos_personal
    ADD CONSTRAINT cat_tipos_personal_pkey PRIMARY KEY (id);


--
-- Name: clin_atenciones clin_atenciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_pkey PRIMARY KEY (id, fecha_atencion);


--
-- Name: clin_atenciones_2026 clin_atenciones_2026_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_atenciones_2026
    ADD CONSTRAINT clin_atenciones_2026_pkey PRIMARY KEY (id, fecha_atencion);


--
-- Name: clin_citas clin_citas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_citas
    ADD CONSTRAINT clin_citas_pkey PRIMARY KEY (id);


--
-- Name: clin_pacientes clin_pacientes_curp_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_curp_key UNIQUE (curp);


--
-- Name: clin_pacientes clin_pacientes_numero_expediente_global_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_numero_expediente_global_key UNIQUE (numero_expediente_global);


--
-- Name: clin_pacientes clin_pacientes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_pkey PRIMARY KEY (id);


--
-- Name: gui_diccionario_opciones gui_diccionario_opciones_diccionario_id_clave_valor_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gui_diccionario_opciones
    ADD CONSTRAINT gui_diccionario_opciones_diccionario_id_clave_valor_key UNIQUE (diccionario_id, clave, valor);


--
-- Name: gui_diccionario_opciones gui_diccionario_opciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gui_diccionario_opciones
    ADD CONSTRAINT gui_diccionario_opciones_pkey PRIMARY KEY (id);


--
-- Name: gui_diccionarios gui_diccionarios_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gui_diccionarios
    ADD CONSTRAINT gui_diccionarios_codigo_key UNIQUE (codigo);


--
-- Name: gui_diccionarios gui_diccionarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gui_diccionarios
    ADD CONSTRAINT gui_diccionarios_pkey PRIMARY KEY (id);


--
-- Name: rel_normatividad_opciones rel_normatividad_opciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_normatividad_opciones
    ADD CONSTRAINT rel_normatividad_opciones_pkey PRIMARY KEY (normatividad_id, opcion_id);


--
-- Name: sys_adopcion_catalogos sys_adopcion_catalogos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_adopcion_catalogos
    ADD CONSTRAINT sys_adopcion_catalogos_pkey PRIMARY KEY (id);


--
-- Name: sys_giis_campos sys_giis_campos_normatividad_id_nombre_campo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_giis_campos
    ADD CONSTRAINT sys_giis_campos_normatividad_id_nombre_campo_key UNIQUE (normatividad_id, nombre_campo);


--
-- Name: sys_giis_campos sys_giis_campos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_giis_campos
    ADD CONSTRAINT sys_giis_campos_pkey PRIMARY KEY (id);


--
-- Name: sys_giis_restricciones sys_giis_restricciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_giis_restricciones
    ADD CONSTRAINT sys_giis_restricciones_pkey PRIMARY KEY (id);


--
-- Name: sys_normatividad_giis sys_normatividad_giis_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_normatividad_giis
    ADD CONSTRAINT sys_normatividad_giis_clave_key UNIQUE (clave);


--
-- Name: sys_normatividad_giis sys_normatividad_giis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_normatividad_giis
    ADD CONSTRAINT sys_normatividad_giis_pkey PRIMARY KEY (id);


--
-- Name: sys_registro_catalogos sys_registro_catalogos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_registro_catalogos
    ADD CONSTRAINT sys_registro_catalogos_pkey PRIMARY KEY (id);


--
-- Name: adm_personal_salud uq_personal_usuario; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_personal_salud
    ADD CONSTRAINT uq_personal_usuario UNIQUE (usuario_id);


--
-- Name: idx_cie10_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cie10_activo ON public.cat_cie10_diagnosticos USING btree (catalog_key) WHERE (activo = true);


--
-- Name: idx_cie9_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cie9_activo ON public.cat_cie9_procedimientos USING btree (catalog_key) WHERE (activo = true);


--
-- Name: idx_citas_paciente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_citas_paciente ON public.clin_citas USING btree (paciente_id, fecha_hora_cita);


--
-- Name: idx_clues_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clues_activo ON public.adm_unidades_medicas USING btree (clues) WHERE (activo = true);


--
-- Name: idx_cp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cp ON public.cat_asentamientos_cp USING btree (codigo_postal);


--
-- Name: idx_giis_campos_orden; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_giis_campos_orden ON public.sys_giis_campos USING btree (normatividad_id, orden);


--
-- Name: idx_giis_restricciones_campo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_giis_restricciones_campo ON public.sys_giis_restricciones USING btree (campo_id);


--
-- Name: idx_paciente_apellidos; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_paciente_apellidos ON public.clin_pacientes USING btree (primer_apellido, segundo_apellido);


--
-- Name: idx_paciente_fecha_nac; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_paciente_fecha_nac ON public.clin_pacientes USING btree (fecha_nacimiento);


--
-- Name: idx_paciente_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_paciente_nombre ON public.clin_pacientes USING btree (nombre);


--
-- Name: idx_unidades_medicas_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_unidades_medicas_geom ON public.adm_unidades_medicas USING gist (geom);


--
-- Name: idx_uur_historial; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uur_historial ON public.adm_usuario_unidad_rol USING btree (usuario_id, fecha_inicio DESC);


--
-- Name: idx_uur_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uur_unidad ON public.adm_usuario_unidad_rol USING btree (unidad_medica_id) WHERE (activo = true);


--
-- Name: idx_uur_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_uur_usuario ON public.adm_usuario_unidad_rol USING btree (usuario_id) WHERE (activo = true);


--
-- Name: uq_uur_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_uur_activa ON public.adm_usuario_unidad_rol USING btree (usuario_id, unidad_medica_id, rol_id) WHERE (activo = true);


--
-- Name: clin_atenciones_2026_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.clin_atenciones_pkey ATTACH PARTITION public.clin_atenciones_2026_pkey;


--
-- Name: adm_usuario_unidad_rol trg_uur_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_uur_updated_at BEFORE UPDATE ON public.adm_usuario_unidad_rol FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: clin_citas trigger_upd_citas; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_upd_citas BEFORE UPDATE ON public.clin_citas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: clin_pacientes trigger_upd_pacientes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_upd_pacientes BEFORE UPDATE ON public.clin_pacientes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: adm_unidades_medicas trigger_upd_unidades; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_upd_unidades BEFORE UPDATE ON public.adm_unidades_medicas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: adm_personal_salud adm_personal_salud_tipo_personal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_personal_salud
    ADD CONSTRAINT adm_personal_salud_tipo_personal_id_fkey FOREIGN KEY (tipo_personal_id) REFERENCES public.cat_tipos_personal(id);


--
-- Name: adm_personal_salud adm_personal_salud_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_personal_salud
    ADD CONSTRAINT adm_personal_salud_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.adm_usuarios(id);


--
-- Name: adm_unidades_medicas adm_unidades_medicas_asentamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_unidades_medicas
    ADD CONSTRAINT adm_unidades_medicas_asentamiento_id_fkey FOREIGN KEY (asentamiento_id) REFERENCES public.cat_asentamientos_cp(id);


--
-- Name: adm_usuario_unidad_rol adm_usuario_unidad_rol_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuario_unidad_rol
    ADD CONSTRAINT adm_usuario_unidad_rol_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.adm_usuarios(id);


--
-- Name: adm_usuario_unidad_rol adm_usuario_unidad_rol_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuario_unidad_rol
    ADD CONSTRAINT adm_usuario_unidad_rol_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.cat_roles(id);


--
-- Name: adm_usuario_unidad_rol adm_usuario_unidad_rol_unidad_medica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuario_unidad_rol
    ADD CONSTRAINT adm_usuario_unidad_rol_unidad_medica_id_fkey FOREIGN KEY (unidad_medica_id) REFERENCES public.adm_unidades_medicas(id) ON DELETE RESTRICT;


--
-- Name: adm_usuario_unidad_rol adm_usuario_unidad_rol_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuario_unidad_rol
    ADD CONSTRAINT adm_usuario_unidad_rol_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.adm_usuarios(id) ON DELETE CASCADE;


--
-- Name: adm_usuarios adm_usuarios_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_usuarios
    ADD CONSTRAINT adm_usuarios_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.cat_roles(id);


--
-- Name: cat_asentamientos_cp cat_asentamientos_cp_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_asentamientos_cp
    ADD CONSTRAINT cat_asentamientos_cp_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.cat_municipios(id) ON DELETE CASCADE;


--
-- Name: cat_matriz_personal_servicio cat_matriz_personal_servicio_servicio_atencion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_matriz_personal_servicio
    ADD CONSTRAINT cat_matriz_personal_servicio_servicio_atencion_id_fkey FOREIGN KEY (servicio_atencion_id) REFERENCES public.cat_servicios_atencion(id) ON DELETE CASCADE;


--
-- Name: cat_matriz_personal_servicio cat_matriz_personal_servicio_tipo_personal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_matriz_personal_servicio
    ADD CONSTRAINT cat_matriz_personal_servicio_tipo_personal_id_fkey FOREIGN KEY (tipo_personal_id) REFERENCES public.cat_tipos_personal(id) ON DELETE CASCADE;


--
-- Name: cat_municipios cat_municipios_entidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cat_municipios
    ADD CONSTRAINT cat_municipios_entidad_id_fkey FOREIGN KEY (entidad_id) REFERENCES public.cat_entidades(id) ON DELETE CASCADE;


--
-- Name: clin_atenciones clin_atenciones_cita_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_cita_id_fkey FOREIGN KEY (cita_id) REFERENCES public.clin_citas(id);


--
-- Name: clin_atenciones clin_atenciones_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.clin_pacientes(id);


--
-- Name: clin_atenciones clin_atenciones_personal_salud_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_personal_salud_id_fkey FOREIGN KEY (personal_salud_id) REFERENCES public.adm_personal_salud(id);


--
-- Name: clin_atenciones clin_atenciones_unidad_medica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.clin_atenciones
    ADD CONSTRAINT clin_atenciones_unidad_medica_id_fkey FOREIGN KEY (unidad_medica_id) REFERENCES public.adm_unidades_medicas(id);


--
-- Name: clin_citas clin_citas_paciente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_citas
    ADD CONSTRAINT clin_citas_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.clin_pacientes(id) ON DELETE CASCADE;


--
-- Name: clin_citas clin_citas_personal_salud_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_citas
    ADD CONSTRAINT clin_citas_personal_salud_id_fkey FOREIGN KEY (personal_salud_id) REFERENCES public.adm_personal_salud(id);


--
-- Name: clin_citas clin_citas_unidad_medica_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_citas
    ADD CONSTRAINT clin_citas_unidad_medica_id_fkey FOREIGN KEY (unidad_medica_id) REFERENCES public.adm_unidades_medicas(id);


--
-- Name: clin_pacientes clin_pacientes_asentamiento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_asentamiento_id_fkey FOREIGN KEY (asentamiento_id) REFERENCES public.cat_asentamientos_cp(id);


--
-- Name: clin_pacientes clin_pacientes_sexo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clin_pacientes
    ADD CONSTRAINT clin_pacientes_sexo_id_fkey FOREIGN KEY (sexo_id) REFERENCES public.gui_diccionario_opciones(id);


--
-- Name: gui_diccionario_opciones gui_diccionario_opciones_diccionario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gui_diccionario_opciones
    ADD CONSTRAINT gui_diccionario_opciones_diccionario_id_fkey FOREIGN KEY (diccionario_id) REFERENCES public.gui_diccionarios(id) ON DELETE CASCADE;


--
-- Name: gui_diccionario_opciones gui_diccionario_opciones_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gui_diccionario_opciones
    ADD CONSTRAINT gui_diccionario_opciones_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.gui_diccionario_opciones(id);


--
-- Name: rel_normatividad_opciones rel_normatividad_opciones_normatividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_normatividad_opciones
    ADD CONSTRAINT rel_normatividad_opciones_normatividad_id_fkey FOREIGN KEY (normatividad_id) REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE;


--
-- Name: rel_normatividad_opciones rel_normatividad_opciones_opcion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rel_normatividad_opciones
    ADD CONSTRAINT rel_normatividad_opciones_opcion_id_fkey FOREIGN KEY (opcion_id) REFERENCES public.gui_diccionario_opciones(id) ON DELETE CASCADE;


--
-- Name: sys_adopcion_catalogos sys_adopcion_catalogos_normatividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_adopcion_catalogos
    ADD CONSTRAINT sys_adopcion_catalogos_normatividad_id_fkey FOREIGN KEY (normatividad_id) REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE;


--
-- Name: sys_adopcion_catalogos sys_adopcion_catalogos_registro_importacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_adopcion_catalogos
    ADD CONSTRAINT sys_adopcion_catalogos_registro_importacion_id_fkey FOREIGN KEY (registro_importacion_id) REFERENCES public.sys_registro_catalogos(id) ON DELETE CASCADE;


--
-- Name: sys_giis_campos sys_giis_campos_normatividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_giis_campos
    ADD CONSTRAINT sys_giis_campos_normatividad_id_fkey FOREIGN KEY (normatividad_id) REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE;


--
-- Name: sys_giis_restricciones sys_giis_restricciones_campo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_giis_restricciones
    ADD CONSTRAINT sys_giis_restricciones_campo_id_fkey FOREIGN KEY (campo_id) REFERENCES public.sys_giis_campos(id) ON DELETE CASCADE;


--
-- Name: sys_giis_restricciones sys_giis_restricciones_normatividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_giis_restricciones
    ADD CONSTRAINT sys_giis_restricciones_normatividad_id_fkey FOREIGN KEY (normatividad_id) REFERENCES public.sys_normatividad_giis(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict QdfLL5EY2dFaQOp9O0A5pu8avPiPOCdfIyaqRKunTIU0q5ypPYRvsZiZcCfQGae

