#!/bin/bash

# Script para verificar el estado de un peer BGP específico en Bird
# Se usa con Zabbix + LLD
# Argumento esperado: nombre del protocolo (ej. pb_0001_as264764)

BIRD_SOCKET="/var/run/bird/bird-rs1-lan1-ipv4.ctl"

if [ -z "$1" ]; then
    echo "No peer provided"
    exit 1
fi

peer="$1"

status=$(birdc -s "$BIRD_SOCKET" show protocols all "$peer" 2>/dev/null | awk '/  BGP state:/ { print $3 }')

if [ "$status" == "Established" ]; then
    echo "1"
else
    echo "0"
fi
