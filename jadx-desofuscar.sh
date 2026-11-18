#!/usr/bin/env bash
set -euo pipefail
ROOT="${APK_ANALYSIS_TMP_ROOT:-$HOME/.cache/apk-analysis}"
JADX="$ROOT/jadx-1.5.6/bin/jadx"
if [[ ! -f "$JADX" ]]; then
  echo 'JADX no disponible; instala con: bash /home/user/rea-kit/instalar-jadx.sh' >&2; exit 1
fi
# Mantener ejecución acotada. La deofuscación genera alias, no nombres originales garantizados.
export JADX_OPTS="${JADX_OPTS:--Xmx768m}"
exec bash "$JADX" --deobf --deobf-cfg-file-mode ignore --threads-count 2 "$@"
