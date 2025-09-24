#!/usr/bin/env bash
set -euo pipefail

# Dependências
sudo dnf install -y curl cabextract fontconfig mkfontscale xorg-x11-font-utils unzip

DEST="/usr/share/fonts/msttcorefonts"
sudo mkdir -p "$DEST"

FONTS=(andale32 arial32 comic32 courie32 georgi32 impact32 times32 trebuc32)
for f in "${FONTS[@]}"; do
  echo "→ Baixando e extraindo $f.exe..."
  curl -sL "https://downloads.sourceforge.net/project/corefonts/the%20fonts/final/${f}.exe" \
    -o "/tmp/${f}.exe"
  sudo cabextract -q -d "$DEST" "/tmp/${f}.exe" || echo "⚠️ Falha ao extrair $f"
done

# Verdana (outra fonte, GitHub)
cd /volume
wget -O verdana.zip https://github.com/gr1zix/verdana/archive/refs/heads/main.zip
unzip -o verdana.zip
sudo mv verdana-main/fonts /usr/share/fonts/Verdana || true

# Atualiza cache de fontes
sudo mkfontscale "$DEST"
sudo mkfontdir   "$DEST"
sudo fc-cache -fv

echo "✅ Fontes instaladas em $DEST e Verdana em /usr/share/fonts/Verdana"
