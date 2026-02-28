-- =========================================================================
-- CARGA EXHAUSTIVA AL 100% - GUÍA 3: URGENCIAS MÉDICAS (GIIS-B014-02-03)
-- (Revisado y apegado milimétricamente al PDF Oficial - 64 Variables)
-- =========================================================================

DO $$
DECLARE
    v_guia_urg INT;
    v_fecha DATE := '2022-03-15';
    v_dic_id INT;
BEGIN

    -- 1. ASEGURAR QUE LA GUÍA EXISTE EN EL CATÁLOGO MAESTRO
    INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus) 
    VALUES ('GIIS-B014-02-03', 'Urgencias Médicas', '2.3', v_fecha, 'ACTIVO')
    ON CONFLICT (clave) DO UPDATE SET version = EXCLUDED.version;

    SELECT id INTO v_guia_urg FROM public.sys_normatividad_giis WHERE clave = 'GIIS-B014-02-03';

    -- 2. INYECCIÓN DE MINICATÁLOGOS EXACTOS DEL PDF
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('URG_TIPO_URGENCIA', 'Tipo de Urgencia', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'URG_TIPO_URGENCIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'URGENCIA CALIFICADA', 1), (v_dic_id, '2', 'URGENCIA NO CALIFICADA', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('URG_MOTIVO_ATENCION', 'Motivo de Atención en Urgencias', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'URG_MOTIVO_ATENCION';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'ACCIDENTES, ENVENENAMIENTO Y VIOLENCIAS', 1), (v_dic_id, '2', 'MEDICA', 2), (v_dic_id, '3', 'GINECO-OBSTETRICA', 3), (v_dic_id, '4', 'PEDIATRICA', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('URG_TIPO_CAMA', 'Tipo de Cama', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'URG_TIPO_CAMA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'CAMA DE OBSERVACION', 1), (v_dic_id, '2', 'CAMA DE CHOQUE', 2), (v_dic_id, '3', 'SIN CAMA', 3), (v_dic_id, '9', 'NO ESPECIFICADO', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('URG_ALTA_POR', 'Motivo de Alta de Urgencias', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'URG_ALTA_POR';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'HOSPITALIZACION', 1), (v_dic_id, '2', 'CONSULTA EXTERNA', 2), (v_dic_id, '3', 'TRASLADO A OTRA UNIDAD', 3), (v_dic_id, '4', 'DOMICILIO', 4), (v_dic_id, '5', 'DEFUNCION', 5), (v_dic_id, '6', 'FUGA', 6), (v_dic_id, '7', 'VOLUNTAD PROPIA', 7) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('URG_PLAN_IRAS', 'Plan Infecciones Respiratorias Agudas', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'URG_PLAN_IRAS';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'SINTOMATICO', 1), (v_dic_id, '2', 'ANTIBIOTICO', 2), (v_dic_id, '3', 'ANTIVIRALES', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('URG_PLAN_EDAS', 'Plan Enfermedades Diarreicas Agudas', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'URG_PLAN_EDAS';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'PLAN A', 1), (v_dic_id, '2', 'PLAN B', 2), (v_dic_id, '3', 'PLAN C', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('SIS_OPCION_SINO', 'Opciones Si / No', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'SIS_OPCION_SINO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'SI', 1), (v_dic_id, '2', 'NO', 2), (v_dic_id, '8', 'SE IGNORA', 3), (v_dic_id, '9', 'NO ESPECIFICADO', 4) ON CONFLICT DO NOTHING;


    -- 3. CARGA DE LAS 64 VARIABLES EXACTAS DEL PDF (En bloques para evitar cortes)
    
    -- Variables 1 al 20 (Identificación, Demografía y Domicilio)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_urg, 1, 'clues', 'Clave Única de Establecimientos en Salud', 'texto', 11, TRUE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_urg, 2, 'folio', 'Clave asignada por la Unidad Médica', 'texto', 8, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 3, 'curpPaciente', 'Clave Única de Registro de Población del paciente', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_urg, 4, 'nombre', 'Nombre(s) del Paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 5, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 6, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 7, 'fechaNacimiento', 'Fecha de nacimiento del paciente', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_urg, 8, 'paisOrigen', 'Identifica el país de nacimiento del paciente', 'texto', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_urg, 9, 'entidadNacimiento', 'Entidad federativa de nacimiento del paciente', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_urg, 10, 'sexo', 'Registre el sexo del paciente', 'numerico', 1, TRUE, FALSE, 'SEXO', 'CATALOGO'),
    (v_guia_urg, 11, 'derechohabiencia', 'Institución del SNS en la cual se encuentran afiliados', 'numerico', 2, TRUE, FALSE, 'AFILIACION', 'CATALOGO'),
    (v_guia_urg, 12, 'gratuidad', 'Programa de Salud de la Ciudad de México', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_urg, 13, 'seConsideraIndigena', '¿Se considera Indígena?', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_urg, 14, 'seConsideraAfromexicano', '¿Se considera Afromexicano?', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_urg, 15, 'paisResidencia', 'Identifica el país de residencia del paciente', 'texto', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_urg, 16, 'entidadResidencia', 'Entidad de residencia del paciente', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_urg, 17, 'municipioResidencia', 'Municipio o delegación de residencia', 'texto', 3, TRUE, FALSE, 'MUNICIPIOS', 'CATALOGO'),
    (v_guia_urg, 18, 'localidadResidencia', 'Localidad de residencia del paciente', 'texto', 4, TRUE, FALSE, 'LOCALIDADES', 'CATALOGO'),
    (v_guia_urg, 19, 'otraLocalidad', 'Especificación del nombre de la localidad', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 20, 'codigoPostal', 'Código Postal del lugar de residencia', 'texto', 5, TRUE, FALSE, 'CODIGO_POSTAL', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Variables 21 al 43 (Estancia, Diagnósticos)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_urg, 21, 'atencionPreHospitalaria', 'Atención prehospitalaria al paciente', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_urg, 22, 'tiempoTraslado', 'Tiempo transcurrido en traslado', 'texto', 5, FALSE, FALSE, NULL, 'FORMATO'),
    (v_guia_urg, 23, 'fechaIngreso', 'Fecha de ingreso correspondiente', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_urg, 24, 'horaIngreso', 'Hora en que ingreso el paciente', 'texto', 5, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_urg, 25, 'tipoUrgencia', 'Tipo de urgencia', 'numerico', 1, TRUE, FALSE, 'URG_TIPO_URGENCIA', 'CATALOGO'),
    (v_guia_urg, 26, 'motivoAtencion', 'Motivo de la atención proporcionada', 'numerico', 1, TRUE, FALSE, 'URG_MOTIVO_ATENCION', 'CATALOGO'),
    (v_guia_urg, 27, 'tipoCama', 'Tipo de cama en la que se encuentra el paciente', 'numerico', 1, TRUE, FALSE, 'URG_TIPO_CAMA', 'CATALOGO'),
    (v_guia_urg, 28, 'trasladoTransitorio', 'Traslado transitorio a otro hospital', 'numerico', 1, TRUE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_urg, 29, 'cluesTraslado', 'CLUES de la unidad médica de traslado', 'texto', 11, FALSE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_urg, 30, 'fechaAlta', 'Fecha de alta del paciente', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_urg, 31, 'horaAlta', 'Hora del alta del paciente', 'texto', 5, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_urg, 32, 'altaPor', 'Motivo de alta del servicio de urgencias', 'numerico', 1, TRUE, FALSE, 'URG_ALTA_POR', 'CATALOGO'),
    (v_guia_urg, 33, 'cluesReferido', 'CLUES de la unidad a la cual es referido el paciente', 'texto', 11, FALSE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_urg, 34, 'ministerioPublico', 'Envió al Ministerio Publico el Certificado', 'numerico', 1, FALSE, FALSE, 'SIS_OPCION_SINO', 'CATALOGO'),
    (v_guia_urg, 35, 'folioCertificadoDefuncion', 'Folio del certificado de defunción', 'numerico', 9, FALSE, FALSE, NULL, 'FORMATO'),
    (v_guia_urg, 36, 'mujerFertil', 'Mujer embarazada o puérpera', 'numerico', 1, FALSE, FALSE, 'HOSP_MUJER_FERTIL', 'CATALOGO'),
    (v_guia_urg, 37, 'edadGestacional', 'Semanas de gestación', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_urg, 38, 'descripcionAfeccionPrincipal', 'Descripción de la afección principal', 'texto', 250, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 39, 'codigoCIEAfeccionPrincipal', 'Código CIE Afección principal', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_urg, 40, 'numeroComorbilidad', 'Número consecutivo de la comorbilidad', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_urg, 41, 'descripcionComorbilidad', 'Descripción de comorbilidad tratada', 'texto', 250, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 42, 'codigoCieComorbilidad', 'Código CIE comorbilidad', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'ARREGLO'),
    (v_guia_urg, 43, 'afeccionPrincipalReseleccionada', 'Código CIE afección principal reseleccionada', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Variables 44 al 64 (Interconsultas, Procedimientos, Medicamentos y Médico)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_urg, 44, 'tipoEspecialidad', 'Tipo de especialidad interconsultante', 'numerico', 3, FALSE, FALSE, 'ESPECIALIDADES', 'ARREGLO'),
    (v_guia_urg, 45, 'especifiqueEspecialidad', 'Especifique otra especialidad', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 46, 'paisNacimientoEspecialista', 'País de nacimiento del especialista', 'numerico', 3, FALSE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_urg, 47, 'curpEspecialista', 'CURP del médico especialista', 'texto', 18, FALSE, TRUE, NULL, 'FORMATO'),
    (v_guia_urg, 48, 'nombreMedico', 'Nombre del Médico Especialista', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 49, 'primerApellidoMedico', 'Primer Apellido del Especialista', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 50, 'segundoApellidoMedico', 'Segundo Apellido del Especialista', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 51, 'cedulaEsp', 'Cédula Profesional del Médico Especialista', 'texto', 14, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 52, 'numeroProcedimiento', 'Número de procedimiento utilizado', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_urg, 53, 'codigoCieProcedimiento', 'Código CIE-9MC del procedimiento', 'texto', 4, FALSE, FALSE, 'PROCEDIMIENTO', 'ARREGLO'),
    (v_guia_urg, 54, 'numeroMedicamento', 'Número consecutivo de medicamentos', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_urg, 55, 'codigoMedicamento', 'Código del medicamento', 'texto', 20, FALSE, FALSE, 'MEDICAMENTOS', 'ARREGLO'),
    (v_guia_urg, 56, 'planIras', 'Plan Infecciones respiratorias', 'numerico', 1, FALSE, FALSE, 'URG_PLAN_IRAS', 'CATALOGO'),
    (v_guia_urg, 57, 'planEdas', 'Plan enfermedades diarreicas', 'numerico', 1, FALSE, FALSE, 'URG_PLAN_EDAS', 'CATALOGO'),
    (v_guia_urg, 58, 'numeroSobres', 'Número de sobres de vida suero oral', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_urg, 59, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_urg, 60, 'curpResponsable', 'Clave Única de Registro del profesional', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_urg, 61, 'nombreResponsable', 'Nombre del profesional responsable', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 62, 'primerApellidoResponsable', 'Primer apellido del responsable', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 63, 'segundoApellidoResponsable', 'Segundo apellido del responsable', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_urg, 64, 'cedulaResponsable', 'Cédula profesional del responsable', 'texto', 14, TRUE, TRUE, NULL, 'TEXTO_LIBRE')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- 4. REGLAS LÓGICAS Y RESTRICCIONES EXTRAÍDAS DEL DICCIONARIO DEL PDF
    
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_urg, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='cluesTraslado' AND normatividad_id=v_guia_urg), 
     'REQ_CLUES_TRASLADO', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "trasladoTransitorio", "valor": "1"}, "accion": {"requerido": "cluesTraslado"}}'::jsonb, 
     'Si hay traslado transitorio, la CLUES de la unidad receptora es obligatoria.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_urg, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='cluesReferido' AND normatividad_id=v_guia_urg), 
     'REQ_CLUES_REFERENCIA', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "altaPor", "valor": "3"}, "accion": {"requerido": "cluesReferido"}}'::jsonb, 
     'Si el alta es por Traslado a Otra Unidad, la CLUES de destino es obligatoria.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_urg, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='folioCertificadoDefuncion' AND normatividad_id=v_guia_urg), 
     'REQ_CERTIFICADO_DEFUNCION', 'LOGICA_COMPLEJA', '{"operador": "if_then", "condicion": {"and": [{"campo": "altaPor", "valor": "5"}, {"campo": "ministerioPublico", "valor": "2"}]}, "accion": {"requerido": "folioCertificadoDefuncion"}}'::jsonb, 
     'Si el alta es por Defunción y NO se envió al Ministerio Público, el Folio del Certificado de Defunción es obligatorio.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_urg, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='fechaAlta' AND normatividad_id=v_guia_urg), 
     'LOGICA_FECHAS_URGENCIA', 'COMPARACION_CAMPOS', '{"operador": "greater_than_or_equal", "campo1": "fechaAlta", "campo2": "fechaIngreso"}'::jsonb, 
     'La fecha de alta de urgencias no puede ser anterior a la fecha de ingreso.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_urg, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='horaIngreso' AND normatividad_id=v_guia_urg), 
     'FORMATO_HORA_INGRESO', 'REGEX', '{"operador": "match", "patron": "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"}'::jsonb, 
     'La hora de ingreso debe tener un formato válido de 24 horas (HH:MM).', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_urg, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='edadGestacional' AND normatividad_id=v_guia_urg), 
     'REQ_EDAD_GESTACIONAL', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "mujerFertil", "valor": "1"}, "accion": {"requerido": "edadGestacional"}}'::jsonb, 
     'Si la mujer está embarazada, el registro de semanas de gestación es obligatorio.', 'ERROR', v_fecha);

END $$;