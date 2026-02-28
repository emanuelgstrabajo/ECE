#!/usr/bin/env bash
# SIRES — Detener todos los servicios

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

echo -e "${RED}Deteniendo SIRES...${NC}"

# Matar backend y frontend por puerto
for PORT in 3001 5173; do
  PID=$(lsof -ti tcp:$PORT 2>/dev/null)
  if [ -n "$PID" ]; then
    kill "$PID" 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Puerto $PORT liberado (PID $PID)"
  fi
done

# Detener Docker si se quiere
read -rp "¿Detener también Docker (PostgreSQL)? (s/N): " resp
if [[ "$resp" =~ ^[Ss]$ ]]; then
  cd "$(dirname "${BASH_SOURCE[0]}")"
  docker-compose down
  echo -e "  ${GREEN}✓${NC} Docker detenido"
fi

echo -e "${GREEN}Listo.${NC}"
