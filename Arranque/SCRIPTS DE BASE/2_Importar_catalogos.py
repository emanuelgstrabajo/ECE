import pandas as pd
import os
import psycopg2
from psycopg2 import extras, errors
import json

# Configuración con Timeout de 10 segundos para evitar bloqueos infinitos
DB_CONFIG = {
    "host": "localhost", "port": 5432,
    "dbname": "ece_global", "user": "postgres", "password": "postgres",
    "options": "-c statement_timeout=10000" 
}
R_CAT = r"C:\ECE Global\Arranque\docs\GIIS\catalogos"

def limpiar(val):
    if pd.isna(val) or str(val).strip().upper() == 'NAN': 
        return None
    return str(val).strip()

def encontrar_archivo(directorio, substring):
    """Busca un archivo asegurando que el nombre contenga la palabra clave."""
    if not os.path.exists(directorio): return None
    for f in os.listdir(directorio):
        if substring.upper() in f.upper() and f.endswith(('.xls', '.xlsx', '.xlsb')):
            return os.path.join(directorio, f)
    return None

def registrar_evento(cursor, archivo, tabla, criterio):
    """Registra el evento en la bitácora y adopción para la Guía Base."""
    cursor.execute("""
        INSERT INTO sys_registro_catalogos (archivo_origen, tabla_destino, criterios_carga)
        VALUES (%s, %s, %s) RETURNING id;
    """, (archivo, tabla, criterio))
    reg_id = cursor.fetchone()[0]
    
    cursor.execute("""
        INSERT INTO sys_adopcion_catalogos (normatividad_id, catalogo_nombre, registro_importacion_id, comentarios)
        VALUES ((SELECT id FROM sys_normatividad_giis WHERE clave = 'DGIS-BASE'), %s, %s, %s);
    """, (tabla, reg_id, f"Carga inicial automatizada de {archivo}"))
    return reg_id

def dicc_id(cursor, cod, nom):
    cursor.execute("""
        INSERT INTO gui_diccionarios (codigo, nombre) VALUES (%s, %s) 
        ON CONFLICT (codigo) DO UPDATE SET nombre = EXCLUDED.nombre RETURNING id;
    """, (cod, nom))
    return cursor.fetchone()[0]

