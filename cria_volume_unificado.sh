#!/bin/bash
# Script para criar volume unificado com mergerfs
# Desenvolvido por Alexandre dos Santos (Coxa)
# Sempre executar o procedimento com o Fluig parado!!!!

set -e  # para o script se algum comando falhar

echo "==> Instalando mergerfs..."
cd /tmp
curl -LO https://github.com/trapexit/mergerfs/releases/download/2.40.2/mergerfs-2.40.2-1.el7.x86_64.rpm
sudo yum install -y ./mergerfs-2.40.2-1.el7.x86_64.rpm

echo "==> Preparando diretórios..."
# renomeia a pasta public -> public1 apenas se ainda não foi renomeada
if [ -d "/volume/wdk-data/public" ] && [ ! -d "/volume/wdk-data/public1" ]; then
    sudo mv /volume/wdk-data/public /volume/wdk-data/public1
fi

# cria pastas public2..public20
sudo mkdir -p /volume/wdk-data/public{2..20}
sudo chown -R fluig:fluig /volume/wdk-data/public{2..20}

echo "==> Configurando fstab..."
if ! grep -q "#volume-unificado" /etc/fstab; then
    sudo bash -c "cat <<EOF >> /etc/fstab
#volume-unificado
mergerfs#/volume/wdk-data/public1:/volume/wdk-data/public2:/volume/wdk-data/public3:/volume/wdk-data/public4:/volume/wdk-data/public5:/volume/wdk-data/public6:/volume/wdk-data/public7:/volume/wdk-data/public8:/volume/wdk-data/public9:/volume/wdk-data/public10:/volume/wdk-data/public11:/volume/wdk-data/public12:/volume/wdk-data/public13:/volume/wdk-data/public14:/volume/wdk-data/public15:/volume/wdk-data/public16:/volume/wdk-data/public17:/volume/wdk-data/public18:/volume/wdk-data/public19:/volume/wdk-data/public20 /volume/wdk-data/public fuse.mergerfs defaults,allow_other,use_ino,category.create=rand,category.search=ff 0 0
EOF"
    echo "✔ Entrada adicionada no /etc/fstab"
else
    echo "ℹ Já existe configuração '#volume-unificado' no /etc/fstab"
fi

echo "==> Montando volumes..."
sudo mount -a

echo "==> Finalizado com sucesso!"
