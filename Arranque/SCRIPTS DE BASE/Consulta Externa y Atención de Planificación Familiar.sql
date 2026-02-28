-- =========================================================================
-- CARGA EXHAUSTIVA AL 100% - GUÍA 7: PLANIFICACIÓN FAMILIAR 
-- Guía GIIS-B018-04-09 (72 Variables Oficiales - Versión Nov 2024)
-- =========================================================================

DO $$
DECLARE
    v_guia_pla INT;
    v_fecha DATE := '2024-11-01';
    v_dic_id INT;
BEGIN

    -- 1. ASEGURAR QUE LA GUÍA EXISTE EN EL CATÁLOGO MAESTRO
    INSERT INTO public.sys_normatividad_giis (clave, nombre_documento, version, fecha_publicacion, estatus) 
    VALUES ('GIIS-B018-04-09', 'Consulta Externa y Atención de Planificación Familiar', '4.9', v_fecha, 'ACTIVO')
    ON CONFLICT (clave) DO UPDATE SET version = EXCLUDED.version;

    SELECT id INTO v_guia_pla FROM public.sys_normatividad_giis WHERE clave = 'GIIS-B018-04-09';

    -- 2. INYECCIÓN DE MINICATÁLOGOS ESPECÍFICOS (Acordes a la Versión 4.9)
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_TIPO_PERSONAL', 'Tipo de Personal Planificación', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_TIPO_PERSONAL';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'MÉDICA(O) PASANTE', 1), (v_dic_id, '2', 'MÉDICA(O) GENERAL', 2), (v_dic_id, '3', 'MÉDICA(O) RESIDENTE', 3), (v_dic_id, '4', 'MÉDICA(O) ESPECIALISTA', 4), (v_dic_id, '5', 'PASANTE DE ENFERMERÍA', 5), (v_dic_id, '6', 'ENFERMERA(O)', 6), (v_dic_id, '9', 'HOMEÓPATA', 7), (v_dic_id, '10', 'MÉDICA(O) TRADICIONAL INDÍGENA', 8), (v_dic_id, '11', 'TAPS', 9), (v_dic_id, '15', 'PASANTE DE PSICOLOGÍA', 10), (v_dic_id, '16', 'PSICÓLOGA(O)', 11), (v_dic_id, '19', 'MÉDICA(O) GENERAL HABILITADA(O) PARA SM', 12), (v_dic_id, '20', 'LICENCIADA(O) EN ENFERMERÍA Y OBSTETRICIA', 13), (v_dic_id, '21', 'PARTERA (O) TÉCNICA', 14), (v_dic_id, '22', 'PROMOTOR(A) DE SALUD', 15), (v_dic_id, '24', 'MÉDICA(O) ESPECIALISTA HABILITADO PARA SM', 16) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_SINO_CERO_UNO', 'Opciones Si(1) / No(0)', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_SINO_CERO_UNO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'SI', 2) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_SEXO_CURP', 'Sexo CURP', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_SEXO_CURP';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'HOMBRE', 1), (v_dic_id, '2', 'MUJER', 2), (v_dic_id, '3', 'NO BINARIO', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_SEXO_BIO', 'Sexo Biológico', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_SEXO_BIO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'HOMBRE', 1), (v_dic_id, '2', 'MUJER', 2), (v_dic_id, '3', 'INTERSEXUAL', 3) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_AFRO_INDIGENA', 'Autodenominación Indígena / Afromexicano', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_AFRO_INDIGENA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'SI', 2), (v_dic_id, '2', 'NO RESPONDE', 3), (v_dic_id, '3', 'NO SABE', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_MIGRANTE', 'Condición Migrante', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_MIGRANTE';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO', 1), (v_dic_id, '1', 'NACIONAL', 2), (v_dic_id, '2', 'INTERNACIONAL', 3), (v_dic_id, '3', 'RETORNADO (Sólo nacional)', 4) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_GENERO', 'Identidad de Género', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_GENERO';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'NO ESPECIFICADO', 1), (v_dic_id, '1', 'MASCULINO', 2), (v_dic_id, '2', 'FEMENINO', 3), (v_dic_id, '3', 'TRANSGENERO', 4), (v_dic_id, '4', 'TRANSEXUAL', 5), (v_dic_id, '5', 'TRAVESTI', 6), (v_dic_id, '6', 'INTERSEXUAL', 7), (v_dic_id, '88', 'OTRO', 8) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_ESTUDIOS_TELE', 'Estudios de Teleconsulta', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_ESTUDIOS_TELE';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '1', 'USG', 1), (v_dic_id, '2', 'ECG', 2), (v_dic_id, '3', 'RAYOS X', 3), (v_dic_id, '4', 'TOMOGRAFIA', 4), (v_dic_id, '5', 'RESONANCIA MAGNETICA', 5), (v_dic_id, '6', 'MASTOGRAFIA', 6), (v_dic_id, '7', 'OTROS', 7) ON CONFLICT DO NOTHING;

    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_REVISION_DIU', 'Revisión o Inserción DIU', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_REVISION_DIU';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'REVISION SIN COLOCACION DE METODO', 1), (v_dic_id, '1', 'INSERCION DE METODO', 2) ON CONFLICT DO NOTHING;
    
    INSERT INTO public.gui_diccionarios (codigo, nombre, es_sistema) VALUES ('PLAN_REVISION_QUIRURGICA', 'Revisión o Realización Quirúrgica', TRUE) ON CONFLICT (codigo) DO NOTHING;
    SELECT id INTO v_dic_id FROM public.gui_diccionarios WHERE codigo = 'PLAN_REVISION_QUIRURGICA';
    INSERT INTO public.gui_diccionario_opciones (diccionario_id, clave, valor, orden) VALUES
    (v_dic_id, '0', 'REVISION POSTERIOR A LA INTERVENCION', 1), (v_dic_id, '1', 'REALIZACION DE LA INTERVENCION', 2) ON CONFLICT DO NOTHING;


    -- 3. CARGA DE LAS 72 VARIABLES EXACTAS DEL PDF 
    
    -- Bloque 1: Identificación y Demografía (Variables 1 a 23)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_pla, 1, 'clues', 'Clave Única de Establecimientos', 'texto', 11, TRUE, FALSE, 'ESTABLECIMIENTO DE SALUD', 'CATALOGO'),
    (v_guia_pla, 2, 'paisNacimiento', 'País de nacimiento del prestador', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_pla, 3, 'curpPrestador', 'CURP del prestador', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_pla, 4, 'nombrePrestador', 'Nombre del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_pla, 5, 'primerApellidoPrestador', 'Primer apellido del prestador', 'texto', 50, TRUE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_pla, 6, 'segundoApellidoPrestador', 'Segundo apellido del prestador', 'texto', 50, FALSE, FALSE, NULL, 'TEXTO_LIBRE'),
    (v_guia_pla, 7, 'tipoPersonal', 'Tipo de profesional de la salud', 'numerico', 2, TRUE, FALSE, 'PLAN_TIPO_PERSONAL', 'CATALOGO'),
    (v_guia_pla, 8, 'programaSMyMG', 'Programa U013', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 9, 'curpPaciente', 'CURP del paciente', 'texto', 18, TRUE, TRUE, NULL, 'FORMATO'),
    (v_guia_pla, 10, 'nombre', 'Nombre(s) del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_pla, 11, 'primerApellido', 'Primer apellido del paciente', 'texto', 50, TRUE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_pla, 12, 'segundoApellido', 'Segundo apellido del paciente', 'texto', 50, FALSE, TRUE, NULL, 'TEXTO_LIBRE'),
    (v_guia_pla, 13, 'fechaNacimiento', 'Fecha de nacimiento', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_pla, 14, 'paisNacPaciente', 'País de nacimiento del paciente', 'numerico', 3, TRUE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_pla, 15, 'entidadNacimiento', 'Entidad de nacimiento del paciente', 'texto', 2, TRUE, FALSE, 'ENTIDAD_FEDERATIVA', 'CATALOGO'),
    (v_guia_pla, 16, 'sexoCURP', 'Sexo registrado ante RENAPO', 'numerico', 1, TRUE, FALSE, 'PLAN_SEXO_CURP', 'CATALOGO'),
    (v_guia_pla, 17, 'sexoBiologico', 'Sexo biológico/fisiológico', 'numerico', 1, TRUE, FALSE, 'PLAN_SEXO_BIO', 'CATALOGO'),
    (v_guia_pla, 18, 'seAutodenominaAfromexicano', 'Afromexicano', 'numerico', 1, TRUE, FALSE, 'PLAN_AFRO_INDIGENA', 'CATALOGO'),
    (v_guia_pla, 19, 'seConsideraIndigena', 'Indígena', 'numerico', 1, TRUE, FALSE, 'PLAN_AFRO_INDIGENA', 'CATALOGO'),
    (v_guia_pla, 20, 'migrante', 'Migrante', 'numerico', 1, TRUE, FALSE, 'PLAN_MIGRANTE', 'CATALOGO'),
    (v_guia_pla, 21, 'paisProcedencia', 'País de procedencia', 'numerico', 3, FALSE, FALSE, 'PAIS', 'CATALOGO'),
    (v_guia_pla, 22, 'genero', 'Identidad de género', 'numerico', 2, TRUE, FALSE, 'PLAN_GENERO', 'CATALOGO'),
    (v_guia_pla, 23, 'derechohabiencia', 'Afiliación', 'texto', 20, TRUE, FALSE, 'AFILIACION', 'ARREGLO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 2: Somatometría, Diagnósticos y Métodos (Variables 24 a 59)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_pla, 24, 'fechaConsulta', 'Fecha de la consulta', 'fecha', NULL, TRUE, FALSE, NULL, 'FORMATO'),
    (v_guia_pla, 25, 'servicioAtencion', 'Servicio de atención', 'numerico', 2, TRUE, FALSE, 'ESPECIALIDADES', 'CATALOGO'),
    (v_guia_pla, 26, 'peso', 'Peso del paciente (kg)', 'numerico', 7, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 27, 'talla', 'Talla (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 28, 'circunferenciaCintura', 'Circunferencia cintura (cm)', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 29, 'sistolica', 'Presión arterial sistólica', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 30, 'diastolica', 'Presión arterial diastólica', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 31, 'frecuenciaCardiaca', 'Latidos por minuto', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 32, 'frecuenciaRespiratoria', 'Respiraciones por minuto', 'numerico', 2, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 33, 'temperatura', 'Temperatura corporal', 'numerico', 4, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 34, 'saturacionOxigeno', 'SpO2', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 35, 'glucemia', 'Glucosa en sangre', 'numerico', 3, TRUE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 36, 'tipoMedicion', 'Glucosa en ayunas', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 37, 'primeraVezAnio', 'Primera consulta en el año', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 38, 'relacionTemporal', 'Primera vez o subsecuente', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 39, 'codigoCIEDiagnostico1', 'Diagnóstico principal', 'texto', 4, TRUE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_pla, 40, 'primeraVezDiagnostico2', 'Primera vez diag 2', 'numerico', 1, FALSE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 41, 'codigoCIEDiagnostico2', 'Diagnóstico secundario', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    (v_guia_pla, 42, 'primeraVezDiagnostico3', 'Primera vez diag 3', 'numerico', 1, FALSE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 43, 'codigoCIEDiagnostico3', 'Tercer diagnóstico', 'texto', 4, FALSE, FALSE, 'DIAGNOSTICOS', 'CATALOGO'),
    
    -- BLOQUE ESPECÍFICO DE MÉTODOS ENTREGADOS
    (v_guia_pla, 44, 'puerperaAceptaPF', 'Aceptó PF en puerperio', 'numerico', 1, FALSE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 45, 'oral', 'Ciclos método oral', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 46, 'inyectableMensual', 'Ciclos inyectable mensual', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 47, 'inyectableBimestral', 'Ciclos inyectable bimestral', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 48, 'inyectableTrimestral', 'Ciclos inyectable trimestral', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 49, 'implanteSubdermico1Var', 'Implante 1 varilla', 'numerico', 1, FALSE, FALSE, 'PLAN_REVISION_DIU', 'CATALOGO'),
    (v_guia_pla, 50, 'implanteSubdermico2Var', 'Implante 2 varillas', 'numerico', 1, FALSE, FALSE, 'PLAN_REVISION_DIU', 'CATALOGO'),
    (v_guia_pla, 51, 'parcheDermico', 'Ciclos parche dérmico', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 52, 'diu', 'Revisión o colocación DIU', 'numerico', 1, FALSE, FALSE, 'PLAN_REVISION_DIU', 'CATALOGO'),
    (v_guia_pla, 53, 'diuMedicado', 'Revisión/colocación DIU medicado', 'numerico', 1, FALSE, FALSE, 'PLAN_REVISION_DIU', 'CATALOGO'),
    (v_guia_pla, 54, 'quirurgico', 'Método quirúrgico (OTB/Vasectomía)', 'numerico', 1, FALSE, FALSE, 'PLAN_REVISION_QUIRURGICA', 'CATALOGO'),
    (v_guia_pla, 55, 'preservativo', 'Preservativos masculinos', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 56, 'preservativoFemenino', 'Preservativos femeninos', 'numerico', 2, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 57, 'otroMetodo', 'Otros métodos entregados', 'numerico', 1, FALSE, FALSE, NULL, 'RANGO'),
    (v_guia_pla, 58, 'anticoncepcionEmergencia', 'Píldora de emergencia', 'numerico', 1, FALSE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 59, 'altaConAzoospermia', 'Alta con azoospermia (Vasectomía)', 'numerico', 1, FALSE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- Bloque 3: Consejerías, Acciones Comunitarias y Telemedicina (Variables 60 a 72)
    INSERT INTO public.sys_giis_campos (normatividad_id, orden, nombre_campo, descripcion, tipo_dato, longitud_maxima, obligatorio, confidencial, catalogo_asociado, tipo_validacion) VALUES
    (v_guia_pla, 60, 'OycPlanificacionF', 'Orientación de PF', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 61, 'OycPrevencionITS', 'Orientación ITS', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 62, 'OycPrevencionEmb', 'Orientación prev. Embarazo', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 63, 'OycOtrasSSRA', 'Salud Sexual en Adolescencia', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 64, 'lineaVida', 'Programa Línea de Vida', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 65, 'cartillaSalud', 'Presenta cartilla', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 66, 'esquemaVacunacion', 'Esquema de vacunación', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 67, 'referidoPor', 'Referido a unidad mayor', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO'),
    (v_guia_pla, 68, 'contrarreferido', 'Paciente contrarreferido', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 69, 'telemedicina', 'Solicita telemedicina', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 70, 'teleconsulta', 'Consulta a distancia', 'numerico', 1, TRUE, FALSE, 'PLAN_SINO_CERO_UNO', 'CATALOGO'),
    (v_guia_pla, 71, 'estudiosTeleconsulta', 'Estudios teleconsulta', 'texto', 15, FALSE, FALSE, 'PLAN_ESTUDIOS_TELE', 'ARREGLO'),
    (v_guia_pla, 72, 'modalidadConsulDist', 'Modalidad a distancia', 'numerico', 1, FALSE, FALSE, NULL, 'CATALOGO')
    ON CONFLICT (normatividad_id, nombre_campo) DO NOTHING;

    -- 4. REGLAS LÓGICAS (Incluyendo las reglas estrictas de la página 34 "Validaciones Adicionales")
    
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_pla, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='peso' AND normatividad_id=v_guia_pla), 
     'LIMITE_PESO', 'RANGO_VALOR', '{"operador": "between", "min": 1, "max": 400}'::jsonb, 
     'El peso debe estar entre 1 y 400 kg.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_pla, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='sistolica' AND normatividad_id=v_guia_pla), 
     'LOGICA_PRESION_ARTERIAL', 'COMPARACION_CAMPOS', '{"operador": "greater_than_or_equal", "campo1": "sistolica", "campo2": "diastolica"}'::jsonb, 
     'La presión arterial sistólica no puede ser menor a la diastólica.', 'ERROR', v_fecha);

    -- Validación estricta por Edad y Sexo (Pag 34 del PDF) - (Nótese el uso correcto de campo_id como NULL)
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_pla, NULL, 
     'VALIDACION_EDAD_HOMBRES', 'LOGICA_COMPLEJA', '{"operador": "if_then", "condicion": {"campo": "sexoBiologico", "in": ["1", "3"]}, "accion": {"rango_edad": {"min": 10, "max": 70}}}'::jsonb, 
     'Si el paciente es hombre o intersexual, la edad permitida para atención de planificación familiar es entre 10 y 70 años.', 'ERROR', v_fecha);

    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_pla, NULL, 
     'VALIDACION_EDAD_MUJERES', 'LOGICA_COMPLEJA', '{"operador": "if_then", "condicion": {"campo": "sexoBiologico", "valor": "2"}, "accion": {"rango_edad": {"min": 10, "max": 59}}}'::jsonb, 
     'Si la paciente es mujer, la edad permitida para atención de planificación familiar es entre 10 y 59 años.', 'ERROR', v_fecha);

    -- Validación para bloquear Quirúrgico Femenino (OTB) en Hombres
    INSERT INTO public.sys_giis_restricciones (normatividad_id, campo_id, nombre_regla, tipo_regla, expresion, mensaje_error, nivel, fecha_inicio) VALUES
    (v_guia_pla, (SELECT id FROM public.sys_giis_campos WHERE nombre_campo='quirurgico' AND normatividad_id=v_guia_pla), 
     'BLOQUEO_CIRUGIA_HOMBRES', 'DEPENDENCIA_CONDICIONAL', '{"operador": "if_then", "condicion": {"campo": "sexoBiologico", "valor": "2"}, "accion": {"max_value": 0}}'::jsonb, 
     'Si el sexo biológico es mujer, para el método quirúrgico solo se debe registrar la opción "0 - Revisión posterior a la intervención".', 'ERROR', v_fecha);

END $$;