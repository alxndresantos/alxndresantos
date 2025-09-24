#!/usr/bin/env bash
set -euo pipefail
sudo dnf install -y curl cabextract fontconfig mkfontscale xorg-x11-font-utils
DEST="/usr/share/fonts/msttcorefonts"
sudo mkdir -p "$DEST"
FONTS=(andale32 arial32 comic32 courie32 georgi32 impact32 times32 trebuc32 verdana32 webdin32)
for f in "${FONTS[@]}"; do
  echo "→ Baixando e extraindo $f.exe..."
  curl -sL "https://downloads.sourceforge.net/project/corefonts/the%20fonts/final/${f}.exe" \
	-o "/tmp/${f}.exe"
  sudo cabextract -q -d "$DEST" "/tmp/${f}.exe"
done
cd /volume
wget --content-disposition https://github.com/gr1zix/verdana/archive/refs/heads/main.zip
unzip verdana-main.zip
mv verdana-main/fonts /usr/share/fonts/Verdana

sudo mkfontscale "$DEST"
sudo mkfontdir   "$DEST"
sudo fc-cache -fv
echo "✅ Fontes instaladas em $DEST:"
