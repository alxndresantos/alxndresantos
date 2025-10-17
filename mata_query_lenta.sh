#!/bin/bash

# Configurações
HOST="C8VMUO-127924-FL-PD.dbaas.clientes.tesp2.local"
USER="UC8VMUO127924"
PASS="qmwfu50489TRIHZ@!"
DB="C8VMUO_127924_FL_PD"
LIMITE=15000
LOGFILE="/var/log/mata_query_lentamata_query_lentamata_query_lenta.log"

# Cabeçalho
echo "================ $(date '+%F %T') ====================" >> "$LOGFILE"

# Busca queries lentas (exceto SLEEP) com mais de LIMITE segundos
mysql -h "$HOST" -u "$USER" -p"$PASS" "$DB" -e "
    SELECT id, user, host, db, time, command, info
    FROM information_schema.processlist
    WHERE command != 'Sleep'
      AND time > $LIMITE;" -N | while IFS=$'\t' read -r id user host db time command info; do

    echo "Matando ID $id - Tempo: ${time}s - Usuário: $user@$host - DB: $db" >> "$LOGFILE"
    echo "Query: $info" >> "$LOGFILE"
    echo "-----------------------------------------------------" >> "$LOGFILE"

    # Mata o processo
    mysql -h "$HOST" -u "$USER" -p"$PASS" "$DB" -e "KILL $id;"
done
