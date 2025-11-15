#!/bin/bash

# Usage:
# bash ./benchmark_threads.sh "threads/virtual" "http:/localhost:8080" "S" "output" "final" "10s"

ENDPOINT="$1"
BASE_URL="$2"
METHOD="$3"
OUTPUT="$4"
TAG="$5"
DURATION="$6"

# Criar pasta de saída
mkdir -p results
CSV="results/results.csv"

# Criar CSV
echo "rate,requests,success,latency_mean,latency_p95,throughput" > "$CSV"

echo "=== Ajustando limites do sistema ==="
ulimit -u 4000
ulimit -n 20000
ulimit -s 20000
ulimit -v unlimited

#############################################
# WARM-UP
#############################################
echo "=== Warm-up ==="
echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
    | tee results/warmup.bin \
    | vegeta report

sleep 20

#############################################
# PRÉ-CARGA 1000 req/s
#############################################
echo "=== Pré-carga 1000 req/s ==="
echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=1000 \
    | tee results/preload1.bin \
    | vegeta report

sleep 20

echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=1000 \
    | tee results/preload2.bin \
    | vegeta report

sleep 20

#############################################
# LOOP PRINCIPAL
#############################################
for i in {1..150}
do
    RATE=$((50 * i))
    echo "=== Iniciando teste com $RATE req/s ==="

    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
        -duration="$DURATION" \
        -rate="$RATE" \
        -timeout=70s \
        -max-workers=100000 \
        | tee "results/run_${RATE}.bin" \
        | vegeta report --type=json > "results/run_${RATE}.json"

    #################################
    # Extrair métricas do JSON
    #################################
    REQUESTS=$(jq '.requests' "results/run_${RATE}.json")
    SUCCESS=$(jq '.success' "results/run_${RATE}.json")
    LAT_MEAN=$(jq '.latencies.mean' "results/run_${RATE}.json")
    LAT_P95=$(jq '.latencies.p95' "results/run_${RATE}.json")
    THROUGHPUT=$(jq '.throughput' "results/run_${RATE}.json")

    # Salvar métricas no CSV
    echo "$RATE,$REQUESTS,$SUCCESS,$LAT_MEAN,$LAT_P95,$THROUGHPUT" >> "$CSV"

    echo "=== Aguardando reset (cooldown) ==="
    sleep 60
done

echo "=== TESTE COMPLETO! Resultados em ./results ==="