def main():
    print("=========================================================")
    print("🚀 IMPORTADOR ECE GLOBAL V6.4 - VERSIÓN DEFINITIVA (37 ARCHIVOS)")
    print("=========================================================")
    
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        print("🧹 Limpiando tablas de manera segura (Max 10 segundos de espera)...")
        cursor.execute("""
            DELETE FROM clin_atenciones;
            DELETE FROM clin_citas;
            DELETE FROM clin_pacientes;
            DELETE FROM adm_personal_salud;
            DELETE FROM adm_unidades_medicas;
            DELETE FROM cat_cie10_diagnosticos;
            DELETE FROM cat_cie9_procedimientos;
            DELETE FROM cat_asentamientos_cp;
            DELETE FROM cat_municipios;
            DELETE FROM cat_entidades;
            DELETE FROM cat_matriz_personal_servicio;
            DELETE FROM cat_servicios_atencion;
            DELETE FROM cat_tipos_personal;
            
            -- Se eliminan opciones de diccionarios
            DELETE FROM gui_diccionario_opciones WHERE diccionario_id IN (
                SELECT id FROM gui_diccionarios WHERE codigo NOT LIKE '%URG%' AND codigo NOT LIKE '%HOSP%' AND codigo NOT LIKE '%SIS%' AND codigo NOT LIKE '%LES%' AND codigo NOT LIKE '%TRIAGE%' AND codigo NOT LIKE '%SGSI%'
            );
            DELETE FROM sys_adopcion_catalogos WHERE comentarios LIKE '%Carga inicial automatizada%';
            DELETE FROM sys_registro_catalogos WHERE criterios_carga NOT LIKE '%SQL%';
        """)

        # 1. GEOGRAFÍA NACIONAL
        print("\n🌍 Cargando Geografía (Entidades y Municipios)...")
        ruta_ent = encontrar_archivo(R_CAT, "ENTIDAD_FEDERATIVA")
        if ruta_ent:
            registrar_evento(cursor, "ENTIDAD_FEDERATIVA/MUNICIPIOS", "Geografía", "Relación Entidad-Municipio V5")
            ent = pd.read_excel(ruta_ent, dtype=str)
            for _, r in ent.iterrows(): 
                cursor.execute("INSERT INTO cat_entidades (clave, nombre, abreviatura) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING", 
                               (limpiar(r.get('CATALOG_KEY')), limpiar(r.get('ENTIDAD_FEDERATIVA')), limpiar(r.get('ABREVIATURA'))))
        
        ruta_mun = encontrar_archivo(R_CAT, "MUNICIPIOS")
        if ruta_mun:
            mun = pd.read_excel(ruta_mun, dtype=str)
            for _, r in mun.iterrows(): 
                cursor.execute("INSERT INTO cat_municipios (entidad_id, clave, nombre) SELECT id, %s, %s FROM cat_entidades WHERE clave = %s ON CONFLICT DO NOTHING", 
                               (limpiar(r.get('CATALOG_KEY')), limpiar(r.get('MUNICIPIO')), limpiar(r.get('EFE_KEY'))))
        
        ruta_cp = encontrar_archivo(R_CAT, "CODIGO_POSTAL")
        if ruta_cp:
            print("📬 Cargando Códigos Postales...")
            registrar_evento(cursor, os.path.basename(ruta_cp), "cat_asentamientos_cp", "Extracción masiva de 32 estados")
            xl_cp = pd.ExcelFile(ruta_cp)
            for sheet in xl_cp.sheet_names:
                if sheet.lower() == 'nota': continue
                df_cp = pd.read_excel(xl_cp, sheet_name=sheet, dtype=str)
                v_cp = [(limpiar(r.get('d_codigo')), limpiar(r.get('d_asenta')), limpiar(r.get('d_tipo_asenta')), limpiar(r.get('d_zona')), limpiar(r.get('c_estado')), limpiar(r.get('c_mnpio'))) for _, r in df_cp.iterrows()]
                extras.execute_batch(cursor, """
                    INSERT INTO cat_asentamientos_cp (municipio_id, codigo_postal, nombre_colonia, tipo_asentamiento, zona) 
                    SELECT m.id, %s, %s, %s, %s FROM cat_municipios m JOIN cat_entidades e ON m.entidad_id = e.id 
                    WHERE e.clave = %s AND m.clave = %s
                    ON CONFLICT DO NOTHING
                """, v_cp)

        # 2. GIGANTES CLÍNICOS (CIE-10 y CIE-9)
        print("\n🩺 Cargando Catálogos Clínicos...")
        ruta_cie10 = encontrar_archivo(R_CAT, "DIAGNOSTICOS")
        if ruta_cie10:
            registrar_evento(cursor, os.path.basename(ruta_cie10), "cat_cie10_diagnosticos", "CIE-10 con Metadatos JSONB")
            df10 = pd.read_excel(ruta_cie10, dtype=str).fillna('')
            v10 = []
            for i, r in df10.iterrows():
                ck = limpiar(r.get('CATALOG_KEY')) or f"S/C-{i}"
                meta = {col: limpiar(r.get(col)) for col in df10.columns if col not in ['CATALOG_KEY', 'NOMBRE', 'LSEX', 'LINF', 'LSUP', 'ES_SUIVE_MORB']}
                v10.append((ck, limpiar(r.get('NOMBRE')), limpiar(r.get('LSEX')) or 'NO', limpiar(r.get('LINF')), limpiar(r.get('LSUP')), True if str(r.get('ES_SUIVE_MORB')).upper() == 'SI' else False, json.dumps(meta)))
            extras.execute_batch(cursor, "INSERT INTO cat_cie10_diagnosticos (catalog_key, nombre, lsex, linf, lsup, es_suive_morb, metadatos) VALUES (%s, %s, %s, %s, %s, %s, %s) ON CONFLICT DO NOTHING", v10, 1000)
            print(f"   ✔️ CIE-10 cargado ({len(v10)} registros)")

        ruta_cie9 = encontrar_archivo(R_CAT, "PROCEDIMIENTO")
        if ruta_cie9:
            registrar_evento(cursor, os.path.basename(ruta_cie9), "cat_cie9_procedimientos", "CIE-9 Procedimientos")
            df_p = pd.read_excel(ruta_cie9, sheet_name='Catálogo-CIE9MC', dtype=str)
            v_p = [(limpiar(r.get('CATALOG_KEY')) or f"S/C-{i}", limpiar(r.get('PRO_NOMBRE')), limpiar(r.get('SEX_TYPE')) or '0', limpiar(r.get('PROCEDIMIENTO_TYPE')) or 'T') for i, r in df_p.iterrows() if limpiar(r.get('PRO_NOMBRE'))]
            extras.execute_batch(cursor, "INSERT INTO cat_cie9_procedimientos (catalog_key, nombre, sex_type, procedimiento_type) VALUES (%s, %s, %s, %s) ON CONFLICT DO NOTHING", v_p)
            print(f"   ✔️ CIE-9 cargado ({len(v_p)} registros)")

        # 3. UNIDADES MÉDICAS (CLUES)
        print("\n🏥 Cargando Directorio CLUES...")
        ruta_clues = encontrar_archivo(R_CAT, "ESTABLECIMIENTO_SALUD")
        if ruta_clues:
            registrar_evento(cursor, os.path.basename(ruta_clues), "adm_unidades_medicas", "Directorio Maestro con Tags Satélite")
            df_clues = pd.read_excel(ruta_clues, dtype=str)
            v_clues = [(limpiar(r.get('CLUES')), limpiar(r.get('NOMBRE DE LA UNIDAD')), limpiar(r.get('NOMBRE TIPO ESTABLECIMIENTO')), limpiar(r.get('ESTATUS DE OPERACION'))) for _, r in df_clues.iterrows() if limpiar(r.get('CLUES'))]
            extras.execute_batch(cursor, "INSERT INTO adm_unidades_medicas (clues, nombre, tipo_unidad, estatus_operacion) VALUES (%s, %s, %s, %s) ON CONFLICT DO NOTHING", v_clues, 1000)

            for tag_pref, col_tag in [("DIRECTORIO_CLUES_CON_ESPIROMETRO", "tiene_espirometro"), ("DIRECTORIO_SERVICIOS_AMIGABLES", "es_servicio_amigable")]:
                ruta_tag = encontrar_archivo(R_CAT, tag_pref)
                if ruta_tag:
                    df_tag = pd.read_excel(ruta_tag, dtype=str)
                    cl_col = next((c for c in df_tag.columns if 'CLUES' in str(c).upper()), None)
                    if cl_col:
                        v_tag = [(limpiar(r[cl_col]),) for _, r in df_tag.iterrows() if limpiar(r[cl_col])]
                        extras.execute_batch(cursor, f"UPDATE adm_unidades_medicas SET {col_tag} = TRUE WHERE clues = %s", v_tag)

        # 4. MATRICES SIS
        print("\n🧮 Cargando Matrices SIS...")
        registrar_evento(cursor, "MATRICES_SIS", "cat_matriz_personal_servicio", "Relación Personal-Servicio")
        ruta_tp = encontrar_archivo(R_CAT, "TIPO_PERSONAL-SIS")
        if ruta_tp:
            df_tp = pd.read_excel(ruta_tp, sheet_name='TIPO_PERSONAL', dtype=str)
            extras.execute_batch(cursor, "INSERT INTO cat_tipos_personal (clave, descripcion) VALUES (%s, %s) ON CONFLICT DO NOTHING", [(limpiar(r.get('CATALOG_KEY')), limpiar(r.get('TIPO_PERSONAL'))) for _, r in df_tp.iterrows() if limpiar(r.get('CATALOG_KEY'))])

        matrices = ["SERVICIOS_ATENCION_POR_TIPO_PERSONAL_SIS-CE", "SERVICIOS_ATENCION_POR_TIPO_PERSONAL_SIS-DET", "SERVICIOS_ATENCION_POR_TIPO_PERSONAL_SIS-PF", "SERVICIOS_ATENCION_POR_TIPO_PERSONAL_SIS-SB", "SERVICIOS_ATENCION_POR_TIPO_PERSONAL_SIS-SM"]
        for prefijo in matrices:
            ruta_m = encontrar_archivo(R_CAT, prefijo)
            if ruta_m:
                xl_m = pd.ExcelFile(ruta_m)
                for sheet in xl_m.sheet_names:
                    df_m = pd.read_excel(xl_m, sheet_name=sheet, header=1, dtype=str).fillna('')
                    if 'SERVICIOS_ATENCION' in df_m.columns:
                        for _, s in df_m[['CATALOG_KEY', 'SERVICIOS_ATENCION']].drop_duplicates().iterrows():
                            if limpiar(s.get('CATALOG_KEY')): cursor.execute("INSERT INTO cat_servicios_atencion (clave, descripcion) VALUES (%s, %s) ON CONFLICT DO NOTHING", (limpiar(s.get('CATALOG_KEY')), limpiar(s.get('SERVICIOS_ATENCION'))))
                        cols_p = [c for c in df_m.columns if '-' in str(c)]
                        df_melted = pd.melt(df_m, id_vars=['CATALOG_KEY'], value_vars=cols_p, var_name='P', value_name='V')
                        for _, row in df_melted[df_melted['V'].astype(str).str.strip().str.upper() == 'X'].iterrows():
                            cursor.execute("INSERT INTO cat_matriz_personal_servicio (tipo_personal_id, servicio_atencion_id) SELECT tp.id, sa.id FROM cat_tipos_personal tp, cat_servicios_atencion sa WHERE tp.clave = %s AND sa.clave = %s ON CONFLICT DO NOTHING;", (row['P'].split('-')[0].strip(), limpiar(row.get('CATALOG_KEY'))))
                        break

        # 5. DICCIONARIOS GENÉRICOS
        print("\n📖 Cargando Diccionarios Genéricos (Auto-detectando cabeceras sucias)...")
        registrar_evento(cursor, "VARIOS_EXCEL", "gui_diccionario_opciones", "Carga integral de catálogos secundarios")
        
        mega_diccionarios = {
            "SEXO": ("SEXO", "CATALOG_KEY", "DESCRIPCION"),
            "AFILIACION": ("AFILIACION", "CATALOG_KEY", "DESCRIPCIÓN LARGA"),
            "ESCOLARIDAD": ("ESCOLARIDAD", "CATALOG_KEY", "ESCOLARIDAD"),
            "ESTADO_CONYUGAL": ("ESTADO_CONYUGAL", "CATALOG_KEY", "ESTADO_CONYUGAL"),
            "RELIGION": ("CAT_RELIGION", "CLAVE RELIGION", "RELIGIÓN"),
            "NACIONALIDAD": ("CAT_NACIONALIDADES", "clave nacionalidad", "pais"),
            "PAIS": ("PAIS", "CATALOG_KEY", "DESCRIPCION"),
            "LOCALIDADES": ("LOCALIDADES", "CVEGEO", "LOCALIDAD"),
            "CIF": ("CIF", "Código", "Descripción"),
            "AGENTE_LESION": ("AGENTE_LESION", "CATALOG_KEY", "AGENTE_LESION"),
            "AREA_ANATOMICA": ("AREA_ANATOMICA", "CATALOG_KEY", "AREA_ANATOMICA"),
            "CONSECUENCIA_LESION": ("CONSECUENCIA_LESION", "CATALOG_KEY", "CONSECUENCIA_LESION"),
            "ESPECIALIDADES": ("ESPECIALIDADES", "CATALOG_KEY", "ESPECIALIDAD"),
            "FORMACION_ACADEMICA": ("FORMACION_ACADEMICA", "CATALOG_KEY", "DESCRIPCION"),
            "LENGUA_INDIGENA": ("LENGUA_INDIGENA", "CATALOG_KEY", "LENGUA_INDIGENA"),
            "MORFOLOGIA": ("MORFOLOGIA", "CATALOG_KEY", "DESCRIPCION"),
            "SITIO_LESION": ("SITIO_OCURRENCIA", "CATALOG_KEY", "DESCRIPCION"), # <-- Ya arreglado en la anterior
            "TIPO_ASENTAMIENTO": ("TIPO_ASENTAMIENTO", "CATALOG_KEY", "DESCRIPCION"),
            "TIPO_VIALIDAD": ("TIPO_VIALIDAD", "CATALOG_KEY", "DESCRIPCION")
        }
        
        for cod, (prefijo, col_k, col_v) in mega_diccionarios.items():
            ruta = encontrar_archivo(R_CAT, prefijo)
            if ruta:
                d_id = dicc_id(cursor, cod, cod)
                df = pd.read_excel(ruta, dtype=str, skiprows=3 if cod == 'CIF' else 0)
                
                # Auto-detectar cabeceras en archivos sucios de DGIS
                if any('UNNAMED' in str(c).upper() for c in df.columns) or any('SECRETAR' in str(c).upper() for c in df.columns):
                    for idx, row_vals in df.head(15).iterrows():
                        vals_upper = [str(v).strip().upper() for v in row_vals.values if pd.notna(v)]
                        if 'CATALOG_KEY' in vals_upper or 'DESCRIPCION' in vals_upper or col_k.upper() in vals_upper or col_v.upper() in vals_upper:
                            df.columns = [str(c).strip().upper() for c in row_vals.values]
                            df = df.iloc[idx+1:]
                            break
                
                df.columns = [str(c).strip().upper().replace('Ó','O').replace('Í','I') for c in df.columns]
                col_k_norm = col_k.strip().upper().replace('Ó','O')
                col_v_norm = col_v.strip().upper().replace('Ó','O')
                
                v_items = []
                for i, r in df.iterrows():
                    clave = limpiar(r.get(col_k_norm)) or limpiar(r.get('CATALOG_KEY')) or limpiar(r.get('CLAVE'))
                    if not clave and len(df.columns) > 0: 
                        clave = limpiar(r.iloc[0])
                    if not clave: 
                        clave = f"S/C-{i}"
                        
                    val = limpiar(r.get(col_v_norm)) or limpiar(r.get('DESCRIPCION')) or limpiar(r.get('NOMBRE')) or limpiar(r.get(cod.upper()))
                    if not val and len(df.columns) > 1:
                        val = limpiar(r.iloc[1])
                        
                    if not val: continue
                    v_items.append((d_id, clave, val))
                
                if v_items:
                    extras.execute_batch(cursor, "INSERT INTO gui_diccionario_opciones (diccionario_id, clave, valor) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING", v_items, 1000)
                    print(f"   ✔️ {cod} cargado ({len(v_items)} registros)")
                else:
                    print(f"   ⚠️ {cod}: Sin datos válidos. Cabeceras detectadas: {list(df.columns)}")
            else:
                print(f"   ❌ {cod}: No se encontró archivo con prefijo '{prefijo}'")

        # Casos Especiales: Medicamentos
        ruta_med = encontrar_archivo(R_CAT, "MEDICAMENTOS")
        if ruta_med:
            print("\n💊 Cargando Medicamentos (Clave Compuesta)...")
            df_med = pd.read_excel(ruta_med, dtype=str)
            d_id = dicc_id(cursor, "MEDICAMENTOS", "MEDICAMENTOS")
            v_med = []
            for i, r in df_med.iterrows():
                c_main, c_sub = limpiar(r.get("CLAVE O CODIGO")), limpiar(r.get("SUBCLAVE O CODIGO"))
                val = limpiar(r.get("DESCRIPCION COMPLETA")) or limpiar(r.get("DESCRIPCION"))
                if not val: continue
                clave = f"{c_main}-{c_sub}" if c_main and c_sub and c_sub.upper() not in ['ND', 'N/A'] else (c_main or f"S/C-{i}")
                v_med.append((d_id, clave, val))
            extras.execute_batch(cursor, "INSERT INTO gui_diccionario_opciones (diccionario_id, clave, valor) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING", v_med, 1000)
            print(f"   ✔️ MEDICAMENTOS cargado ({len(v_med)} registros)")

        # Casos Especiales: Jurisdicciones
        ruta_jur = encontrar_archivo(R_CAT, "JURISDICCION")
        if ruta_jur:
            print("\n🗺️ Cargando Jurisdicciones (Clave Compuesta)...")
            df_jur = pd.read_excel(ruta_jur, dtype=str)
            d_id = dicc_id(cursor, "JURISDICCIONES", "JURISDICCIONES")
            v_jur = []
            
            # Auto-detectar columnas de forma más agresiva por ser un caso súper especial de DGIS
            for i, r in df_jur.iterrows():
                c_ent = limpiar(r.get('CLAVE_ENTIDAD')) or limpiar(r.get('ENTIDAD'))
                c_jur = limpiar(r.get('CLAVE_JURISDICCION')) or limpiar(r.get('JURISDICCION'))
                
                # --- SOLUCIÓN PARA LAS JURISDICCIONES ---
                val = limpiar(r.get('DESCRIPCION_JURISDICCION')) or limpiar(r.get('NOMBRE_JURISDICCION')) or limpiar(r.get('DESCRIPCION')) or limpiar(r.get('JURISDICCION')) or (limpiar(r.iloc[2]) if len(df_jur.columns) > 2 else None)
                
                if not val: continue
                
                clave = f"{c_ent}-{c_jur}" if c_ent and c_jur else (limpiar(r.get('CATALOG_KEY')) or f"S/C-{i}")
                v_jur.append((d_id, clave, val))
                
            if v_jur:
                extras.execute_batch(cursor, "INSERT INTO gui_diccionario_opciones (diccionario_id, clave, valor) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING", v_jur, 1000)
                print(f"   ✔️ JURISDICCIONES cargado ({len(v_jur)} registros)")
            else:
                print("   ⚠️ JURISDICCIONES: Archivo encontrado, pero no se detectaron las columnas de descripción.")

        # 6. ENLACE FINAL A NORMATIVIDAD
        print("\n🔗 Enlazando carga con Guía DGIS-BASE...")
        cursor.execute("""
            INSERT INTO rel_normatividad_opciones (normatividad_id, opcion_id)
            SELECT (SELECT id FROM sys_normatividad_giis WHERE clave = 'DGIS-BASE'), o.id 
            FROM gui_diccionario_opciones o
            JOIN gui_diccionarios d ON o.diccionario_id = d.id
            ON CONFLICT DO NOTHING;
        """)

        conn.commit()
        print("\n🎉 ¡ÉXITO TOTAL! Base de datos actualizada correctamente. 🎉")

    except errors.QueryCanceled:
        conn.rollback()
        print("\n⏳ ❌ ERROR DE TIMEOUT (BASE DE DATOS BLOQUEADA)")
        print("El script se detuvo porque PostgreSQL no le dio permiso. Cierra tus ventanas de pgAdmin/DBeaver.")
        
    except Exception as e:
        conn.rollback()
        print(f"\n❌ ERROR CRÍTICO: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()