#!/usr/bin/env bash
# ============================================================
# SIRES — Script de arranque rápido (Linux / macOS / WSL)
# Uso: ./start.sh
# ============================================================

set -e

# ── Colores ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

OK="${GREEN}✓${NC}"; WARN="${YELLOW}!${NC}"; ERR="${RED}✗${NC}"; INFO="${CYAN}→${NC}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"
MIGRATION_FILE="$ROOT_DIR/docs/migrations/001_multi_unidad.sql"
LOG_DIR="$ROOT_DIR/.logs"
BACKEND_LOG="$LOG_DIR/backend.log"
FRONTEND_LOG="$LOG_DIR/frontend.log"

mkdir -p "$LOG_DIR"

echo ""
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║      SIRES — Arranque del sistema    ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# ── Función: matar procesos al salir ─────────────────────────
BACKEND_PID=""
FRONTEND_PID=""
cleanup() {
  echo ""
  echo -e "${WARN} Deteniendo servidores..."
  [ -n "$BACKEND_PID" ]  && kill "$BACKEND_PID"  2>/dev/null && echo -e "  ${OK} Backend detenido"
  [ -n "$FRONTEND_PID" ] && kill "$FRONTEND_PID" 2>/dev/null && echo -e "  ${OK} Frontend detenido"
  exit 0
}
trap cleanup SIGINT SIGTERM

# ── PASO 1: Docker / PostgreSQL ──────────────────────────────
echo -e "${BOLD}[1/4] Base de datos (PostgreSQL)${NC}"

if ! command -v docker &>/dev/null; then
  echo -e "  ${WARN} Docker no encontrado. Asumiendo que PostgreSQL está corriendo externamente."
else
  cd "$ROOT_DIR"
  if ! docker-compose ps postgres 2>/dev/null | grep -q "Up"; then
    echo -e "  ${INFO} Iniciando contenedor PostgreSQL..."
    docker-compose up -d postgres
  else
    echo -e "  ${OK} PostgreSQL ya está corriendo"
  fi

  echo -n "  ${INFO} Esperando que esté lista la BD"
  for i in $(seq 1 20); do
    if docker-compose exec -T postgres pg_isready -U postgres -d ece_global &>/dev/null 2>&1; then
      echo -e " ${GREEN}lista${NC}"
      break
    fi
    echo -n "."
    sleep 1
    if [ "$i" -eq 20 ]; then
      echo -e " ${ERR} Timeout. Verifica Docker."
      exit 1
    fi
  done
fi

# ── PASO 2: Migraciones ──────────────────────────────────────
echo ""
echo -e "${BOLD}[2/4] Migraciones${NC}"

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-ece_global}"
PGPASSWORD="${DB_PASSWORD:-postgres}"
export PGPASSWORD

check_migration_001() {
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
    "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='adm_usuario_unidad_rol');" 2>/dev/null
}

if command -v psql &>/dev/null; then
  MIGRATED=$(check_migration_001 2>/dev/null || echo "f")
  if [ "$MIGRATED" = "t" ]; then
    echo -e "  ${OK} Migración 001 (multi-unidad) ya aplicada"
  else
    echo -e "  ${WARN} Migración 001 pendiente: adm_usuario_unidad_rol no existe"
    echo ""
    read -rp "  ¿Ejecutar migración ahora? (S/n): " resp
    resp="${resp:-S}"
    if [[ "$resp" =~ ^[Ss]$ ]]; then
      echo -e "  ${INFO} Creando backup previo..."
      BACKUP_FILE="$ROOT_DIR/docs/backups/pre-migration-001_$(date +%Y%m%d_%H%M).sql"
      mkdir -p "$ROOT_DIR/docs/backups"
      pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null && \
        echo -e "  ${OK} Backup: $BACKUP_FILE" || \
        echo -e "  ${WARN} No se pudo crear backup, continuando de todas formas..."
      echo -e "  ${INFO} Aplicando migración 001..."
      psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$MIGRATION_FILE" -q && \
        echo -e "  ${OK} Migración 001 aplicada correctamente" || \
        echo -e "  ${ERR} Error al aplicar migración — revisa $MIGRATION_FILE"
    else
      echo -e "  ${WARN} Migración omitida. Algunas funciones pueden no funcionar."
    fi
  fi
else
  echo -e "  ${WARN} psql no encontrado — no se puede verificar migraciones"
  echo -e "       Ejecuta manualmente: psql -U postgres -d ece_global -f $MIGRATION_FILE"
fi

# ── PASO 3: Backend ──────────────────────────────────────────
echo ""
echo -e "${BOLD}[3/4] Backend (Express — puerto 3001)${NC}"

if [ ! -d "$BACKEND_DIR/node_modules" ]; then
  echo -e "  ${INFO} Instalando dependencias del backend..."
  cd "$BACKEND_DIR" && npm install --silent
fi

cd "$BACKEND_DIR"
npm run dev > "$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

echo -n "  ${INFO} Esperando que responda"
for i in $(seq 1 15); do
  sleep 1
  if curl -sf http://localhost:3001/api/auth/me > /dev/null 2>&1 || \
     grep -q "Servidor SIRES corriendo\|listening\|started" "$BACKEND_LOG" 2>/dev/null; then
    echo -e " ${GREEN}listo${NC} (PID $BACKEND_PID)"
    break
  fi
  echo -n "."
  if [ "$i" -eq 15 ]; then
    echo -e " ${WARN} (puede estar iniciando aún)"
    echo -e "       Log: tail -f $BACKEND_LOG"
  fi
done

# ── PASO 4: Frontend ─────────────────────────────────────────
echo ""
echo -e "${BOLD}[4/4] Frontend (Vite — puerto 5173)${NC}"

if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
  echo -e "  ${INFO} Instalando dependencias del frontend..."
  cd "$FRONTEND_DIR" && npm install --silent
fi

cd "$FRONTEND_DIR"
npm run dev > "$FRONTEND_LOG" 2>&1 &
FRONTEND_PID=$!

echo -n "  ${INFO} Esperando que responda"
for i in $(seq 1 15); do
  sleep 1
  if grep -q "Local:.*http" "$FRONTEND_LOG" 2>/dev/null; then
    echo -e " ${GREEN}listo${NC} (PID $FRONTEND_PID)"
    break
  fi
  echo -n "."
  if [ "$i" -eq 15 ]; then
    echo -e " ${WARN} (puede estar iniciando aún)"
    echo -e "       Log: tail -f $FRONTEND_LOG"
  fi
done

# ── Resumen ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║   SIRES está listo para usar                 ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║${NC}  Frontend  → ${CYAN}http://localhost:5173${NC}         ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}║${NC}  Backend   → ${CYAN}http://localhost:3001${NC}         ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}║${NC}  pgAdmin   → ${CYAN}http://localhost:5050${NC}         ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║${NC}  Usuario: admin@eceglobal.mx               ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}║${NC}  Logs:    .logs/backend.log                ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}║${NC}           .logs/frontend.log               ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║${NC}  Presiona ${BOLD}Ctrl+C${NC} para detener todo         ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Abrir browser si es posible
if command -v xdg-open &>/dev/null; then
  sleep 1 && xdg-open "http://localhost:5173" &>/dev/null &
elif command -v open &>/dev/null; then
  sleep 1 && open "http://localhost:5173" &>/dev/null &
fi

# Mantener el script vivo mostrando logs del backend
echo -e "${CYAN}── Backend logs (Ctrl+C para salir) ──────────────${NC}"
tail -f "$BACKEND_LOG" &
wait $BACKEND_PID
