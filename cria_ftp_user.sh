#!/bin/bash

# Parâmetros
USUARIO=$1           # nome.sobrenome
DIRETORIO=$2         # Ex: FTPTOTVSRH
GRUPO=$2             # O grupo normalmente tem mesmo nome do diretório

# Criação do usuário sem criar home (-M), definindo diretório já existente e shell restrito
useradd $USUARIO -M -d /data/FTPTOTVS/$DIRETORIO -s /bin/ftponly

# Adicionar usuário ao grupo responsável pelo diretório
usermod -aG $GRUPO $USUARIO

# Gerar senha aleatória
SENHA=$(date +%s | sha256sum | base64 | head -c 12)
echo "$USUARIO:$SENHA" | chpasswd

# Opcional: Imprimir senha para entrega (ou registrar para envio seguro)
echo "Senha do usuário $USUARIO: $SENHA"

# Adicionar usuário à lista de usuários permitidos no vsftpd
echo "$USUARIO" >> /etc/vsftpd/user_list

# Verificar permissões no diretório
#chown $USUARIO:$GRUPO /data/FTPTOTVS/$DIRETORIO

# Pronto!
echo "Usuário $USUARIO criado, senha gerada, e incluído no FTP/vsftpd!"
