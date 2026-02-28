-- =========================================================================
-- INYECCIÓN DE METADATOS Y DOCUMENTACIÓN EN LA BASE DE DATOS
-- =========================================================================

-- MÓDULO DE SEGURIDAD
COMMENT ON TABLE public.adm_usuarios IS 'Almacena credenciales de acceso. Protegida con hash y monitoreo de fuerza bruta.';
COMMENT ON COLUMN public.adm_usuarios.intentos_fallidos IS 'Contador para bloquear la cuenta (anti-hackeo).';
COMMENT ON COLUMN public.adm_usuarios.bloqueado_hasta IS 'Marca de tiempo hasta la que el usuario no puede iniciar sesión.';

COMMENT ON TABLE public.cat_roles IS 'Roles del sistema para el Control de Acceso (RBAC).';

-- MÓDULO CLÍNICO
COMMENT ON TABLE public.clin_pacientes IS 'Directorio Maestro de Pacientes (MPI). Contiene la información demográfica central.';
COMMENT ON COLUMN public.clin_pacientes.es_identidad_desconocida IS 'Bandera booleana para pacientes de Urgencias ingresados sin identificación (NN).';

COMMENT ON TABLE public.clin_atenciones IS 'Tabla particionada. Almacena las consultas médicas, urgencias y egresos de forma transaccional.';
COMMENT ON COLUMN public.clin_atenciones.datos_atencion IS 'Payload JSONB que almacena todas las respuestas dinámicas de los formularios médicos (GIIS).';

-- MÓDULO MOTOR GIIS
COMMENT ON TABLE public.sys_giis_campos IS 'Diccionario de variables para construir los formularios médicos dinámicamente en el Frontend.';
COMMENT ON COLUMN public.sys_giis_campos.fuente_catalogo IS 'Indica al API del Backend a qué tabla dirigir la consulta para llenar los menús desplegables (CIE10, CIE9, SEPOMEX, DICCIONARIOS).';

COMMENT ON TABLE public.sys_giis_restricciones IS 'Motor de reglas. Contiene la lógica en JSONB para bloquear inputs erróneos en el Frontend (Ej. Congruencia de sexo y edad).';

-- MÓDULO DE EXPEDIENTE DIGITAL Y AUDITORÍA
COMMENT ON TABLE public.doc_expediente_digital IS 'Repositorio de PDFs, DICOM y Consentimientos Informados.';
COMMENT ON COLUMN public.doc_expediente_digital.hash_integridad IS 'Firma criptográfica (SHA-256) del archivo para cumplimiento forense y NOM-024 de no repudio.';

COMMENT ON TABLE public.sys_bitacora_auditoria IS 'Log histórico inmutable. Registra qué usuario hizo qué cambio en los datos clínicos. Protegida por trigger anti-borrado.';

INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus)
VALUES ('DGIS-BASE', 'Catálogos Base Nacionales DGIS', '1.0', CURRENT_DATE, 'ACTIVO')
ON CONFLICT (clave) DO NOTHING;