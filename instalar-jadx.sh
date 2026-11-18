#!/usr/bin/env bash
set -euo pipefail
# El contenido de .cache es temporal y puede desaparecer entre mensajes.
ROOT="${APK_ANALYSIS_TMP_ROOT:-$HOME/.cache/apk-analysis}"
JADX="$ROOT/jadx-1.5.6/bin/jadx"
if [[ -f "$JADX" ]] && bash "$JADX" --version >/dev/null 2>&1; then
  echo "JADX disponible: $JADX"; exit 0
fi
for x in java curl unzip sha256sum; do
  command -v "$x" >/dev/null || { echo "Falta $x" >&2; exit 1; }
done
mkdir -p "$ROOT"
TMP="$(mktemp -d "$ROOT/.jadx.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
URL='https://github.com/skylot/jadx/releases/download/v1.5.6/jadx-1.5.6.zip'
SHA='545ea2be9c242511bc145755cf4bda2485ade42966e096f8b4d3da2a230e8974'
curl -fL --retry 2 --connect-timeout 20 "$URL" -o "$TMP/jadx.zip"
printf '%s  %s\n' "$SHA" "$TMP/jadx.zip" | sha256sum -c -
mkdir "$TMP/extracted"; unzip -q "$TMP/jadx.zip" -d "$TMP/extracted"
bash "$TMP/extracted/bin/jadx" --version
rm -rf "$ROOT/jadx-1.5.6"
mv "$TMP/extracted" "$ROOT/jadx-1.5.6"
echo "JADX instalado temporalmente: $JADX"
