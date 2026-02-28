-- =========================================================================
-- CARGA EXHAUSTIVA AL 100% - GUÍA 1: CONSULTA EXTERNA (Definitiva)
-- Guía GIIS-B015-04-11 (106 Variables Oficiales - Versión Nov 2024)
-- =========================================================================

DO $$
DECLARE
    v_guia_cex INT;
    v_fecha DATE := '2024-11-01';
    v_dic_id INT;
BEGIN

    -- 1. ASEGURAR QUE LA GUÍA EXISTE EN EL CATÁLOGO MAESTRO
    INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus) 
    VALUES ('GIIS-B015-04-11', 'Consulta Externa', '4.11', v_fecha, 'ACTIVO')
    ON CONFLICT (clave) DO UPDATE SET version = EXCLUDED.version;

    SELECT id INTO v_guia_cex FROM public.sys_normatividad_giis WHERE clave = 'GIIS-B015-04-11';

    -- 2. INYECCIÓN DE MINICATÁLOGOS ESPECÍFICOS DE CONSULTA EXTERNA
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_SINO_CERO_UNO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'SI', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_RELACION_TEMP', 'Relación Temporal', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_RELACION_TEMP';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'PRIMERA VEZ', 1), (v_dic_id, '1', 'SUBSECUENTE', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_SEXO_CURP', 'Sexo CURP', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_SEXO_CURP';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'HOMBRE', 1), (v_dic_id, '2', 'MUJER', 2), (v_dic_id, '3', 'NO BINARIO', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_SEXO_BIO', 'Sexo Biológico', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_SEXO_BIO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'HOMBRE', 1), (v_dic_id, '2', 'MUJER', 2), (v_dic_id, '3', 'INTERSEXUAL', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_GENERO', 'Identidad de Género', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_GENERO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO ESPECIFICADO', 1), (v_dic_id, '1', 'MASCULINO', 2), (v_dic_id, '2', 'FEMENINO', 3), (v_dic_id, '3', 'TRANSGENERO', 4), (v_dic_id, '4', 'TRANSEXUAL', 5), (v_dic_id, '5', 'TRAVESTI', 6), (v_dic_id, '6', 'INTERSEXUAL', 7), (v_dic_id, '88', 'OTRO', 8) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_RIESGO_PREGESTACIONAL', 'Riesgo Pregestacional', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_RIESGO_PREGESTACIONAL';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'PATOLOGIA CRONICA ORGANO FUNCIONAL', 1), (v_dic_id, '2', 'PATOLOGIA CRONICA INFECCIOSA', 2), (v_dic_id, '3', 'MORBILIDAD MATERNA EXTREMA', 3), (v_dic_id, '4', 'CON FACTORES DE RIESGO SOCIALES', 4), (v_dic_id, '5', 'ANTECEDENTES OBSTETRICOS DE RIESGO', 5), (v_dic_id, '9', 'SIN ANTECEDENTES', 6) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_TRIMESTRE_GESTACIONAL', 'Trimestre Gestacional', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_TRIMESTRE_GESTACIONAL';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'PRIMERO', 1), (v_dic_id, '2', 'SEGUNDO', 2), (v_dic_id, '3', 'TERCERO', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_RESULTADO_EDI', 'Resultado Prueba EDI', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_RESULTADO_EDI';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'VERDE', 1), (v_dic_id, '2', 'AMARILLO', 2), (v_dic_id, '3', 'ROJO', 3), (v_dic_id, '4', 'RECUPERADO DE REZAGO', 4), (v_dic_id, '5', 'RECUPERADO DE RIESGO', 5), (v_dic_id, '6', 'EN SEGUIMIENTO', 6) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_RESULTADO_BATTELLE', 'Resultado Prueba Battelle', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_RESULTADO_BATTELLE';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'MAYOR O IGUAL A 90', 1), (v_dic_id, '2', 'DE 89 A 80', 2), (v_dic_id, '3', 'MENOR O IGUAL A 79', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_PLAN_EDAS', 'Plan EDAS', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_PLAN_EDAS';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'PLAN A', 1), (v_dic_id, '2', 'PLAN B', 2), (v_dic_id, '3', 'PLAN C', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_PLAN_IRAS', 'Plan IRAS', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_PLAN_IRAS';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'SINTOMATICO', 1), (v_dic_id, '2', 'ANTIBIOTICO', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_GERONTOLOGIA', 'Intervención Gerontológica', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_GERONTOLOGIA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'PREVENTIVA', 1), (v_dic_id, '2', 'TRATAMIENTO', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_MOTIVO_REFERIDO', 'Motivo de Referencia', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_MOTIVO_REFERIDO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'EMBARAZO ALTO RIESGO', 1), (v_dic_id, '2', 'SOSPECHA CANCER < 18 AÑOS', 2), (v_dic_id, '3', 'POR IRAS', 3), (v_dic_id, '4', 'POR NEUMONIA', 4), (v_dic_id, '5', 'OTRAS', 5), (v_dic_id, '6', 'CISTICERCOSIS', 6), (v_dic_id, '7', 'EMERGENCIA OBSTETRICA-PREECLAMPSIA', 7), (v_dic_id, '8', 'EMERGENCIA OBSTETRICA-HEMORRAGIA', 8), (v_dic_id, '9', 'OTRA EMERGENCIA OBSTETRICA', 9) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('CEX_MODALIDAD_TELE', 'Modalidad Teleconsulta', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'CEX_MODALIDAD_TELE';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'EN TIEMPO REAL', 1), (v_dic_id, '2', 'DIFERIDA', 2) ON CONFLICT DO NOTHING;


    -- 3. CARGA DE LAS 106 VARIABLES EXACTAS DEL PDF 
    
    -- Bloque 1: Identificación y Demografía (Variables 1 a 25)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_cex, 1, 'clues', 'Clave Única de Establecimientos', 'texto', 11, TRUE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_cex, 2, 'paisNacimiento', 'País nacimiento prestador', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_cex, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_cex, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_cex, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_cex, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_cex, 7, 'tipoPersonal', 'Tipo de profesional', 'numerico', 2, TRUE, FALSE, 'TIPO PERSONAL - SIS', 'CATALOGO'),
    (v_guia_cex, 8, 'programaSMyMG', 'Programa U013', 'numerico', 1, TRUE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_cex, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_cex, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_cex, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_cex, 13, 'fechaNacimiento', 'Fecha de nacimiento', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_cex, 14, 'paisNacPaciente', 'País nacimiento paciente', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_cex, 15, 'entidadNacimiento', 'Entidad de nacimiento', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_cex, 16, 'sexoCURP', 'Sexo según CURP', 'numerico', 1, TRUE, FALSE, 'CEX_SEXO_CURP', 'CATALOGO'),
    (v_guia_cex, 17, 'sexoBiologico', 'Sexo biológico', 'numerico', 1, TRUE, FALSE, 'CEX_SEXO_BIO', 'CATALOGO'),
    (v_guia_cex, 18, 'seAutodenominaAfromexicano', 'Afromexicano', 'numerico', 1, TRUE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 19, 'seConsideraIndigena', 'Indígena', 'numerico', 1, TRUE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 20, 'migrante', 'Migrante', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_cex, 21, 'paisProcedencia', 'País de procedencia', 'numerico', 3, FALSE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_cex, 22, 'genero', 'Identidad de género', 'numerico', 2, TRUE, FALSE, 'CEX_GENERO', 'CATALOGO'),
    (v_guia_cex, 23, 'derechohabiencia', 'Afiliación', 'texto', 20, TRUE, FALSE, 'AFILIACION', 'ARREGLO'),
    (v_guia_cex, 24, 'fechaConsulta', 'Fecha de la consulta', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_cex, 25, 'servicioAtencion', 'Servicio de atención', 'numerico', 2, TRUE, FALSE, 'ESPECIALIDADES', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 2: Somatometría y Diagnósticos (Variables 26 a 51)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_cex, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 27, 'talla', 'Talla (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 28, 'circunferenciaCintura', 'Circunferencia cintura (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 29, 'sistolica', 'Presión arterial sistólica', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 30, 'diastolica', 'Presión arterial diastólica', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 33, 'temperatura', 'Temperatura corporal', 'numerico', 4, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 34, 'saturacionOxigeno', 'SpO2', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 35, 'glucemia', 'Glucosa en sangre', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 36, 'tipoMedicion', 'Glucosa en ayunas', 'numerico', 1, TRUE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 37, 'resultadoObtenidoaTravesde', 'Origen glucosa', 'numerico', 1, TRUE, FALSE, NULL, 'CATALOGO'),
    (v_guia_cex, 38, 'embarazadaSinDiabetes', 'Tiras usadas embarazo', 'numerico', 1, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 39, 'sintomaticoRespiratorioTb', 'Probable TB', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 40, 'primeraVezAnio', 'Primera consulta año', 'numerico', 1, TRUE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 41, 'primeraVezUneme', 'Seguimiento UNEME', 'numerico', 1, TRUE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 42, 'relacionTemporal', 'Relación temporal', 'numerico', 1, TRUE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 43, 'codigoCIEDiagnostico1', 'Diagnóstico principal', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_cex, 44, 'confirmacionDiagnostica1', 'Confirma Dx1', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 45, 'primeraVezDiagnostico2', 'Primera vez Dx2', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 46, 'codigoCIEDiagnostico2', 'Diagnóstico secundario', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_cex, 47, 'confirmacionDiagnostica2', 'Confirma Dx2', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 48, 'primeraVezDiagnostico3', 'Primera vez Dx3', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 49, 'codigoCIEDiagnostico3', 'Tercer diagnóstico', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_cex, 50, 'confirmacionDiagnostica3', 'Confirma Dx3', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 51, 'intervencionesSMyA', 'Acciones Salud Mental', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 3: Salud Reproductiva y Embarazo (Variables 52 a 76)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_cex, 52, 'atencionPregestacionalRT', 'Atención pregestacional', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 53, 'riesgo', 'Riesgos detectados', 'texto', 10, FALSE, FALSE, 'CEX_RIESGO_PREGESTACIONAL', 'ARREGLO'),
    (v_guia_cex, 54, 'relacionTemporalEmbarazo', 'Relación temporal embarazo', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 55, 'planSeguridad', 'Plan de seguridad embarazo', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_cex, 56, 'trimestreGestacional', 'Trimestre gestacional', 'numerico', 1, FALSE, FALSE, 'CEX_TRIMESTRE_GESTACIONAL', 'CATALOGO'),
    (v_guia_cex, 57, 'primeraVezAltoRiesgo', 'Alto riesgo primera vez', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 58, 'complicacionPorDiabetes', 'Complicación Diabetes', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 59, 'complicacionPorInfeccionUrinaria', 'Complicación IVU', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 60, 'complicacionPorPreeclampsiaEclampsia', 'Complicación Preeclampsia', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 61, 'complicacionPorHemorragia', 'Complicación hemorragia', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 62, 'sospechaCovid19', 'Sospecha COVID Embarazo', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 63, 'covid19Confirmado', 'COVID confirmado', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 64, 'hipertensionarterialprexistente', 'HTA preexistente', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 65, 'otrasAccPrescAcidoFolico', 'Acido fólico', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 66, 'otrasAccApoyoTranslado', 'Apoyo traslado obstétrico', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 67, 'otrasACCApoyoTransladoAME', 'Transporte AME', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 68, 'puerpera', 'Puerperio', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 69, 'infeccionPuerperal', 'Infección puerperal', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 70, 'terapiaHormonal', 'Terapia Hormonal', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 71, 'periPostMenopausia', 'Menopausia', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 72, 'its', 'Infección transmisión sexual', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 73, 'patologiaMamariaBenigna', 'Patología mamaria', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 74, 'cancerMamario', 'Cáncer mamario', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 75, 'colposcopia', 'Realizó colposcopia', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 76, 'cancerCervicouterino', 'Cáncer cervicouterino', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 4: Pediatría, Gerontología y Telemedicina (Variables 77 a 106)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_cex, 77, 'ninoSanoRT', 'Consulta niño sano', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 78, 'pruebaEDI', 'Aplicación prueba EDI', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_cex, 79, 'resultadoEDI', 'Resultado EDI', 'numerico', 1, FALSE, FALSE, 'CEX_RESULTADO_EDI', 'CATALOGO'),
    (v_guia_cex, 80, 'resultadoBattelle', 'Resultado Battelle', 'numerico', 1, FALSE, FALSE, 'CEX_RESULTADO_BATTELLE', 'CATALOGO'),
    (v_guia_cex, 81, 'edasRT', 'EDAS relación temporal', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 82, 'edasPlanTratamiento', 'Plan tratamiento EDAS', 'numerico', 1, FALSE, FALSE, 'CEX_PLAN_EDAS', 'CATALOGO'),
    (v_guia_cex, 83, 'recuperadoDeshidratacion', 'Recuperado deshidratación', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 84, 'numeroSobresVSOTratamiento', 'Sobres VSO', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 85, 'irasRT', 'IRAS relación temporal', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 86, 'irasPlanTratamiento', 'Plan tratamiento IRAS', 'numerico', 1, FALSE, FALSE, 'CEX_PLAN_IRAS', 'CATALOGO'),
    (v_guia_cex, 87, 'neumoniaRT', 'Neumonía temporalidad', 'numerico', 1, FALSE, FALSE, 'CEX_RELACION_TEMP', 'CATALOGO'),
    (v_guia_cex, 88, 'aplicacionCedulaCancer', 'Cédula cáncer <18', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_cex, 89, 'informaPrevencionAccidentes', 'Prevención accidentes <10', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 90, 'sintomaDepresiva', 'Sintomatología depresiva', 'numerico', 1, FALSE, FALSE, 'CEX_GERONTOLOGIA', 'CATALOGO'),
    (v_guia_cex, 91, 'alteracionMemoria', 'Alteración memoria', 'numerico', 1, FALSE, FALSE, 'CEX_GERONTOLOGIA', 'CATALOGO'),
    (v_guia_cex, 92, 'aivd_ABVD', 'Actividades vida diaria', 'numerico', 1, FALSE, FALSE, 'CEX_GERONTOLOGIA', 'CATALOGO'),
    (v_guia_cex, 93, 'sindromeCaidas', 'Síndrome caídas', 'numerico', 1, FALSE, FALSE, 'CEX_GERONTOLOGIA', 'CATALOGO'),
    (v_guia_cex, 94, 'incontinenciaUrinaria', 'Incontinencia', 'numerico', 1, FALSE, FALSE, 'CEX_GERONTOLOGIA', 'CATALOGO'),
    (v_guia_cex, 95, 'motricidad', 'Motricidad', 'numerico', 1, FALSE, FALSE, 'CEX_GERONTOLOGIA', 'CATALOGO'),
    (v_guia_cex, 96, 'asesoriaNutricional', 'Asesoría nutricional', 'numerico', 1, FALSE, FALSE, 'CEX_GERONTOLOGIA', 'CATALOGO'),
    (v_guia_cex, 97, 'numeroSobresVSOPromocion', 'VSO Promoción', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_cex, 98, 'lineaVida', 'Programa Línea de Vida', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 99, 'cartillaSalud', 'Presenta cartilla', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 100, 'esquemaVacunacion', 'Esquema de vacunación', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 101, 'referidoPor', 'Referido a unidad mayor', 'numerico', 1, FALSE, FALSE, 'CEX_MOTIVO_REFERIDO', 'CATALOGO'),
    (v_guia_cex, 102, 'contrarreferido', 'Contrarreferido', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 103, 'telemedicina', 'Solicita telemedicina', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 104, 'teleconsulta', 'Consulta a distancia', 'numerico', 1, FALSE, FALSE, 'CEX_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_cex, 105, 'estudiosTeleconsulta', 'Estudios teleconsulta', 'texto', 15, FALSE, FALSE, NULL, 'ARREGLO'),
    (v_guia_cex, 106, 'modalidadConsulDist', 'Modalidad teleconsulta', 'numerico', 1, FALSE, FALSE, 'CEX_MODALIDAD_TELE', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;


    -- 4. REGLAS LÓGICAS Y RESTRICCIONES DENTRO DEL DICCIONARIO
    
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_cex, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='peso' AND normatividad_id=v_guia_cex), 
     'LIMITE_PESO', 'RANGO_VALOR', '{"operador": "between", "min": 1, "max": 400}'::jsonb, 
     'El peso debe estar entre 1 y 400 kg.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_cex, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='sistolica' AND normatividad_id=v_guia_cex), 
     'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"operador": "greater_than_or_equal", "campo1": "sistolica", "campo2": "diastolica"}'::jsonb, 
     'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_cex, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='fechaConsulta' AND normatividad_id=v_guia_cex), 
     'LOGICA_FECHAS_CONSULTA', 'COMPARACION_CAMPOS', '{"operador": "greater_than_or_equal", "campo1": "fechaConsulta", "campo2": "fechaNacimiento"}'::jsonb, 
     'La fecha de consulta no puede ser anterior a la fecha de nacimiento.', 'ERROR', v_fecha);

    -- REGLA: Dependencia EDAS (Pág 38 del PDF)
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_cex, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='edasPlanTratamiento' AND normatividad_id=v_guia_cex), 
     'REQ_PLAN_EDAS', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "edasRT", "in": ["0", "1"]}, "accion": {"requerido": "edasPlanTratamiento"}}'::jsonb, 
     'Si se reporta Enfermedad Diarreica Aguda (EDAS), es obligatorio especificar el Plan de Tratamiento (A, B o C).', 'ERROR', v_fecha);

    -- REGLA: Dependencia IRAS (Pág 39 del PDF)
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_cex, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='irasPlanTratamiento' AND normatividad_id=v_guia_cex), 
     'REQ_PLAN_IRAS', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "irasRT", "in": ["0", "1"]}, "accion": {"requerido": "irasPlanTratamiento"}}'::jsonb, 
     'Si se reporta Infección Respiratoria Aguda (IRAS), es obligatorio especificar el Plan de Tratamiento.', 'ERROR', v_fecha);

    -- REGLA: Dependencia Teleconsulta (Pág 44 del PDF)
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_cex, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='modalidadConsulDist' AND normatividad_id=v_guia_cex), 
     'REQ_MODALIDAD_TELE', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "teleconsulta", "valor": "1"}, "accion": {"requerido_valor": "1"}}'::jsonb, 
     'Si se realizó teleconsulta, la modalidad debe ser EN TIEMPO REAL (1).', 'ERROR', v_fecha);

    -- REGLA: Coherencia de Embarazo y Sexo (Pág 31 del PDF)
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_cex, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='relacionTemporalEmbarazo' AND normatividad_id=v_guia_cex), 
     'BLOQUEO_EMBARAZO_HOMBRES', 'LOGICA_CRUZADA', '{"operador": "not_and", "condiciones": [{"campo": "sexoBiologico", "in": ["1", "3"]}, {"campo": "relacionTemporalEmbarazo", "in": ["0", "1"]}]}'::jsonb, 
     'Incongruencia: No se puede registrar control de embarazo en pacientes con sexo biológico masculino o intersexual.', 'ERROR', v_fecha);
     
    -- REGLA: Prueba EDI restringida a menores de 6 años (Pág 37 del PDF)
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_cex, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='pruebaEDI' AND normatividad_id=v_guia_cex), 
     'REQ_EDI_EDAD', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "edadCalculada", "greater_than_or_equal": 6}, "accion": {"requerido_valor": "-1"}}'::jsonb, 
     'La prueba EDI (Evaluación del Desarrollo Infantil) solo aplica para menores de 6 años.', 'ERROR', v_fecha);

END $$;