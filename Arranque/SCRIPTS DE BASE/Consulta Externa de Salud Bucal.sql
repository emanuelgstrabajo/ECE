-- =========================================================================
-- CARGA EXHAUSTIVA AL 100% - GUÍA 5: CONSULTA EXTERNA DE SALUD BUCAL
-- Guía GIIS-B016-04-08 (77 Variables Oficiales - Versión Nov 2024)
-- =========================================================================

DO $$
DECLARE
    v_guia_buc INT;
    v_fecha DATE := '2024-11-01';
    v_dic_id INT;
BEGIN

    -- 1. ASEGURAR QUE LA GUÍA EXISTE EN EL CATÁLOGO MAESTRO
    INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus) 
    VALUES ('GIIS-B016-04-08', 'Consulta Externa de Salud Bucal', '4.8', v_fecha, 'ACTIVO')
    ON CONFLICT (clave) DO UPDATE SET version = EXCLUDED.version;

    SELECT id INTO v_guia_buc FROM public.sys_normatividad_giis WHERE clave = 'GIIS-B016-04-08';

    -- 2. INYECCIÓN DE MINICATÁLOGOS ESPECÍFICOS DE SALUD BUCAL (Basados en PDF)
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_TIPO_PERSONAL', 'Tipo de Personal Odontológico', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_TIPO_PERSONAL';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '12', 'PASANTE EN ODONTOLOGIA', 1), (v_dic_id, '13', 'ODONTOLOGA (O)', 2), (v_dic_id, '14', 'ODONTOLOGA (O) ESPECIALISTA', 3), (v_dic_id, '23', 'TECNICA(O) EN ODONTOLOGIA', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_SEXO_CURP', 'Sexo CURP', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_SEXO_CURP';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'HOMBRE', 1), (v_dic_id, '2', 'MUJER', 2), (v_dic_id, '3', 'NO BINARIO', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_SEXO_BIO', 'Sexo Biológico', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_SEXO_BIO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'HOMBRE', 1), (v_dic_id, '2', 'MUJER', 2), (v_dic_id, '3', 'INTERSEXUAL', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_AFRO_INDIGENA', 'Autodenominación Indígena / Afromexicano', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_AFRO_INDIGENA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'SI', 2), (v_dic_id, '2', 'NO RESPONDE', 3), (v_dic_id, '3', 'NO SABE', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_MIGRANTE', 'Condición Migrante', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_MIGRANTE';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'NACIONAL', 2), (v_dic_id, '2', 'INTERNACIONAL', 3), (v_dic_id, '3', 'RETORNADO (Sólo nacional)', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_GENERO', 'Identidad de Género', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_GENERO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO ESPECIFICADO', 1), (v_dic_id, '1', 'MASCULINO', 2), (v_dic_id, '2', 'FEMENINO', 3), (v_dic_id, '3', 'TRANSGENERO', 4), (v_dic_id, '4', 'TRANSEXUAL', 5), (v_dic_id, '5', 'TRAVESTI', 6), (v_dic_id, '6', 'INTERSEXUAL', 7), (v_dic_id, '88', 'OTRO', 8) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_SINO_CERO_UNO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'SI', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_RELACION_TEMP', 'Relación Temporal', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_RELACION_TEMP';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'PRIMERA VEZ', 1), (v_dic_id, '1', 'SUBSECUENTE', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_TELECONSULTA_ESTUDIOS', 'Estudios de Teleconsulta', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_TELECONSULTA_ESTUDIOS';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'USG', 1), (v_dic_id, '2', 'ECG', 2), (v_dic_id, '3', 'RAYOS X', 3), (v_dic_id, '4', 'TOMOGRAFIA', 4), (v_dic_id, '5', 'RESONANCIA MAGNETICA', 5), (v_dic_id, '6', 'MASTOGRAFIA', 6), (v_dic_id, '7', 'OTROS', 7) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('BUC_MODALIDAD_TELE', 'Modalidad Teleconsulta', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'BUC_MODALIDAD_TELE';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'EN TIEMPO REAL', 1), (v_dic_id, '2', 'DIFERIDA', 2) ON CONFLICT DO NOTHING;


    -- 3. CARGA DE LAS 77 VARIABLES EXACTAS DEL PDF (En bloques para evitar cortes)
    
    -- Variables 1 al 25 (Unidad, Prestador, Paciente y Demografía)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_buc, 1, 'clues', 'Clave Única de Establecimiento', 'texto', 11, TRUE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_buc, 2, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_buc, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_buc, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_buc, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_buc, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_buc, 7, 'tipoPersonal', 'Tipo de profesional de la salud', 'numerico', 2, TRUE, FALSE, 'BUC_TIPO_PERSONAL', 'CATALOGO'),
    (v_guia_buc, 8, 'programaSMYMG', 'Contratado para Prog. U013', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_buc, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_buc, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_buc, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_buc, 13, 'fechaNacimiento', 'Fecha de nacimiento del paciente', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_buc, 14, 'paisNacPaciente', 'País de nacimiento del paciente', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_buc, 15, 'entidadNacimiento', 'Entidad de nacimiento del paciente', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_buc, 16, 'sexoCURP', 'Sexo registrado ante RENAPO', 'numerico', 1, TRUE, FALSE, 'BUC_SEXO_CURP', 'CATALOGO'),
    (v_guia_buc, 17, 'sexoBiologico', 'Sexo biológico/fisiológico', 'numerico', 1, TRUE, FALSE, 'BUC_SEXO_BIO', 'CATALOGO'),
    (v_guia_buc, 18, 'seAutodenominaAfromexicano', 'Autodenominación Afromexicano', 'numerico', 1, TRUE, FALSE, 'BUC_AFRO_INDIGENA', 'CATALOGO'),
    (v_guia_buc, 19, 'seConsideraIndigena', 'Identifica si se considera indígena', 'numerico', 1, TRUE, FALSE, 'BUC_AFRO_INDIGENA', 'CATALOGO'),
    (v_guia_buc, 20, 'migrante', 'Identifica si es migrante', 'numerico', 1, TRUE, FALSE, 'BUC_MIGRANTE', 'CATALOGO'),
    (v_guia_buc, 21, 'paisProcedencia', 'País de procedencia (Migrante)', 'numerico', 3, FALSE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_buc, 22, 'genero', 'Identidad de género', 'numerico', 2, TRUE, FALSE, 'BUC_GENERO', 'CATALOGO'),
    (v_guia_buc, 23, 'derechohabiencia', 'Afiliación(es) del SNS', 'texto', 20, TRUE, FALSE, 'AFILIACION', 'ARREGLO'),
    (v_guia_buc, 24, 'fechaConsulta', 'Fecha de la consulta', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_buc, 25, 'servicioAtencion', 'Tipo de servicio otorgado', 'numerico', 2, TRUE, FALSE, 'ESPECIALIDADES', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Variables 26 al 50 (Somatometría, CIE10 y Prevención)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_buc, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 27, 'talla', 'Talla del paciente (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 28, 'circunferenciaCintura', 'Circunferencia de cintura (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 29, 'sistolica', 'Presión arterial sistólica (mm/Hg)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 30, 'diastolica', 'Presión arterial diastólica (mm/Hg)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 33, 'temperatura', 'Temperatura corporal (C)', 'numerico', 4, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 34, 'saturacionOxigeno', 'Saturación de oxígeno (SpO2)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 35, 'glucemia', 'Glucosa en sangre mg/dl', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 36, 'tipoMedicion', 'Medición de glucosa en ayunas', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 37, 'primeraVezAnio', 'Primera consulta en el año (cobertura)', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 38, 'relacionTemporal', 'Relación temporal por motivo', 'numerico', 1, TRUE, FALSE, 'BUC_RELACION_TEMP', 'CATALOGO'),
    (v_guia_buc, 39, 'codigoCIEDiagnostico1', 'Código CIE del diagnóstico 1', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_buc, 40, 'primeraVezDiagnostico2', 'Primera vez del diagnóstico 2', 'numerico', 1, FALSE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 41, 'codigoCIEDiagnostico2', 'Código CIE del diagnóstico 2', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_buc, 42, 'primeraVezDiagnostico3', 'Primera vez del diagnóstico 3', 'numerico', 1, FALSE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 43, 'codigoCIEDiagnostico3', 'Código CIE del diagnóstico 3', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_buc, 44, 'placaBacteriana', 'Detección de placa bacteriana', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 45, 'cepillado', 'Instrucción en Técnica de Cepillado', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 46, 'hiloDental', 'Instrucción de uso de Hilo Dental', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 47, 'limpiezaDental', 'Realización de limpieza dental', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 48, 'protesis', 'Revisión/Higiene de prótesis bucales', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 49, 'tejidosBucales', 'Examen de tejidos bucales', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 50, 'autoExamen', 'Autoexamen de cavidad bucal', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Variables 51 al 77 (Actividades Odontológicas, Curativas y Referencias)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_buc, 51, 'fluor', 'Aplicación tópica de Flúor', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 52, 'raspadoAlisadoPeriodontal', 'Raspado y alisado periodontal', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 53, 'barnizFluor', 'Aplicación de Barniz de Flúor', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 54, 'fosetasFisuras', 'Fosetas y fisuras selladas', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 55, 'amalgamas', 'Obturaciones con amalgamas', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 56, 'resinas', 'Obturaciones con resinas', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 57, 'ionomeroVidrio', 'Obturaciones con Ionómero de vidrio', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 58, 'alcasite', 'Obturaciones con alcasite', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 59, 'obturacionTemporal', 'Obturaciones temporales', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 60, 'dienteTemp', 'Extracciones de dientes temporales', 'numerico', 1, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 61, 'dientePerm', 'Extracciones de dientes permanentes', 'numerico', 1, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 62, 'pulpar', 'Piezas tratadas con terapia pulpar', 'numerico', 1, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 63, 'cirugiaBucal', 'Actividad quirúrgica menor', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 64, 'farmacoTerapia', 'Prescripción de fármacos', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 65, 'otrasAtenciones', 'Atenciones adicionales', 'numerico', 1, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 66, 'radiografias', 'Radiografías dentales tomadas', 'numerico', 1, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_buc, 67, 'orientacionSaludBucal', 'Orientación de Salud Bucal', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 68, 'tratamientoIntegral', 'Conclusión integral del tratamiento', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 69, 'lineaVida', 'Programa Línea de Vida', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 70, 'cartillaSalud', 'Presenta cartilla de salud', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 71, 'esquemaVacunacion', 'Esquema de vacunación completo', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 72, 'referidoPor', 'Motivo de referencia', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_buc, 73, 'contrarreferido', 'Paciente contrarreferido', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 74, 'telemedicina', 'Solicita telemedicina', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 75, 'teleconsulta', 'Consulta a distancia', 'numerico', 1, TRUE, FALSE, 'BUC_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_buc, 76, 'estudiosTeleconsulta', 'Estudios valorados a distancia', 'texto', 15, FALSE, FALSE, 'BUC_TELECONSULTA_ESTUDIOS', 'ARREGLO'),
    (v_guia_buc, 77, 'modalidadConsulDist', 'Modalidad de teleconsulta', 'numerico', 1, FALSE, FALSE, 'BUC_MODALIDAD_TELE', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- 4. REGLAS LÓGICAS Y RESTRICCIONES (Motor Front-End)
    
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_buc, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='peso' AND normatividad_id=v_guia_buc), 
     'LIMITE_PESO', 'RANGO_VALOR', '{"operador": "between", "min": 1, "max": 400}'::jsonb, 
     'El peso debe estar entre 1 y 400 kg.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_buc, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='sistolica' AND normatividad_id=v_guia_buc), 
     'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"operador": "greater_than_or_equal", "campo1": "sistolica", "campo2": "diastolica"}'::jsonb, 
     'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_buc, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='hiloDental' AND normatividad_id=v_guia_buc), 
     'REQ_HILODENTAL_EDAD', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "edadCalculada", "less_than": 6}, "accion": {"requerido_valor": "-1"}}'::jsonb, 
     'La instrucción de hilo dental no aplica (debe ser -1) para menores de 6 años.', 'ERROR', v_fecha);

    -- Regla extraída de la Fe de Erratas (Pág 30 del PDF)
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_buc, NULL, 
     'ERRATA_ACCIONES_BUCALES_MINIMAS', 'LOGICA_COMPLEJA', '{"operador": "al_menos_uno_diferente_cero", "campos": ["placaBacteriana", "cepillado", "limpiezaDental", "protesis", "tejidosBucales", "autoExamen", "fluor", "raspadoAlisadoPeriodontal", "barnizFluor"], "condicion_hilo_dental": "!= 0 y != -1"}'::jsonb, 
     'De acuerdo a la Fe de Erratas (18/04/2024), se debe validar que al menos una de las acciones realizadas tenga un valor diferente de 0. Para hiloDental, diferente de 0 y -1.', 'ERROR', v_fecha);

END $$;