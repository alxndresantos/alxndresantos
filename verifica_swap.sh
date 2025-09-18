#!/bin/bash

# Log
LOGFILE="/var/log/verifica_swap.log"
DATA=$(date '+%Y-%m-%d %H:%M:%S')

# Pega uso de swap em porcentagem (sem %)
swap_used=$(free | awk '/Swap:/ { if ($2 > 0) printf("%.0f", ($3/$2)*100); else print 0 }')

# RAM disponível em MB
free_mem=$(free -m | awk '/Mem:/ {print $7}')

echo "$DATA - Uso de swap: ${swap_used}%, RAM disponível: ${free_mem} MB" >> "$LOGFILE"

if [ "$swap_used" -gt 60 ]; then
    if [ "$free_mem" -gt 1024 ]; then
        echo "$DATA - Swap > 60% e RAM livre > 1GB. Limpando swap..." >> "$LOGFILE"
        /sbin/swapoff -a && /sbin/swapon -a
        echo "$DATA - Swap limpa com sucesso." >> "$LOGFILE"
    else
        echo "$DATA - RAM insuficiente (${free_mem} MB). Abortando limpeza da swap." >> "$LOGFILE"
    fi
else
    echo "$DATA - Uso de swap aceitável. Nenhuma ação necessária." >> "$LOGFILE"
fi
