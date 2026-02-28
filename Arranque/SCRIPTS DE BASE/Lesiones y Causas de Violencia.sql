-- =========================================================================
-- CARGA EXHAUSTIVA AL 100% - GUÍA 4: LESIONES Y CAUSAS DE VIOLENCIA
-- Guía GIIS-B013-02-03 (82 Variables Oficiales)
-- =========================================================================

DO $$
DECLARE
    v_guia_les INT;
    v_fecha DATE := '2022-03-15';
    v_dic_id INT;
BEGIN

    -- 1. ASEGURAR QUE LA GUÍA EXISTE EN EL CATÁLOGO MAESTRO
    INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus) 
    VALUES ('GIIS-B013-02-03', 'Lesiones y Causas de Violencia', '2.3', v_fecha, 'ACTIVO')
    ON CONFLICT (clave) DO UPDATE SET version = EXCLUDED.version;

    SELECT id INTO v_guia_les FROM public.sys_normatividad_giis WHERE clave = 'GIIS-B013-02-03';

    -- 2. INYECCIÓN DE MINICATÁLOGOS ESPECÍFICOS DE LA GUÍA DE LESIONES
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_USUARIO_REFERIDO', 'Institución que refiere al paciente', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_USUARIO_REFERIDO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'UNIDAD MEDICA', 1), (v_dic_id, '2', 'PROCURACION DE JUSTICIA', 2), (v_dic_id, '3', 'SECRETARIA DE EDUCACION', 3), (v_dic_id, '4', 'DESARROLLO SOCIAL', 4), (v_dic_id, '5', 'DIF', 5), (v_dic_id, '6', 'OTRAS INSTITUCIONES GUBERNAMENTALES', 6), (v_dic_id, '7', 'INSTITUCIONES NO GUBERNAMENTALES', 7), (v_dic_id, '8', 'SIN REFERENCIA (Iniciativa Propia)', 8) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_SUSTANCIAS', 'Sospecha bajo efectos de sustancias', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_SUSTANCIAS';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'ALCOHOL', 1), (v_dic_id, '2', 'DROGA POR INDICACION MEDICA', 2), (v_dic_id, '3', 'DROGAS ILEGALES', 3), (v_dic_id, '4', 'SE IGNORA', 4), (v_dic_id, '5', 'NINGUNA', 5) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_INTENCIONALIDAD', 'Intencionalidad del evento', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_INTENCIONALIDAD';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'ACCIDENTAL', 1), (v_dic_id, '2', 'VIOLENCIA FAMILIAR', 2), (v_dic_id, '3', 'VIOLENCIA NO FAMILIAR', 3), (v_dic_id, '4', 'AUTO INFLIGIDO', 4), (v_dic_id, '11', 'TRATA DE PERSONAS', 5) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_EVENTO_REPETIDO', 'Identificación de evento repetido', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_EVENTO_REPETIDO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'UNICA VEZ', 1), (v_dic_id, '2', 'REPETIDO', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_LESIONADO_VEHICULO', 'Lesionado en vehículo de motor', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_LESIONADO_VEHICULO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'CONDUCTOR', 1), (v_dic_id, '2', 'OCUPANTE', 2), (v_dic_id, '3', 'PEATON', 3), (v_dic_id, '4', 'SE IGNORA', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_EQUIPO_UTILIZADO', 'Equipo de seguridad utilizado', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_EQUIPO_UTILIZADO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'CINTURON DE SEGURIDAD', 1), (v_dic_id, '2', 'CASCO', 2), (v_dic_id, '3', 'SILLA PORTA INFANTE', 3), (v_dic_id, '4', 'OTRO', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_TIPO_VIOLENCIA', 'Tipo de Violencia', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_TIPO_VIOLENCIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '6', 'VIOLENCIA FISICA', 1), (v_dic_id, '7', 'VIOLENCIA SEXUAL', 2), (v_dic_id, '8', 'VIOLENCIA PSICOLOGICA', 3), (v_dic_id, '9', 'VIOLENCIA ECONOMICA / PATRIMONIAL', 4), (v_dic_id, '10', 'ABANDONO Y/O NEGLIGENCIA', 5) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_NUMERO_AGRESORES', 'Número de agresores', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_NUMERO_AGRESORES';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'UNICO', 1), (v_dic_id, '2', 'MAS DE UNO', 2), (v_dic_id, '3', 'NO ESPECIFICADO', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_PARENTESCO', 'Parentesco del agresor', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_PARENTESCO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO ESPECIFICADO', 1), (v_dic_id, '1', 'PADRE', 2), (v_dic_id, '2', 'MADRE', 3), (v_dic_id, '3', 'CONYUGE/PAREJA/NOVIO', 4), (v_dic_id, '4', 'OTRO PARIENTE', 5), (v_dic_id, '5', 'PADRASTRO', 6), (v_dic_id, '6', 'MADRASTRA', 7), (v_dic_id, '7', 'CONOCIDO SIN PARENTESCO', 8), (v_dic_id, '8', 'DESCONOCIDO', 9), (v_dic_id, '9', 'HIJA/HIJO', 10), (v_dic_id, '10', 'OTRO', 11), (v_dic_id, '99', 'SE IGNORA', 12) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_SERVICIO_ATENCION', 'Servicio que otorgo la atención', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_SERVICIO_ATENCION';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'CONSULTA EXTERNA', 1), (v_dic_id, '2', 'HOSPITALIZACION', 2), (v_dic_id, '3', 'URGENCIAS', 3), (v_dic_id, '4', 'SERVICIO ESPECIALIZADO DE ATENCION A LA VIOLENCIA', 4), (v_dic_id, '5', 'OTRO SERVICIO', 5) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_TIPO_ATENCION', 'Tipo de Atención Brindada', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_TIPO_ATENCION';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'TRATAMIENTO MEDICO', 1), (v_dic_id, '2', 'TRATAMIENTO PSICOLOGICO', 2), (v_dic_id, '3', 'TRATAMIENTO QUIRURGICO', 3), (v_dic_id, '4', 'TRATAMIENTO PSIQUIATRICO', 4), (v_dic_id, '5', 'CONSEJERIA', 5), (v_dic_id, '6', 'OTRO', 6), (v_dic_id, '7', 'PILDORA ANTICONCEPTIVA DE EMERGENCIA', 7), (v_dic_id, '8', 'PROFILAXIS VIH', 8), (v_dic_id, '9', 'PROFILAXIS OTRAS ITS', 9) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_DESPUES_ATENCION', 'Destino después de la atención', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_DESPUES_ATENCION';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'DOMICILIO', 1), (v_dic_id, '2', 'TRASLADO A OTRA UNIDAD MEDICA', 2), (v_dic_id, '3', 'SERVICIO ESPECIALIZADO ATENCION A LA VIOLENCIA', 3), (v_dic_id, '4', 'CONSULTA EXTERNA', 4), (v_dic_id, '5', 'DEFUNCION', 5), (v_dic_id, '6', 'REFUGIO O ALBERGUE', 6), (v_dic_id, '7', 'DIF', 7), (v_dic_id, '8', 'HOSPITALIZACION', 8), (v_dic_id, '9', 'MINISTERIO PUBLICO', 9), (v_dic_id, '10', 'GRUPO DE AYUDA MUTUA', 10), (v_dic_id, '11', 'OTRO', 11) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('LES_RESPONSABLE', 'Responsable de la atención', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'LES_RESPONSABLE';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'MEDICO TRATANTE', 1), (v_dic_id, '2', 'PSICOLOGO TRATANTE', 2), (v_dic_id, '3', 'TRABAJADORA SOCIAL', 3) ON CONFLICT DO NOTHING;


    -- 3. CARGA DE LAS 82 VARIABLES EXACTAS DEL PDF (En bloques)
    
    -- Variables 1 al 23 (Identificación, Demografía)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_les, 1, 'clues', 'Clave Única de Establecimientos en Salud', 'texto', 11, TRUE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_les, 2, 'folio', 'Clave asignada por la Unidad Médica', 'texto', 8, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 3, 'curpPaciente', 'Clave Única de Registro de Población', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_les, 4, 'nombre', 'Nombre(s) del Paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 5, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 6, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 7, 'fechaNacimiento', 'Fecha de nacimiento del paciente', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_les, 8, 'paisOrigen', 'País de nacimiento del paciente', 'texto', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_les, 9, 'entidadNacimiento', 'Entidad federativa de nacimiento', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_les, 10, 'escolaridad', 'Nivel de escolaridad', 'numerico', 3, FALSE, FALSE, 'ESCOLARIDAD', 'CATALOGO'),
    (v_guia_les, 11, 'sabeLeerEscribir', 'Habilidad del paciente para leer y escribir', 'numerico', 1, FALSE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 12, 'sexo', 'Sexo del paciente', 'numerico', 1, TRUE, FALSE, 'SEXO', 'CATALOGO'),
    (v_guia_les, 13, 'derechohabiencia', 'Afiliación', 'numerico', 2, TRUE, FALSE, 'AFILIACION', 'CATALOGO'),
    (v_guia_les, 14, 'gratuidad', 'Programa de Salud CDMX', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 15, 'seConsideraIndigena', '¿Se considera Indígena?', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 16, 'hablaLenguaIndigena', '¿Habla lengua Indígena?', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 17, 'cualLengua', '¿Cuál lengua Indígena habla?', 'texto', 4, TRUE, FALSE, 'LENGUA_INDIGENA', 'CATALOGO'),
    (v_guia_les, 18, 'seConsideraAfromexicano', '¿Se considera Afromexicano?', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 19, 'mujerFertil', '¿Se encuentra embarazada?', 'numerico', 1, TRUE, FALSE, 'HOSP_MUJER_FERTIL', 'CATALOGO'),
    (v_guia_les, 20, 'edadGestacional', 'Semanas de gestación', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_les, 21, 'discapacidad', 'Discapacidad preexistente', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 22, 'usuarioReferido', 'Institución que refiere al paciente', 'numerico', 1, TRUE, FALSE, 'LES_USUARIO_REFERIDO', 'CATALOGO'),
    (v_guia_les, 23, 'cluesReferido', 'CLUES de la Unidad que refiere', 'texto', 11, FALSE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Variables 24 al 48 (Detalles del Evento, Prehospitalario, Circunstancias)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_les, 24, 'fechaEvento', 'Fecha en la que ocurrió el evento', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_les, 25, 'horaEvento', 'Hora en la que ocurrió el evento', 'texto', 5, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_les, 26, 'diaFestivo', '¿Día festivo o fin de semana?', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 27, 'sitioOcurrencia', 'Sitio de ocurrencia del evento', 'numerico', 3, TRUE, FALSE, 'SITIO_OCURRENCIA_LESION', 'CATALOGO'),
    (v_guia_les, 28, 'entidadOcurrencia', 'Entidad de la ocurrencia', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_les, 29, 'municipioOcurrencia', 'Municipio de la ocurrencia', 'texto', 3, TRUE, FALSE, 'MUNICIPIOS', 'CATALOGO'),
    (v_guia_les, 30, 'localidadOcurrencia', 'Localidad de ocurrencia', 'texto', 4, TRUE, FALSE, 'LOCALIDADES', 'CATALOGO'),
    (v_guia_les, 31, 'otraLocalidad', 'Especificación de la localidad', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 32, 'codigoPostal', 'Código Postal de ocurrencia', 'texto', 5, TRUE, FALSE, 'CODIGO_POSTAL', 'CATALOGO'),
    (v_guia_les, 33, 'tipoVialidad', 'Clasificación de vialidad', 'numerico', 2, TRUE, FALSE, 'TIPO_VIALIDAD', 'CATALOGO'),
    (v_guia_les, 34, 'nombreVialidad', 'Nombre de la vialidad', 'texto', 100, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 35, 'numeroExterior', 'Número exterior', 'texto', 15, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 36, 'tipoAsentamiento', 'Tipo de asentamiento', 'numerico', 2, TRUE, FALSE, 'TIPO_ASENTAMIENTO', 'CATALOGO'),
    (v_guia_les, 37, 'nombreAsentamiento', 'Nombre del asentamiento', 'texto', 100, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 38, 'atencionPreHospitalaria', 'Atención prehospitalaria', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 39, 'tiempoTrasladoUH', 'Tiempo transcurrido en traslado', 'texto', 5, FALSE, FALSE, NULL, 'FORMATO'),
    (v_guia_les, 40, 'sospechaBajoEfectosDe', '¿Bajo efecto de alcohol o droga?', 'texto', 5, TRUE, FALSE, 'LES_SUSTANCIAS', 'ARREGLO'),
    (v_guia_les, 41, 'intencionalidad', 'Intencionalidad del evento', 'numerico', 2, TRUE, FALSE, 'LES_INTENCIONALIDAD', 'CATALOGO'),
    (v_guia_les, 42, 'eventoRepetido', 'Identificación de evento repetido', 'numerico', 1, TRUE, FALSE, 'LES_EVENTO_REPETIDO', 'CATALOGO'),
    (v_guia_les, 43, 'agenteLesion', 'Agente que produjo la lesión', 'numerico', 3, TRUE, FALSE, 'AGENTE_LESION', 'CATALOGO'),
    (v_guia_les, 44, 'especifique', 'Especifique el agente causal', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 45, 'lesionadoVehiculoMotor', 'Lesionado vehículo motor', 'numerico', 1, FALSE, FALSE, 'LES_LESIONADO_VEHICULO', 'CATALOGO'),
    (v_guia_les, 46, 'usoEquipoSeguridad', 'Uso equipo de seguridad', 'numerico', 1, FALSE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 47, 'equipoUtilizado', 'Equipo utilizado', 'numerico', 1, FALSE, FALSE, 'LES_EQUIPO_UTILIZADO', 'CATALOGO'),
    (v_guia_les, 48, 'especifiqueEquipo', 'Especifique otro equipo', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Variables 49 al 82 (Violencia, Clínica, CIE10, Referencia, Responsable)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_les, 49, 'tipoViolencia', 'Tipo de violencia', 'texto', 15, FALSE, FALSE, 'LES_TIPO_VIOLENCIA', 'ARREGLO'),
    (v_guia_les, 50, 'numeroAgresores', 'Número de agresores', 'numerico', 1, FALSE, FALSE, 'LES_NUMERO_AGRESORES', 'CATALOGO'),
    (v_guia_les, 51, 'parentescoAfectado', 'Parentesco del agresor', 'numerico', 2, FALSE, FALSE, 'LES_PARENTESCO', 'CATALOGO'),
    (v_guia_les, 52, 'sexoAgresor', 'Sexo del agresor', 'numerico', 1, FALSE, FALSE, 'SEXO', 'CATALOGO'),
    (v_guia_les, 53, 'edadAgresor', 'Edad del agresor', 'numerico', 3, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_les, 54, 'agresorBajoEfectos', 'Agresor bajo efectos de sustancia', 'texto', 5, FALSE, FALSE, 'LES_SUSTANCIAS', 'ARREGLO'),
    (v_guia_les, 55, 'fechaAtencion', 'Fecha de la atención', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_les, 56, 'horaAtencion', 'Hora de la atención', 'texto', 5, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_les, 57, 'servicioAtencion', 'Servicio que otorgo la atención', 'numerico', 1, TRUE, FALSE, 'LES_SERVICIO_ATENCION', 'CATALOGO'),
    (v_guia_les, 58, 'especifiqueServicio', 'Especifique servicio', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 59, 'tipoAtencion', 'Tipo de atención', 'texto', 20, TRUE, FALSE, 'LES_TIPO_ATENCION', 'ARREGLO'),
    (v_guia_les, 60, 'areaAnatomica', 'Área anatómica de mayor gravedad', 'numerico', 2, TRUE, FALSE, 'AREA_ANATOMICA', 'CATALOGO'),
    (v_guia_les, 61, 'especifiqueArea', 'Otra área anatómica', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 62, 'consecuenciaGravedad', 'Consecuencia resultante', 'numerico', 2, TRUE, FALSE, 'CONSECUENCIA_LESION', 'CATALOGO'),
    (v_guia_les, 63, 'especifiqueConsecuencia', 'Otro tipo de consecuencia', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 64, 'descripcionAfeccionPrincipal', 'Descripción de afección principal', 'texto', 250, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 65, 'codigoCIEAfeccionPrincipal', 'Código CIE Afección principal', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_les, 66, 'numeroAfeccion', 'Número de afección', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_les, 67, 'descripcionAfeccion', 'Descripción de afección tratada', 'texto', 250, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 68, 'codigoCIEAfeccion', 'CIE Afección tratada', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'ARREGLO'),
    (v_guia_les, 69, 'afeccionPrincipalReseleccionada', 'CIE principal reseleccionada', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_les, 70, 'causaExterna', 'Descripción causa externa', 'texto', 250, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 71, 'codigoCIECausaExterna', 'Código CIE Causa Externa', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_les, 72, 'despuesAtencion', 'Destino después de atención', 'numerico', 2, TRUE, FALSE, 'LES_DESPUES_ATENCION', 'CATALOGO'),
    (v_guia_les, 73, 'especifiqueDestino', 'Especifica destino', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 74, 'ministerioPublico', 'Dio aviso al MP', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_les, 75, 'folioCertificadoDefuncion', 'Folio Certificado de defunción', 'numerico', 9, FALSE, FALSE, NULL, 'FORMATO'),
    (v_guia_les, 76, 'responsableAtencion', 'Responsable de atención', 'numerico', 1, TRUE, FALSE, 'LES_RESPONSABLE', 'CATALOGO'),
    (v_guia_les, 77, 'paisNacimiento', 'País nacimiento prestador', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_les, 78, 'curpResponsable', 'CURP responsable', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_les, 79, 'nombreResponsable', 'Nombre responsable', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 80, 'primerApellidoResponsable', 'Primer apellido responsable', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 81, 'segundoApellidoResponsable', 'Segundo apellido responsable', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_les, 82, 'cedulaResponsable', 'Cédula profesional', 'texto', 14, TRUE, FALSE, NULL, 'TEXTO_LIBRE')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- 4. REGLAS LÓGICAS Y RESTRICCIONES (Motor Front-End)
    
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_les, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='horaEvento' AND normatividad_id=v_guia_les), 
     'FORMATO_HORA', 'REGEX', '{"operador": "match", "patron": "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"}'::jsonb, 
     'La hora debe tener un formato válido (HH:MM).', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_les, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='fechaEvento' AND normatividad_id=v_guia_les), 
     'LOGICA_FECHA_EVENTO', 'COMPARACION_CAMPOS', '{"operador": "less_than_or_equal", "campo1": "fechaEvento", "campo2": "fechaAtencion"}'::jsonb, 
     'La fecha del evento no puede ser posterior a la fecha de atención.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_les, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='tipoViolencia' AND normatividad_id=v_guia_les), 
     'REQ_TIPO_VIOLENCIA', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "intencionalidad", "in": ["2", "3"]}, "accion": {"requerido": "tipoViolencia"}}'::jsonb, 
     'Si la lesión fue por violencia, especificar el tipo de violencia es obligatorio.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_les, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='numeroAgresores' AND normatividad_id=v_guia_les), 
     'REQ_AGRESORES', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "intencionalidad", "in": ["2", "3"]}, "accion": {"requerido": "numeroAgresores"}}'::jsonb, 
     'En casos de violencia, se debe especificar el número de agresores.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_les, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='parentescoAfectado' AND normatividad_id=v_guia_les), 
     'REQ_PARENTESCO', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "numeroAgresores", "valor": "1"}, "accion": {"requerido": "parentescoAfectado"}}'::jsonb, 
     'Si el agresor es ÚNICO, especificar el parentesco es obligatorio.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_les, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='lesionadoVehiculoMotor' AND normatividad_id=v_guia_les), 
     'REQ_VEHICULO_MOTOR', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "agenteLesion", "valor": "20"}, "accion": {"requerido": "lesionadoVehiculoMotor"}}'::jsonb, 
     'Si el agente de lesión es VEHÍCULO DE MOTOR, debe especificar la condición del lesionado (Conductor/Ocupante/Peatón).', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_les, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='folioCertificadoDefuncion' AND normatividad_id=v_guia_les), 
     'REQ_CERT_DEFUNCION', 'LOGICA_COMPLEJA', '{"operador": "if_then", "condicion": {"and": [{"campo": "despuesAtencion", "valor": "5"}, {"campo": "ministerioPublico", "valor": "2"}]}, "accion": {"requerido": "folioCertificadoDefuncion"}}'::jsonb, 
     'Si el destino es Defunción y NO se dio aviso al MP, registrar el folio de certificado de defunción es obligatorio.', 'ERROR', v_fecha);

END $$;