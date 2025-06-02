#!/usr/bin/env bash
#
# scripts/collect_lsmod.sh
# ------------------------
# • Captura tu salida de `lsmod` en lsmod_results/lsmod_<user>.txt
# • Genera todos los diffs posibles entre los archivos de esa carpeta
#   (uno por par; si hay 0-1 archivo no se crea nada)
# -----------------------------------------------------------------

set -euo pipefail

### 1 │ Ir siempre al root del proyecto (padre de scripts/)
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
cd "$PROJECT_ROOT"

### 2 │ Obtener nombre de usuario Git y capturar lsmod
mkdir -p lsmod_results
USER_GIT="$(git config --get user.email 2>/dev/null | cut -d'@' -f1 || true)"
USER_GIT="${USER_GIT:-$(whoami)}"
OUTFILE="lsmod_results/lsmod_${USER_GIT}.txt"

echo "[+] Guardando lsmod en $OUTFILE"
lsmod > "$OUTFILE"

### 3 │ Generar todos los diffs posibles
shopt -s nullglob
FILES=(lsmod_results/lsmod_*.txt)

if (( ${#FILES[@]} > 1 )); then
    echo "[+] Generando diffs en lsmod_results/diffs/"
    for ((i=0; i<${#FILES[@]}; i++)); do
        for ((j=i+1; j<${#FILES[@]}; j++)); do
            f1="${FILES[i]}"
            f2="${FILES[j]}"
            b1="$(basename "$f1" .txt)"
            b2="$(basename "$f2" .txt)"
            diff -u "$f1" "$f2" \
                > "lsmod_results/diff_${b1}_vs_${b2}.txt" || true
        done
    done
else
    echo "[i] Sólo hay ${#FILES[@]} archivo(s) en lsmod_results; no se crean diffs."
fi
