@echo off
REM ============================================================
REM  SIRES — Backup previo + Migración 001_multi_unidad
REM  Ejecutar desde: C:\ECE Global\
REM  Requiere: Docker Desktop corriendo
REM ============================================================

echo.
echo =====================================================
echo  SIRES — Migración 001: Modelo Multi-Unidad
echo =====================================================
echo.

REM Verificar que Docker está corriendo
docker ps >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Desktop no está corriendo. Ábrelo primero.
    pause
    exit /b 1
)

REM Verificar que el contenedor postgres existe
docker ps --filter "name=sires_postgres" --format "{{.Names}}" | findstr "sires_postgres" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] El contenedor sires_postgres no está corriendo.
    echo         Ejecuta primero: docker compose up -d
    pause
    exit /b 1
)

echo [1/3] Creando backup de seguridad...
docker exec sires_postgres pg_dump -U postgres ece_global > docs\backups\pre-migration-multi-unidad.sql
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Falló el backup. Abortando.
    pause
    exit /b 1
)
echo      Backup guardado en: docs\backups\pre-migration-multi-unidad.sql
echo.

echo [2/3] Ejecutando migración 001_multi_unidad.sql...
docker exec -i sires_postgres psql -U postgres -d ece_global < docs\migrations\001_multi_unidad.sql
if %ERRORLEVEL% neq 0 (
    echo [ERROR] La migración falló.
    echo         Puedes restaurar el backup con:
    echo         docker exec -i sires_postgres psql -U postgres -d ece_global ^< docs\backups\pre-migration-multi-unidad.sql
    pause
    exit /b 1
)
echo.

echo [3/3] Verificando resultado...
docker exec sires_postgres psql -U postgres -d ece_global -c "\dt adm_usuario_unidad_rol"
echo.

echo =====================================================
echo  Migracion completada exitosamente!
echo =====================================================
echo.
pause
