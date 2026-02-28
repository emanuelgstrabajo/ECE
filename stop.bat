@echo off
REM SIRES — Detener servidores (Windows)

title SIRES — Detener
echo Deteniendo servidores SIRES...
echo.

REM Matar procesos en puertos 3001 y 5173
FOR %%P IN (3001 5173) DO (
    FOR /F "tokens=5" %%i IN ('netstat -aon ^| findstr ":%%P "') DO (
        taskkill /PID %%i /F >NUL 2>&1
        echo   Puerto %%P liberado.
    )
)

REM Cerrar ventanas de cmd con titulo SIRES
taskkill /FI "WINDOWTITLE eq SIRES Backend" /F >NUL 2>&1
taskkill /FI "WINDOWTITLE eq SIRES Frontend" /F >NUL 2>&1

echo.
set /p STOP_DOCKER="Detener tambien Docker (PostgreSQL)? (S/N): "
IF /I "%STOP_DOCKER%"=="S" (
    docker-compose down
    echo   Docker detenido.
)

echo.
echo Servidores detenidos.
pause >NUL
