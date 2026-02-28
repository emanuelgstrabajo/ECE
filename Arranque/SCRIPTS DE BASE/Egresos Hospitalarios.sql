
-- =========================================================================
-- FASE 2: CARGA DE EGRESOS HOSPITALARIOS Y MINICATÁLOGOS COMPLETOS
-- =========================================================================
DO $$
DECLARE
    v_guia_egr INT;
    v_fecha DATE := '2022-07-15';
    v_dic_id INT;
BEGIN

    -- 1. ASEGURAR QUE LA GUÍA EXISTE
    INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus) 
    VALUES ('GIIS-B002-04-05', 'Egresos Hospitalarios', '4.5', v_fecha, 'ACTIVO')
    ON CONFLICT (clave) DO UPDATE SET version = EXCLUDED.version;

    SELECT id INTO v_guia_egr FROM public.sys_normatividad_giis WHERE clave = 'GIIS-B002-04-05';

    -- 2. INYECCIÓN DE MINICATÁLOGOS EN GUI_DICCIONARIOS
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_MOTIVO_EGRESO', 'Motivo de Egreso Hospitalario', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_MOTIVO_EGRESO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'CURACION', 1), (v_dic_id, '2', 'MEJORIA', 2), (v_dic_id, '3', 'VOLUNTAD PROPIA', 3), (v_dic_id, '4', 'TRASLADO A OTRA UNIDAD', 4), (v_dic_id, '5', 'DEFUNCION', 5), (v_dic_id, '6', 'FUGA', 6), (v_dic_id, '7', 'OTRO', 7) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_PROCEDENCIA', 'Área de Procedencia', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_PROCEDENCIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'CONSULTA EXTERNA', 1), (v_dic_id, '2', 'URGENCIAS', 2), (v_dic_id, '3', 'REFERIDO', 3), (v_dic_id, '4', 'CUNERO PATOLOGICO', 4), (v_dic_id, '5', 'OTRO', 5) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_TIPO_INGRESO', 'Tipo de Servicio de Ingreso', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_TIPO_INGRESO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'NORMAL', 1), (v_dic_id, '2', 'CORTA ESTANCIA', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_ATENCION_OBST', 'Tipo de Atención Obstétrica', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_ATENCION_OBST';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'ABORTO', 1), (v_dic_id, '2', 'PARTO', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_TIPO_PARTO', 'Tipo de Parto', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_TIPO_PARTO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'EUTOCICO', 1), (v_dic_id, '2', 'DISTOCICO VAGINAL', 2), (v_dic_id, '3', 'CESAREA', 3), (v_dic_id, '9', 'NO ESPECIFICADO', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_USO_QUIROFANO', 'Uso de Quirófano', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_USO_QUIROFANO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'DENTRO', 1), (v_dic_id, '2', 'FUERA', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('SIS_OPCION_SINO', 'Opciones Si / No', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'SIS_OPCION_SINO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'SI', 1), (v_dic_id, '2', 'NO', 2), (v_dic_id, '8', 'SE IGNORA', 3), (v_dic_id, '9', 'NO ESPECIFICADO', 4) ON CONFLICT DO NOTHING;

    -- NUEVOS DICCIONARIOS EXTRAÍDOS DEL PDF PARA COMPLETAR EL FRONT-END --
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_TIPO_ANESTESIA', 'Tipo de Anestesia', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_TIPO_ANESTESIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'GENERAL', 1), (v_dic_id, '2', 'REGIONAL', 2), (v_dic_id, '3', 'SEDACION', 3), (v_dic_id, '4', 'LOCAL', 4), (v_dic_id, '5', 'COMBINADA', 5), (v_dic_id, '6', 'NO USO', 6) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_MUJER_FERTIL', 'Condición de Mujer Fértil', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_MUJER_FERTIL';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'EMBARAZO', 1), (v_dic_id, '2', 'PUERPERIO', 2), (v_dic_id, '3', 'NO ESTABA EMBARAZADA', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_PLANIFICACION_FAM', 'Planificación Familiar (Egreso)', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_PLANIFICACION_FAM';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NINGUNO', 1), (v_dic_id, '1', 'HORMONAL ORAL', 2), (v_dic_id, '2', 'INYECTABLE MENSUAL', 3), (v_dic_id, '4', 'IMPLANTE SUBDERMICO', 4), (v_dic_id, '5', 'DIU', 5), (v_dic_id, '10', 'OTB', 6), (v_dic_id, '11', 'OTRO METODO', 7) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_TIPO_ATENCION', 'Tipo de Atención Proporcionada', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_TIPO_ATENCION';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'PRIMERA VEZ', 1), (v_dic_id, '2', 'SUBSECUENTE', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('HOSP_CONDICION_NAC', 'Condición de Nacimiento', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'HOSP_CONDICION_NAC';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'NACIDO MUERTO', 1), (v_dic_id, '2', 'NACIDO VIVO', 2) ON CONFLICT DO NOTHING;

    -- 3. CARGA DE LAS 92 VARIABLES (Corregidas para usar CATALOGO donde corresponde)
    
    -- Variables 1 a 30 (Identificación y Demografía)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_egr, 1, 'clues', 'Clave Única de Establecimientos en Salud', 'texto', 11, TRUE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_egr, 2, 'folio', 'Clave asignada por la Unidad Hospitalaria', 'texto', 8, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 3, 'curpPaciente', 'CURP del paciente', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_egr, 4, 'nombre', 'Nombre(s) del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 5, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 6, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 7, 'fechaNacimiento', 'Fecha de nacimiento del paciente', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_egr, 8, 'paisOrigen', 'Identificador del país de nacimiento', 'texto', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_egr, 9, 'entidadNacimiento', 'Entidad federativa de nacimiento', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_egr, 10, 'nacioHospital', 'Nació en el hospital', 'texto', 1, FALSE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 11, 'sexo', 'Sexo del paciente', 'texto', 1, TRUE, FALSE, 'SEXO', 'CATALOGO'),
    (v_guia_egr, 12, 'peso', 'Peso del paciente en kilogramos', 'numerico', 7, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 13, 'talla', 'Talla del paciente en centímetros', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 14, 'derechohabiencia', 'Afiliación', 'texto', 2, TRUE, FALSE, 'AFILIACION', 'CATALOGO'),
    (v_guia_egr, 15, 'gratuidad', 'Programa de Salud de la Ciudad de México', 'texto', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 16, 'estadoConyugal', 'Estado conyugal del paciente', 'texto', 1, TRUE, FALSE, 'ESTADO_CONYUGAL', 'CATALOGO'),
    (v_guia_egr, 17, 'seConsideraIndigena', '¿Se considera Indígena?', 'texto', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 18, 'hablaLenguaIndigena', '¿Habla alguna lengua Indígena?', 'texto', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 19, 'cualLengua', '¿Cuál lengua Indígena habla?', 'texto', 4, TRUE, FALSE, 'LENGUA_INDIGENA', 'CATALOGO'),
    (v_guia_egr, 20, 'seConsideraAfromexicano', '¿Se considera Afromexicano?', 'texto', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 21, 'paisResidencia', 'País de residencia del paciente', 'texto', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_egr, 22, 'entidadResidencia', 'Entidad de residencia', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_egr, 23, 'municipioResidencia', 'Municipio de residencia', 'texto', 3, TRUE, FALSE, 'MUNICIPIOS', 'CATALOGO'),
    (v_guia_egr, 24, 'localidadResidencia', 'Localidad de residencia', 'texto', 4, TRUE, FALSE, 'LOCALIDADES', 'CATALOGO'),
    (v_guia_egr, 25, 'otraLocalidad', 'Especificación del nombre de la localidad', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 26, 'codigoPostal', 'Código Postal del lugar de residencia', 'texto', 5, TRUE, FALSE, 'CODIGO_POSTAL', 'CATALOGO'),
    (v_guia_egr, 27, 'fechaIngreso', 'Fecha de ingreso', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_egr, 28, 'fechaEgreso', 'Fecha de egreso', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_egr, 29, 'tipoServicioIngreso', 'Clave del tipo de servicio de ingreso', 'texto', 1, TRUE, FALSE, 'HOSP_TIPO_INGRESO', 'CATALOGO'),
    (v_guia_egr, 30, 'claveServicioIngreso', 'Clave del servicio de ingreso', 'texto', 4, TRUE, FALSE, 'ESPECIALIDADES', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Variables 31 a 64 (Hospitalización, Diagnósticos y Procedimientos)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_egr, 31, 'numeroServiciosAdicional', 'Número de servicios adicionales', 'numerico', 1, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 32, 'claveServicioAdicional', 'Clave del servicio adicional', 'texto', 4, FALSE, FALSE, 'ESPECIALIDADES', 'ARREGLO'),
    (v_guia_egr, 33, 'claveServicioEgreso', 'Clave del servicio de egreso', 'texto', 4, TRUE, FALSE, 'ESPECIALIDADES', 'CATALOGO'),
    (v_guia_egr, 34, 'terapiaIntensivaDias', 'Estancia en terapia intensiva en días', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 35, 'terapiaIntensivaHoras', 'Estancia en terapia intensiva en horas', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 36, 'terapiaIntermediaDias', 'Estancia en terapia intermedia en días', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 37, 'terapiaIntermediaHoras', 'Estancia en terapia intermedia en horas', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 38, 'procedencia', 'Área de procedencia del paciente', 'texto', 1, TRUE, FALSE, 'HOSP_PROCEDENCIA', 'CATALOGO'),
    (v_guia_egr, 39, 'especifiqueProcedencia', 'Especifique el lugar de procedencia', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 40, 'cluesProcedencia', 'CLUES de procedencia', 'texto', 11, FALSE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_egr, 41, 'motivoEgreso', 'Motivo del egreso', 'texto', 1, TRUE, FALSE, 'HOSP_MOTIVO_EGRESO', 'CATALOGO'),
    (v_guia_egr, 42, 'cluesReferido', 'CLUES de la unidad médica de Referencia', 'texto', 11, FALSE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_egr, 43, 'mujerFertil', 'Mujer en edad fértil', 'texto', 1, TRUE, FALSE, 'HOSP_MUJER_FERTIL', 'CATALOGO'),
    (v_guia_egr, 44, 'descripcionAfeccionPrincipal', 'Descripción de la afección principal', 'texto', 250, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 45, 'codigoCIEAfeccionPrincipal', 'Código CIE afección principal', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_egr, 46, 'tipoAtencion', 'Tipo de atención proporcionada', 'texto', 1, TRUE, FALSE, 'HOSP_TIPO_ATENCION', 'CATALOGO'),
    (v_guia_egr, 47, 'numeroComorbilidad', 'Número consecutivo de comorbilidad', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 48, 'descripcionComorbilidad', 'Descripción de comorbilidad', 'texto', 250, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 49, 'codigoCieComorbilidad', 'Código CIE de comorbilidad', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'ARREGLO'),
    (v_guia_egr, 50, 'afeccionPrincipalReseleccionada', 'Código CIE afección principal reseleccionada', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_egr, 51, 'causaExterna', 'Descripción de causa externa', 'texto', 250, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 52, 'codigoCieCausaExterna', 'Código CIE de Causa Externa', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_egr, 53, 'morfologia', 'Código morfología de tumores', 'texto', 10, FALSE, FALSE, 'MORFOLOGIA', 'CATALOGO'),
    (v_guia_egr, 54, 'infeccionIntraHospitalaria', 'Existió Infección intrahospitalaria', 'texto', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 55, 'numeroProcedimiento', 'Número de procedimiento médico', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 56, 'descripcionProcedimiento', 'Descripción del procedimiento', 'texto', 250, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 57, 'codigoCieProcedimiento', 'Código CIE-9MC del procedimiento', 'texto', 4, FALSE, FALSE, 'PROCEDIMIENTO', 'ARREGLO'),
    (v_guia_egr, 58, 'tipoAnestesia', 'Tipo de Anestesia', 'texto', 1, FALSE, FALSE, 'HOSP_TIPO_ANESTESIA', 'CATALOGO'),
    (v_guia_egr, 59, 'quirofanoDentroFuera', 'Uso del quirófano', 'texto', 1, FALSE, FALSE, 'HOSP_USO_QUIROFANO', 'CATALOGO'),
    (v_guia_egr, 60, 'tiempoQuirofano', 'Tiempo en el quirófano', 'texto', 5, FALSE, FALSE, NULL, 'FORMATO'),
    (v_guia_egr, 61, 'cedulaProfesional', 'Cédula Profesional del médico', 'texto', 14, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 62, 'folioLesion', 'Folio atención violencia/lesión', 'texto', 8, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 63, 'ministerioPublico', 'Envió al MP al fallecido', 'texto', 1, FALSE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 64, 'folioCertificadoDefuncion', 'Folio del certificado de defunción', 'numerico', 9, FALSE, FALSE, NULL, 'FORMATO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Variables 65 a 92 (Obstetricia, Nacimientos y Responsable)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_egr, 65, 'gestas', 'Número de embarazos', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 66, 'partos', 'Número de partos', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 67, 'abortos', 'Número de abortos', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 68, 'cesareas', 'Número de cesáreas', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 69, 'edadGestacional', 'Semanas de gestación', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 70, 'tipoAtencionObstetrica', 'Tipo de Atención Obstétrica', 'texto', 1, FALSE, FALSE, 'HOSP_ATENCION_OBST', 'CATALOGO'),
    (v_guia_egr, 71, 'tipoParto', 'Tipo de parto', 'texto', 1, FALSE, FALSE, 'HOSP_TIPO_PARTO', 'CATALOGO'),
    (v_guia_egr, 72, 'tipoProcAborto', 'Procedimiento de aborto', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 73, 'productoEmbarazo', 'Tipo de productos extraídos', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 74, 'totalProductos', 'Total de los productos', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 75, 'planificacionFamiliar', 'Método de planificación familiar', 'texto', 2, FALSE, FALSE, 'HOSP_PLANIFICACION_FAM', 'CATALOGO'),
    (v_guia_egr, 76, 'otroMetodo', 'Otro método planificacion', 'texto', 250, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 77, 'numeroProducto', 'Número consecutivo del producto', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 78, 'condicionNacimiento', 'Condición de nacimiento', 'texto', 1, FALSE, FALSE, 'HOSP_CONDICION_NAC', 'CATALOGO'),
    (v_guia_egr, 79, 'condicionNacidoVivo', 'Condición del nacido vivo al egresar', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 80, 'folioCertificado', 'Folio del certificado de nacimiento', 'texto', 14, FALSE, FALSE, NULL, 'FORMATO'),
    (v_guia_egr, 81, 'apgar5Minutos', 'APGAR a los 5 min', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 82, 'reanimacionNeonatal', 'Uso de reanimación', 'texto', 1, FALSE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 83, 'alojamientoConjunto', 'Alojamiento conjunto con madre', 'texto', 1, FALSE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 84, 'lactanciaExclusiva', 'Lactancia exclusiva', 'texto', 1, FALSE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_egr, 85, 'tipoUnidad', 'Tipo de Unidad (Psiquiátricos)', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 86, 'tipoServicio', 'Tipo de servicio (Psiquiátricos)', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_egr, 87, 'paisNacimiento', 'País de nacimiento del prestador', 'texto', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_egr, 88, 'curpResponsable', 'CURP del profesional', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_egr, 89, 'nombreResponsable', 'Nombre del profesional', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 90, 'primerApellidoResponsable', 'Primer apellido del profesional', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 91, 'segundoApellidoResponsable', 'Segundo apellido del profesional', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_egr, 92, 'cedulaResponsable', 'Cédula profesional del médico', 'texto', 14, TRUE, TRUE, NULL, 'TEXTO_LIBRE')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- 4. CARGA DE REGLAS LÓGICAS COMPLETADAS CON EL PDF
    
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_egr, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='peso' AND normatividad_id=v_guia_egr), 
     'LIMITE_PESO', 'RANGO_VALOR', '{"operador": "between", "min": 1, "max": 400}'::jsonb, 
     'El peso debe estar entre 1 y 400 kg.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_egr, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='tipoServicioIngreso' AND normatividad_id=v_guia_egr), 
     'REQ_CLAVE_SERVICIO', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "tipoServicioIngreso", "valor": "1"}, "accion": {"requerido": "claveServicioIngreso"}}'::jsonb, 
     'Si el ingreso es Normal (1), la Especialidad de Ingreso es obligatoria.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_egr, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='edadGestacional' AND normatividad_id=v_guia_egr), 
     'LIMITE_EDAD_GESTACIONAL', 'RANGO_VALOR', '{"operador": "between", "min": 1, "max": 45}'::jsonb, 
     'La edad gestacional no puede ser mayor a 45 semanas.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_egr, NULL, 
     'COHERENCIA_PARTO_ABORTO', 'LOGICA_CRUZADA', '{"operador": "not_and", "condiciones": [{"campo": "codigoCIEAfeccionPrincipal", "startsWith": "O8"}, {"campo": "codigoCIEAfeccionPrincipal", "startsWith": "O0"}]}'::jsonb, 
     'No se puede mezclar diagnósticos de parto con aborto en la misma atención.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_egr, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='quirofanoDentroFuera' AND normatividad_id=v_guia_egr), 
     'REQ_CEDULA_MEDICO', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "quirofanoDentroFuera", "valor": "1"}, "accion": {"requerido": "cedulaProfesional"}}'::jsonb, 
     'Si se utilizó el quirófano (DENTRO), la Cédula Profesional del médico es obligatoria.', 'ERROR', v_fecha);

    -- NUEVAS REGLAS EXTRAÍDAS DEL DICCIONARIO DEL PDF --
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_egr, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='folioLesion' AND normatividad_id=v_guia_egr), 
     'REQ_FOLIO_LESION', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "codigoCIEAfeccionPrincipal", "startsWith_any": ["S", "T"]}, "accion": {"requerido": "folioLesion"}}'::jsonb, 
     'Si el diagnóstico principal corresponde al Capítulo XIX (Lesiones S00-T98), el folio de lesión es obligatorio.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_egr, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='apgar5Minutos' AND normatividad_id=v_guia_egr), 
     'REQ_APGAR', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "tipoAtencionObstetrica", "valor": "2"}, "accion": {"requerido": "apgar5Minutos"}}'::jsonb, 
     'Si el tipo de atención obstétrica es PARTO (2), se debe registrar la valoración del APGAR a los 5 minutos.', 'ERROR', v_fecha);

END $$;