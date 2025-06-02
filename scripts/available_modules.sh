#!/usr/bin/env bash
#
# scripts/available_modules.sh
# ----------------------------
# Genera avmod_results.txt con:
#   • Conteo de módulos instalados, cargados y no cargados
#   • Lista de módulos disponibles pero no cargados actualmente
# ---------------------------------------------------------------

set -euo pipefail

### 0 │ Ir al root del proyecto (padre de scripts/)
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
cd "$PROJECT_ROOT"

### 1 │ Archivos temporales
TMP_ALL=$(mktemp)
TMP_LOADED=$(mktemp)
trap 'rm -f "$TMP_ALL" "$TMP_LOADED"' EXIT

### 2 │ Listar módulos INSTALADOS 
find /lib/modules/$(uname -r) -type f -name '*.ko' \
    -exec basename {} .ko \; | sort -u > "$TMP_ALL"

### 3 │ Listar módulos actualmente cargados
lsmod | awk '{print $1}' | sort -u > "$TMP_LOADED"

### 4 │ Diferencia: disponibles – cargados
OUTPUT="avmod_results.txt"
NOT_LOADED=$(comm -23 "$TMP_ALL" "$TMP_LOADED")

### 5 │ Estadísticas y escritura
{
  echo "# Total installed : $(wc -l < "$TMP_ALL")"
  echo "# Active in RAM   : $(wc -l < "$TMP_LOADED")"
  echo "# Not loaded      : $(echo "$NOT_LOADED" | wc -l)"
  echo "# ------------------------------------"
  echo "$NOT_LOADED"
} > "$OUTPUT"

echo "[+] Resultado escrito en $OUTPUT"
