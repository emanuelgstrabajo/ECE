-- =========================================================================
-- CARGA EXHAUSTIVA AL 100% - GUÍA 6: CONSULTA EXTERNA SALUD MENTAL 
-- Guía GIIS-B017-04-09 (85 Variables Oficiales - Versión Nov 2024)
-- =========================================================================

DO $$
DECLARE
    v_guia_men INT;
    v_fecha DATE := '2024-11-01';
    v_dic_id INT;
BEGIN

    -- 1. ASEGURAR QUE LA GUÍA EXISTE EN EL CATÁLOGO MAESTRO
    INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus) 
    VALUES ('GIIS-B017-04-09', 'Consulta Externa de Salud Mental', '4.9', v_fecha, 'ACTIVO')
    ON CONFLICT (clave) DO UPDATE SET version = EXCLUDED.version;

    SELECT id INTO v_guia_men FROM public.sys_normatividad_giis WHERE clave = 'GIIS-B017-04-09';

    -- 2. INYECCIÓN DE MINICATÁLOGOS ESPECÍFICOS DE SALUD MENTAL
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_TIPO_PERSONAL', 'Tipo de Personal Salud Mental', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_TIPO_PERSONAL';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '15', 'PASANTE DE PSICOLOGÍA', 1), (v_dic_id, '16', 'PSICÓLOGA (O)', 2), (v_dic_id, '17', 'RESIDENTE DE PSIQUIATRÍA', 3), (v_dic_id, '18', 'PSIQUIATRA', 4), (v_dic_id, '19', 'MÉDICA(O) GENERAL HABILITADO PARA SALUD MENTAL', 5), (v_dic_id, '24', 'MÉDICA(O) ESPECIALISTA HABILITADO PARA SALUD MENTAL', 6), (v_dic_id, '25', 'LICENCIADA(O) EN GERONTOLOGÍA', 7), (v_dic_id, '27', 'PASANTE EN GERONTOLOGÍA', 8) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_SINO_CERO_UNO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'SI', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_SUSTANCIAS', 'Sustancias de Consumo', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_SUSTANCIAS';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'ALCOHOL', 1), (v_dic_id, '2', 'TABACO', 2), (v_dic_id, '3', 'CANNABIS', 3), (v_dic_id, '4', 'COCAINA', 4), (v_dic_id, '5', 'METANFETAMINAS', 5), (v_dic_id, '6', 'INHALABLES', 6), (v_dic_id, '7', 'OPIACEOS', 7), (v_dic_id, '8', 'ALUCINOGENOS', 8), (v_dic_id, '9', 'BENZODIACEPINAS', 9), (v_dic_id, '10', 'OTROS', 10) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_ATENCION_SUSTANCIA', 'Tipo de Atención por Sustancia', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_ATENCION_SUSTANCIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'PRIMARIA', 1), (v_dic_id, '2', 'COMORBILIDAD', 2), (v_dic_id, '3', 'DETECTADO', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_CONSUMO_SUSTANCIA', 'Patrón de Consumo de Sustancia', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_CONSUMO_SUSTANCIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'EPISODIO UNICO DE CONSUMO NOCIVO', 1), (v_dic_id, '2', 'CONSUMO PELIGROSO', 2), (v_dic_id, '3', 'PATRON NOCIVO DE CONSUMO', 3), (v_dic_id, '4', 'DEPENDENCIA', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_AMBITO_VIOLENCIA', 'Ámbito de las Violencias', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_AMBITO_VIOLENCIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'FAMILIAR', 1), (v_dic_id, '2', 'COMUNITARIA', 2), (v_dic_id, '3', 'COLECTIVA', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_TIPO_VIOLENCIA', 'Tipo de Violencia Específica', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_TIPO_VIOLENCIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'VIOLENCIA PSICOLOGICA', 1), (v_dic_id, '2', 'VIOLENCIA FISICA', 2), (v_dic_id, '3', 'VIOLENCIA PATRIMONIAL', 3), (v_dic_id, '4', 'VIOLENCIA ECONOMICA', 4), (v_dic_id, '5', 'VIOLENCIA SEXUAL', 5) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_COMPORTAMIENTO_SUICIDA', 'Comportamiento Suicida', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_COMPORTAMIENTO_SUICIDA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'AUTOLESION SIN RIESGO', 1), (v_dic_id, '2', 'AUTOLESION CON RIESGO', 2), (v_dic_id, '3', 'IDEACION', 3), (v_dic_id, '4', 'INTENTO', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_EVALUACION_PSICOLOGICA', 'Evaluación Psicológica', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_EVALUACION_PSICOLOGICA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'APLICACION DE PRUEBAS', 1), (v_dic_id, '2', 'CALIFICACION DE PRUEBAS', 2), (v_dic_id, '3', 'INTEGRACION DE LA EVALUACION', 3), (v_dic_id, '4', 'ENTREGA DE RESULTADOS', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('MEN_PSICOTERAPIA', 'Tipo de Psicoterapia', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'MEN_PSICOTERAPIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'INDIVIDUAL', 1), (v_dic_id, '2', 'GRUPAL', 2), (v_dic_id, '3', 'PAREJA', 3), (v_dic_id, '4', 'FAMILIAR', 4), (v_dic_id, '5', 'POSTVENCION', 5) ON CONFLICT DO NOTHING;

    -- 3. CARGA DE LAS 85 VARIABLES EXACTAS DEL PDF 
    
    -- Bloque 1: Unidad, Prestador y Paciente (1 al 23)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_men, 1, 'clues', 'Clave Única de Establecimientos', 'texto', 11, TRUE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_men, 2, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_men, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_men, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_men, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_men, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_men, 7, 'tipoPersonal', 'Tipo de profesional de la salud', 'numerico', 2, TRUE, FALSE, 'MEN_TIPO_PERSONAL', 'CATALOGO'),
    (v_guia_men, 8, 'programaSMyMG', 'Programa U013', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_men, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_men, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_men, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_men, 13, 'fechaNacimiento', 'Fecha de nacimiento', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_men, 14, 'paisNacPaciente', 'País de nacimiento del paciente', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_men, 15, 'entidadNacimiento', 'Entidad de nacimiento del paciente', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_men, 16, 'sexoCURP', 'Sexo registrado ante RENAPO', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 17, 'sexoBiologico', 'Sexo biológico/fisiológico', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 18, 'seAutodenominaAfromexicano', 'Afromexicano', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 19, 'seConsideraIndigena', 'Indígena', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 20, 'migrante', 'Migrante', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 21, 'paisProcedencia', 'País de procedencia', 'numerico', 3, FALSE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_men, 22, 'genero', 'Identidad de género', 'numerico', 2, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 23, 'derechohabiencia', 'Afiliación', 'texto', 20, TRUE, FALSE, 'AFILIACION', 'ARREGLO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 2: Somatometría y Diagnósticos (24 al 48)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_men, 24, 'fechaConsulta', 'Fecha de la consulta', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_men, 25, 'servicioAtencion', 'Servicio de atención', 'numerico', 2, TRUE, FALSE, 'ESPECIALIDADES', 'CATALOGO'),
    (v_guia_men, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 27, 'talla', 'Talla (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 28, 'circunferenciaCintura', 'Circunferencia cintura (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 29, 'sistolica', 'Presión arterial sistólica', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 30, 'diastolica', 'Presión arterial diastólica', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 33, 'temperatura', 'Temperatura corporal', 'numerico', 4, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 34, 'saturacionOxigeno', 'SpO2', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 35, 'glucemia', 'Glucosa en sangre', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_men, 36, 'tipoMedicion', 'Glucosa en ayunas', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 37, 'primeraVezAnio', 'Primera consulta en el año', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 38, 'primeraVezUneme', 'Seguimiento en UNEME', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 39, 'relacionTemporal', 'Primera vez o subsecuente', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 40, 'codigoCIEDiagnostico1', 'Diagnóstico principal', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_men, 41, 'primeraVezDiagnostico2', 'Primera vez diag 2', 'numerico', 1, FALSE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 42, 'codigoCIEDiagnostico2', 'Diagnóstico secundario', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_men, 43, 'primeraVezDiagnostico3', 'Primera vez diag 3', 'numerico', 1, FALSE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 44, 'codigoCIEDiagnostico3', 'Tercer diagnóstico', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_men, 45, 'derivacionPreconsulta', 'Derivación de preconsulta', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 46, 'evaluacionPsicologica', 'Evaluación psicológica', 'numerico', 1, FALSE, FALSE, 'MEN_EVALUACION_PSICOLOGICA', 'CATALOGO'),
    (v_guia_men, 47, 'psicoTerapia', 'Tipo de psicoterapia', 'numerico', 1, FALSE, FALSE, 'MEN_PSICOTERAPIA', 'CATALOGO'),
    (v_guia_men, 48, 'psicoEducacion', 'Psicoeducación otorgada', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 3: Sustancias y Violencias (49 al 85)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_men, 49, 'sustanciaDeConsumo', 'Sustancia(s) de consumo', 'texto', 20, TRUE, FALSE, 'MEN_SUSTANCIAS', 'ARREGLO'),
    (v_guia_men, 50, 'tipoAtencionAlcohol', 'Atención por Alcohol', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 51, 'tipoConsumoAlcohol', 'Consumo de Alcohol', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 52, 'tipoAtencionTabaco', 'Atención por Tabaco', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 53, 'tipoConsumoTabaco', 'Consumo de Tabaco', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 54, 'tipoAtencionCannabis', 'Atención por Cannabis', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 55, 'tipoConsumoCannabis', 'Consumo de Cannabis', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 56, 'tipoAtencionCocaina', 'Atención por Cocaína', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 57, 'tipoConsumoCocaina', 'Consumo de Cocaína', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 58, 'tipoAtencionMetanfetaminas', 'Atención Metanfetaminas', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 59, 'tipoConsumoMetanfetaminas', 'Consumo Metanfetaminas', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 60, 'tipoAtencionInhalables', 'Atención Inhalables', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 61, 'tipoConsumoInhalables', 'Consumo Inhalables', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 62, 'tipoAtencionOpiaceos', 'Atención Opiáceos', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 63, 'tipoConsumoOpiaceos', 'Consumo Opiáceos', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 64, 'tipoAtencionAlucinogenos', 'Atención Alucinógenos', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 65, 'tipoConsumoAlucinogenos', 'Consumo Alucinógenos', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 66, 'tipoAtencionBenzodiacepinas', 'Atención Benzodiacepinas', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 67, 'tipoConsumoBenzodiacepinas', 'Consumo Benzodiacepinas', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 68, 'tipoAtencionOtros', 'Atención Otras sustancias', 'numerico', 1, FALSE, FALSE, 'MEN_ATENCION_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 69, 'tipoConsumoOtros', 'Consumo Otras sustancias', 'numerico', 1, FALSE, FALSE, 'MEN_CONSUMO_SUSTANCIA', 'CATALOGO'),
    (v_guia_men, 70, 'ambitoViolencias', 'Ámbito de violencias', 'texto', 5, FALSE, FALSE, 'MEN_AMBITO_VIOLENCIA', 'ARREGLO'),
    (v_guia_men, 71, 'tipoViolenciaFamiliar', 'Tipo de violencia familiar', 'texto', 10, FALSE, FALSE, 'MEN_TIPO_VIOLENCIA', 'ARREGLO'),
    (v_guia_men, 72, 'tipoViolenciaComunitaria', 'Tipo de violencia comunitaria', 'texto', 10, FALSE, FALSE, 'MEN_TIPO_VIOLENCIA', 'ARREGLO'),
    (v_guia_men, 73, 'tipoViolenciaColectiva', 'Tipo de violencia colectiva', 'texto', 10, FALSE, FALSE, 'MEN_TIPO_VIOLENCIA', 'ARREGLO'),
    (v_guia_men, 74, 'comportamientoSuicida', 'Comportamiento suicida', 'numerico', 1, FALSE, FALSE, 'MEN_COMPORTAMIENTO_SUICIDA', 'CATALOGO'),
    (v_guia_men, 75, 'usuarioConflictoLey', 'Caso médico legal', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 76, 'pacienteRehabilitado', 'Remisión o recuperación', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 77, 'lineaVida', 'Programa Línea de Vida', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 78, 'cartillaSalud', 'Presenta cartilla', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 79, 'esquemaVacunacion', 'Esquema de vacunación', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 80, 'referidoPor', 'Referido a unidad mayor', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_men, 81, 'contrarreferido', 'Paciente contrarreferido', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 82, 'telemedicina', 'Solicita telemedicina', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 83, 'teleconsulta', 'Consulta a distancia', 'numerico', 1, TRUE, FALSE, 'MEN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_men, 84, 'estudiosTeleconsulta', 'Estudios teleconsulta', 'texto', 15, FALSE, FALSE, NULL, 'ARREGLO'),
    (v_guia_men, 85, 'modalidadConsulDist', 'Modalidad a distancia', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- 4. REGLAS LÓGICAS (Considerando la Fe de Erratas Oficial Pág. 35)
    
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_men, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='peso' AND normatividad_id=v_guia_men), 
     'LIMITE_PESO', 'RANGO_VALOR', '{"operador": "between", "min": 1, "max": 400}'::jsonb, 
     'El peso debe estar entre 1 y 400 kg.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_men, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='sistolica' AND normatividad_id=v_guia_men), 
     'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"operador": "greater_than_or_equal", "campo1": "sistolica", "campo2": "diastolica"}'::jsonb, 
     'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_men, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='codigoCIEDiagnostico1' AND normatividad_id=v_guia_men), 
     'ERRATA_VALIDACION_DIAGNOSTICO_TERAPIA', 'LOGICA_COMPLEJA', '{"operador": "if_then", "condicion": {"campo": "psicoTerapia", "in": ["2", "3", "4"]}, "accion": {"ignorar_validacion_edad_sexo": true}}'::jsonb, 
     'Fe de erratas: Si la psicoterapia es Grupal, de Pareja o Familiar, se omite la validación de Edad y Sexo del diagnóstico.', 'ADVERTENCIA', v_fecha);

END $$;