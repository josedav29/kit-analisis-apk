#!/usr/bin/env bash
set -euo pipefail
ROOT="${REA_TMP_ROOT:-$HOME/.cache/rea-temporal}"
NODE="$ROOT/runtime/node_modules/node/bin/node"
CLI="$ROOT/runtime/node_modules/rea-agents/scripts/rea.mjs"
if [[ ! -x "$NODE" || ! -f "$CLI" ]]; then
  echo "REA no está instalado en este entorno. Ejecuta: $HOME/rea-kit/instalar.sh rea" >&2; exit 1
fi
export PATH="$ROOT/runtime/node_modules/node/bin:$PATH"
if [[ -x "$ROOT/jdk/bin/java" && -f "$ROOT/ghidra_12.1.4_PUBLIC/support/analyzeHeadless" ]]; then
  export JAVA_HOME="${JAVA_HOME:-$ROOT/jdk}"
  export GHIDRA_INSTALL_DIR="${GHIDRA_INSTALL_DIR:-$ROOT/ghidra_12.1.4_PUBLIC}"
  export PATH="$JAVA_HOME/bin:$PATH"
fi
exec "$NODE" "$CLI" "$@"
