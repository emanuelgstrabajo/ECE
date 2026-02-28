-- =========================================================================
-- CARGA EXHAUSTIVA AL 100% - GUÍA 8: DETECCIONES (PREVENCIÓN)
-- Guía GIIS-B019-04-09 (92 Variables Oficiales - Versión Nov 2024)
-- =========================================================================

DO $$
DECLARE
    v_guia_det INT;
    v_fecha DATE := '2024-11-01';
    v_dic_id INT;
BEGIN

    -- 1. ASEGURAR QUE LA GUÍA EXISTE EN EL CATÁLOGO MAESTRO
    INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus) 
    VALUES ('GIIS-B019-04-09', 'Detecciones', '4.9', v_fecha, 'ACTIVO')
    ON CONFLICT (clave) DO UPDATE SET version = EXCLUDED.version;

    SELECT id INTO v_guia_det FROM public.sys_normatividad_giis WHERE clave = 'GIIS-B019-04-09';

    -- 2. INYECCIÓN DE MINICATÁLOGOS ESPECÍFICOS DE DETECCIONES
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('DET_TIPO_PERSONAL', 'Tipo de Personal Detecciones', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'DET_TIPO_PERSONAL';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'MÉDICA(O) PASANTE', 1), (v_dic_id, '2', 'MÉDICA(O) GENERAL', 2), (v_dic_id, '3', 'MÉDICA(O) RESIDENTE', 3), (v_dic_id, '4', 'MÉDICA(O) ESPECIALISTA', 4), (v_dic_id, '5', 'PASANTE DE ENFERMERÍA', 5), (v_dic_id, '6', 'ENFERMERA(O)', 6), (v_dic_id, '7', 'PASANTE DE NUTRICIÓN', 7), (v_dic_id, '8', 'NUTRIÓLOGA(O)', 8), (v_dic_id, '9', 'HOMEÓPATA', 9), (v_dic_id, '10', 'MÉDICA(O) TRADICIONAL', 10), (v_dic_id, '11', 'TAPS', 11), (v_dic_id, '15', 'PASANTE DE PSICOLOGÍA', 12), (v_dic_id, '16', 'PSICÓLOGA(O)', 13), (v_dic_id, '17', 'RESIDENTE DE PSIQUIATRÍA', 14), (v_dic_id, '18', 'PSIQUIATRA', 15), (v_dic_id, '19', 'MÉDICA(O) GENERAL HABILITADO SM', 16), (v_dic_id, '20', 'LICENCIADA EN ENFERMERÍA Y OBSTETRICIA', 17), (v_dic_id, '21', 'PARTERA TÉCNICA', 18), (v_dic_id, '22', 'PROMOTOR DE SALUD', 19), (v_dic_id, '24', 'MÉDICA(O) ESPECIALISTA HABILITADO SM', 20), (v_dic_id, '25', 'LICENCIADA(O) EN GERONTOLOGÍA', 21), (v_dic_id, '27', 'PASANTE DE GERONTOLOGÍA', 22), (v_dic_id, '30', 'TRABAJADORA(OR) SOCIAL', 23) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('DET_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'DET_SINO_CERO_UNO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'SI', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('DET_POS_NEG', 'Opciones Positivo/Negativo', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'DET_POS_NEG';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'POSITIVO', 1), (v_dic_id, '1', 'NEGATIVO', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('DET_NORMAL_ANORMAL', 'Opciones Normal/Anormal', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'DET_NORMAL_ANORMAL';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NORMAL', 1), (v_dic_id, '1', 'ANORMAL', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('DET_RIESGO', 'Escala de Riesgo', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'DET_RIESGO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'BAJO RIESGO', 1), (v_dic_id, '2', 'MEDIANO RIESGO', 2), (v_dic_id, '3', 'ALTO RIESGO', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('DET_PRUEBAS_ITS', 'Resultados ITS (VIH/Sífilis)', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'DET_PRUEBAS_ITS';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', '1A DETECCIÓN PRUEBA RÁPIDA REACTIVA', 1), (v_dic_id, '2', '1A DETECCIÓN PRUEBA RÁPIDA NO REACTIVA', 2), (v_dic_id, '3', '1A DETECCIÓN ELISA POSITIVA', 3), (v_dic_id, '4', '1A DETECCIÓN ELISA NEGATIVA', 4), (v_dic_id, '5', '2A DETECCIÓN PRUEBA RÁPIDA REACTIVA', 5), (v_dic_id, '6', '2A DETECCIÓN PRUEBA RÁPIDA NO REACTIVA', 6), (v_dic_id, '7', '2A DETECCIÓN ELISA POSITIVA', 7), (v_dic_id, '8', '2A DETECCIÓN ELISA NEGATIVA', 8), (v_dic_id, '9', 'PRUEBA CONFIRMATORIA POSITIVA', 9), (v_dic_id, '10', 'PRUEBA CONFIRMATORIA NEGATIVA', 10) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('DET_ESPIROMETRIA', 'Resultado Espirometría', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'DET_ESPIROMETRIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'NORMAL CON RESPUESTA A BRONCODILATADOR', 1), (v_dic_id, '2', 'NORMAL SIN RESPUESTA A BRONCODILATADOR', 2), (v_dic_id, '3', 'OBSTRUIDO CON RESPUESTA', 3), (v_dic_id, '4', 'OBSTRUIDO SIN RESPUESTA', 4), (v_dic_id, '5', 'SUGIERE RESTRICCIÓN CON RESPUESTA', 5), (v_dic_id, '6', 'SUGIERE RESTRICCIÓN SIN RESPUESTA', 6), (v_dic_id, '7', 'SUGIERE PATRÓN MIXTO CON RESPUESTA', 7), (v_dic_id, '8', 'SUGIERE PATRÓN MIXTO SIN RESPUESTA', 8), (v_dic_id, '9', 'PATRÓN NO ESPECÍFICO CON RESPUESTA', 9), (v_dic_id, '10', 'PATRÓN NO ESPECÍFICO SIN RESPUESTA', 10) ON CONFLICT DO NOTHING;


    -- 3. CARGA DE LAS 92 VARIABLES EXACTAS DEL PDF 
    
    -- Bloque 1: Identificación y Demografía (Variables 1 a 23)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_det, 1, 'clues', 'Clave Única de Establecimientos', 'texto', 11, TRUE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_det, 2, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_det, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_det, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_det, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_det, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_det, 7, 'tipoPersonal', 'Tipo de profesional de la salud', 'numerico', 2, TRUE, FALSE, 'DET_TIPO_PERSONAL', 'CATALOGO'),
    (v_guia_det, 8, 'programaSMyMG', 'Programa U013', 'numerico', 1, TRUE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_det, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_det, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_det, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_det, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_det, 13, 'fechaNacimiento', 'Fecha de nacimiento', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_det, 14, 'paisNacPaciente', 'País de nacimiento del paciente', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_det, 15, 'entidadNacimiento', 'Entidad de nacimiento del paciente', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_det, 16, 'sexoCURP', 'Sexo registrado ante RENAPO', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_det, 17, 'sexoBiologico', 'Sexo biológico/fisiológico', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_det, 18, 'seAutodenominaAfromexicano', 'Afromexicano', 'numerico', 1, TRUE, FALSE, 'DET_AFRO_INDIGENA', 'CATALOGO'),
    (v_guia_det, 19, 'seConsideraIndigena', 'Indígena', 'numerico', 1, TRUE, FALSE, 'DET_AFRO_INDIGENA', 'CATALOGO'),
    (v_guia_det, 20, 'migrante', 'Migrante', 'numerico', 1, TRUE, FALSE, 'DET_MIGRANTE', 'CATALOGO'),
    (v_guia_det, 21, 'paisProcedencia', 'País de procedencia', 'numerico', 3, FALSE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_det, 22, 'genero', 'Identidad de género', 'numerico', 2, TRUE, FALSE, 'DET_GENERO', 'CATALOGO'),
    (v_guia_det, 23, 'derechohabiencia', 'Afiliación', 'texto', 20, TRUE, FALSE, 'AFILIACION', 'ARREGLO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 2: Somatometría y Primera Detección (Variables 24 a 38)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_det, 24, 'fechaDeteccion', 'Fecha de las detecciones', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_det, 25, 'servicioAtencion', 'Servicio de atención', 'numerico', 2, TRUE, FALSE, 'ESPECIALIDADES', 'CATALOGO'),
    (v_guia_det, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 27, 'talla', 'Talla (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 28, 'circunferenciaCintura', 'Circunferencia cintura (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 29, 'sistolica', 'Presión arterial sistólica', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 30, 'diastolica', 'Presión arterial diastólica', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 33, 'temperatura', 'Temperatura corporal', 'numerico', 4, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 34, 'saturacionOxigeno', 'SpO2', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 35, 'glucemia', 'Glucosa en sangre', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 36, 'tipoMedicion', 'Glucosa en ayunas', 'numerico', 1, TRUE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_det, 37, 'tirasDeteccion', 'Número de tiras usadas', 'numerico', 1, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 38, 'primeraVezAnio', 'Primera consulta en el año', 'numerico', 1, TRUE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 3: Salud Mental, Geriátrica y Crónicas (Variables 39 a 62)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_det, 39, 'depresionTamizaje', 'Tamizaje de depresión', 'numerico', 1, FALSE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_det, 40, 'depresion', 'Detección de depresión', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 41, 'ansiedad', 'Detección de ansiedad', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 42, 'haOlvidadoMasCosas', 'Tamizaje olvido de cosas', 'numerico', 1, FALSE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_det, 43, 'alteracionesDeMemoria', 'Detección alteración memoria', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 44, 'demencia', 'Riesgo de demencia', 'numerico', 1, FALSE, FALSE, 'DET_RIESGO', 'CATALOGO'),
    (v_guia_det, 45, 'tamizajeFugaDeOrina', 'Tamizaje fuga de orina', 'numerico', 1, FALSE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_det, 46, 'incontinenciaUrinaria', 'Detección incontinencia', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 47, 'tamizajeCaidas', 'Tamizaje de caídas', 'numerico', 1, FALSE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_det, 48, 'caida60yMas', 'Detección síndrome de caídas', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 49, 'marcha', 'Evaluación de la marcha', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 50, 'estadoNutricional', 'Evaluación estado nutricional', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 51, 'abvdTamizaje', 'Tamizaje ABVD', 'numerico', 1, FALSE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_det, 52, 'abvdEvaluacion', 'Evaluación ABVD', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 53, 'aivdTamizaje', 'Tamizaje AIVD', 'numerico', 1, FALSE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_det, 54, 'aivdEvaluacion', 'Evaluación AIVD', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 55, 'edadCuidador', 'Edad del cuidador', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_det, 56, 'sexoCuidador', 'Sexo del cuidador', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_det, 57, 'sobrecargaCuidador', 'Sobrecarga del cuidador', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 58, 'riesgoFractura', 'Riesgo fractura osteoporosis', 'numerico', 1, FALSE, FALSE, 'DET_RIESGO', 'CATALOGO'),
    (v_guia_det, 59, 'diabetesMellitus', 'Detección Diabetes Mellitus', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 60, 'hipertensionArterial', 'Detección Hipertensión', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 61, 'obesidad', 'Detección Obesidad', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 62, 'dislipidemias', 'Detección Dislipidemias', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 4: Sustancias, ITS, Cáncer y Espirometría (Variables 63 a 92)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_det, 63, 'alcohol', 'Consumo Alcohol', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 64, 'tabaco', 'Consumo Tabaco', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 65, 'cannabis', 'Consumo Cannabis', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 66, 'cocaina', 'Consumo Cocaína', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 67, 'metanfetaminas', 'Consumo Metanfetaminas', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 68, 'inhalables', 'Consumo Inhalables', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 69, 'opiaceos', 'Consumo Opiáceos', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 70, 'alucinogenos', 'Consumo Alucinógenos', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 71, 'tranquilizantes', 'Consumo Tranquilizantes', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 72, 'otrasSubstancias', 'Otras Sustancias', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 73, 'B24X', 'Detección VIH', 'numerico', 2, FALSE, FALSE, 'DET_PRUEBAS_ITS', 'CATALOGO'),
    (v_guia_det, 74, 'A539', 'Detección Sífilis', 'numerico', 2, FALSE, FALSE, 'DET_PRUEBAS_ITS', 'CATALOGO'),
    (v_guia_det, 75, 'gonorrea', 'Detección Gonorrea', 'numerico', 2, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_det, 76, 'hepatitisB', 'Detección Hepatitis B', 'numerico', 2, FALSE, FALSE, 'DET_PRUEBAS_ITS', 'CATALOGO'),
    (v_guia_det, 77, 'herpesGenital', 'Detección Herpes', 'numerico', 2, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_det, 78, 'chlamydia', 'Detección Chlamydia', 'numerico', 2, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_det, 79, 'resultadoVPH', 'Resultado VPH', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 80, 'cancerCervicoUterino', 'Citología cervical', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_det, 81, 'resultadoCancerCervicoUterino', 'Resultado Citología', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 82, 'cancerMama', 'Detección Cáncer Mama', 'numerico', 1, FALSE, FALSE, 'DET_NORMAL_ANORMAL', 'CATALOGO'),
    (v_guia_det, 83, 'violenciaSexual', 'Violencia sexual no pareja', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 84, 'violenciaMujer15yMas', 'Violencia por pareja', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 85, 'sospechaSindromeTurner', 'Sospecha de Turner', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 86, 'hiperplasiaProstatica', 'Próstata/Cuestionario PSA', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 87, 'reactivosAntigenoProstatico', 'Reactivos PSA usados', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 88, 'sintomaticoRespiratorio', 'Probable TB', 'numerico', 1, FALSE, FALSE, 'DET_POS_NEG', 'CATALOGO'),
    (v_guia_det, 89, 'espirometriaVEFI_CVF', 'Resultado VEFI/CVF', 'numerico', 3, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 90, 'LIN', 'Límite Inferior Normalidad', 'numerico', 4, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_det, 91, 'espirometriaResultado', 'Resultado Espirometría', 'numerico', 2, FALSE, FALSE, 'DET_ESPIROMETRIA', 'CATALOGO'),
    (v_guia_det, 92, 'cartillaSalud', 'Presenta cartilla', 'numerico', 1, FALSE, FALSE, 'DET_SINO_CERO_UNO', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- 4. REGLAS LÓGICAS Y RESTRICCIONES DENTRO DEL DICCIONARIO
    
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_det, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='peso' AND normatividad_id=v_guia_det), 
     'LIMITE_PESO', 'RANGO_VALOR', '{"operador": "between", "min": 1, "max": 400}'::jsonb, 
     'El peso debe estar entre 1 y 400 kg.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_det, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='sistolica' AND normatividad_id=v_guia_det), 
     'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"operador": "greater_than_or_equal", "campo1": "sistolica", "campo2": "diastolica"}'::jsonb, 
     'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', v_fecha);

    -- Prevención de Próstata en Mujeres
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_det, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='hiperplasiaProstatica' AND normatividad_id=v_guia_det), 
     'BLOQUEO_PROSTATA_MUJER', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "sexoBiologico", "valor": "2"}, "accion": {"requerido_valor": "-1"}}'::jsonb, 
     'La detección de hiperplasia prostática no aplica en mujeres.', 'ERROR', v_fecha);

END $$;