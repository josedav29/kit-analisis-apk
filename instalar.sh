#!/usr/bin/env bash
set -euo pipefail
# Instalación temporal: .cache no forma parte de la copia persistente de Arena.
ROOT="${REA_TMP_ROOT:-$HOME/.cache/rea-temporal}"
MODE="${1:-ghidra}"
if [[ "$MODE" != "rea" && "$MODE" != "ghidra" ]]; then
  echo "Uso: $0 [rea|ghidra]" >&2; exit 2
fi
for tool in node npm curl tar unzip sha256sum; do
  command -v "$tool" >/dev/null || { echo "Falta $tool" >&2; exit 1; }
done
mkdir -p "$ROOT"
if [[ ! -x "$ROOT/runtime/node_modules/node/bin/node" || ! -f "$ROOT/runtime/node_modules/rea-agents/scripts/rea.mjs" ]]; then
  mkdir -p "$ROOT/runtime"
  npm install --prefix "$ROOT/runtime" --save-exact node@24.22.3
  PATH="$ROOT/runtime/node_modules/node/bin:$PATH" npm install --prefix "$ROOT/runtime" --save-exact rea-agents@6.9.0
fi
if [[ "$MODE" == ghidra ]]; then
  [[ "$(uname -s)-$(uname -m)" == Linux-x86_64 ]] || { echo 'Las descargas fijadas requieren Linux x86_64.' >&2; exit 1; }
  download_checked() {
    local url="$1" expected="$2" file="$3"
    curl -fL --retry 2 --connect-timeout 20 "$url" -o "$file"
    echo "$expected  $file" | sha256sum -c -
  }
  if [[ ! -x "$ROOT/jdk/bin/java" ]]; then
    archive="$ROOT/jdk.tar.gz"
    download_checked 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz' 'd7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c' "$archive"
    mkdir -p "$ROOT/jdk"; tar -xzf "$archive" -C "$ROOT/jdk" --strip-components=1; rm -f "$archive"
  fi
  if [[ ! -f "$ROOT/ghidra_12.1.4_PUBLIC/support/analyzeHeadless" ]]; then
    archive="$ROOT/ghidra.zip"
    download_checked 'https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_12.1.4_build/ghidra_12.1.4_PUBLIC_20260921.zip' 'ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db' "$archive"
    unzip -q "$archive" -d "$ROOT"; rm -f "$archive"
  fi
fi
echo "Instalación temporal lista: $ROOT"
echo "Comprueba el estado con: $HOME/rea-kit/rea.sh doctor --json"
