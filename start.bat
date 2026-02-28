@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM SIRES — Script de arranque rapido (Windows)
REM Uso: Doble clic o ejecutar en CMD desde la carpeta del proyecto
REM ============================================================

title SIRES — Arranque del sistema
color 0B

echo.
echo  ==========================================
echo   SIRES - Sistema de Expediente Clinico
echo  ==========================================
echo.

SET ROOT_DIR=%~dp0
SET BACKEND_DIR=%ROOT_DIR%backend
SET FRONTEND_DIR=%ROOT_DIR%frontend
SET MIGRATION_FILE=%ROOT_DIR%docs\migrations\001_multi_unidad.sql
SET LOG_DIR=%ROOT_DIR%.logs
SET PGPASSWORD=postgres

IF NOT EXIST "%LOG_DIR%" mkdir "%LOG_DIR%"

REM ── PASO 1: Docker / PostgreSQL ──────────────────────────────
echo [1/4] Base de datos (PostgreSQL)...

docker-compose -f "%ROOT_DIR%docker-compose.yml" ps postgres 2>NUL | find "Up" >NUL
IF ERRORLEVEL 1 (
    echo   Iniciando contenedor PostgreSQL...
    docker-compose -f "%ROOT_DIR%docker-compose.yml" up -d postgres
    echo   Esperando que este lista la BD ^(10 segundos^)...
    timeout /t 10 /nobreak >NUL
) ELSE (
    echo   PostgreSQL ya esta corriendo.
)
echo.

REM ── PASO 2: Verificar migracion 001 ──────────────────────────
echo [2/4] Verificando migraciones...

psql -h 127.0.0.1 -U postgres -d ece_global -tAc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='adm_usuario_unidad_rol');" 2>NUL > "%TEMP%\migration_check.txt"
SET /p MIGRATED=<"%TEMP%\migration_check.txt"

IF "%MIGRATED%"=="t" (
    echo   Migracion 001 ya aplicada.
) ELSE (
    echo   ATENCION: Migracion 001 pendiente.
    echo.
    set /p RUN_MIGRATION="  Ejecutar migracion ahora? (S/N): "
    IF /I "!RUN_MIGRATION!"=="S" (
        echo   Aplicando migracion 001...
        psql -h 127.0.0.1 -U postgres -d ece_global -f "%MIGRATION_FILE%" -q
        IF ERRORLEVEL 1 (
            echo   ERROR al aplicar migracion. Revisa el archivo SQL.
        ) ELSE (
            echo   Migracion 001 aplicada correctamente.
        )
    ) ELSE (
        echo   Migracion omitida. Algunas funciones pueden no funcionar.
    )
)
echo.

REM ── PASO 3: Backend ──────────────────────────────────────────
echo [3/4] Iniciando Backend ^(puerto 3001^)...

IF NOT EXIST "%BACKEND_DIR%\node_modules" (
    echo   Instalando dependencias del backend...
    pushd "%BACKEND_DIR%"
    call npm install --silent
    popd
)

start "SIRES Backend" /min cmd /c "cd /d "%BACKEND_DIR%" && npm run dev > "%LOG_DIR%\backend.log" 2>&1"
echo   Backend iniciado. Log: .logs\backend.log
timeout /t 3 /nobreak >NUL
echo.

REM ── PASO 4: Frontend ─────────────────────────────────────────
echo [4/4] Iniciando Frontend ^(puerto 5173^)...

IF NOT EXIST "%FRONTEND_DIR%\node_modules" (
    echo   Instalando dependencias del frontend...
    pushd "%FRONTEND_DIR%"
    call npm install --silent
    popd
)

start "SIRES Frontend" /min cmd /c "cd /d "%FRONTEND_DIR%" && npm run dev > "%LOG_DIR%\frontend.log" 2>&1"
echo   Frontend iniciado. Log: .logs\frontend.log
timeout /t 4 /nobreak >NUL
echo.

REM ── Resumen ──────────────────────────────────────────────────
echo  ==========================================
echo   SIRES esta listo para usar
echo  ==========================================
echo   Frontend  ^> http://localhost:5173
echo   Backend   ^> http://localhost:3001
echo   pgAdmin   ^> http://localhost:5050
echo  ------------------------------------------
echo   Usuario:  admin@eceglobal.mx
echo   Password: (la configurada en el setup)
echo  ==========================================
echo.

REM Abrir browser
start "" "http://localhost:5173"

echo  Presiona cualquier tecla para cerrar ESTE script.
echo  Los servidores seguiran corriendo en sus ventanas.
pause >NUL
