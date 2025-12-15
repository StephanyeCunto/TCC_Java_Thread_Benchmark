#!/bin/bash

IP="$1"

if [ -z "$IP" ]; then
    echo "Uso: ./script.sh <IP_DO_SERVIDOR>"
    exit 1
fi

echo "IP informado: $IP"

echo "=== Executando loadConstant ==="
cd loadConstant || exit 1
./benchmark_threads.sh "$IP"

echo "=== Executando loadRamping ==="
cd ../loadRamping || exit 1
./benchmark_threads.sh "$IP"
