#!/bin/bash

# Usage:
# bash ./jmeter.sh "threads/virtual" "20.195.171.67:8080" "GET" "output" "final" "10s"

# -------------------------------------------------
# PARÂMETROS
# -------------------------------------------------
ENDPOINT="$1"             # Ex: threads/virtual
BASE_URL="$2"             # Ex: 20.195.171.67:8080 (sem http://)
METHOD="$3"               # GET, POST, etc.
OUTPUT="$4"
TAG="$5"
DURATION="$6"             # Ex: 10s

# Remove o 's' do duration para usar no Thread Group
DURATION_NUM=${DURATION%?}

# Caminho do JMeter
JMETER_BIN="/Users/stephanye/Downloads/apache-jmeter-5.6.3/bin/jmeter"
JMETER_PLAN="./test.jmx"

# Criar pasta de saída
mkdir -p results

# CSV de métricas
CSV="results/results.csv"
echo "rate,requests,success,latency_mean,latency_p95,throughput" > "$CSV"

# Limpar resultados antigos
rm -f results/*.jtl
rm -rf results/*_report

echo "=== Ajustando limites do sistema ==="
# Caso queira aumentar limites, use sudo ou ajuste /etc/security/limits.conf
# ulimit -n 20000  # exemplo (se permitido)

# -------------------------------------------------
# PRÉ-CARGA 1000 req/s
# -------------------------------------------------
for PRELOAD in 1 2
do
    echo "=== Pré-carga 1000 req/s ($PRELOAD) ==="
    
    $JMETER_BIN -n \
        -t $JMETER_PLAN \
        -JBASE_URL="$BASE_URL" \
        -JENDPOINT="$ENDPOINT" \
        -JMETHOD="$METHOD" \
        -JTHREADS=1000 \
        -JDURATION="$DURATION_NUM" \
        -JLOOP=-1 \
        -l results/preload${PRELOAD}.jtl \
        -e -o results/preload${PRELOAD}_report
    
    sleep 20
done

# -------------------------------------------------
# LOOP PRINCIPAL
# -------------------------------------------------
for i in {1..150}
do
    RATE=$((50 * i))
    echo "=== Iniciando teste com $RATE req/s ==="

    $JMETER_BIN -n \
        -t $JMETER_PLAN \
        -JBASE_URL="$BASE_URL" \
        -JENDPOINT="$ENDPOINT" \
        -JMETHOD="$METHOD" \
        -JTHREADS=$RATE \
        -JDURATION="$DURATION_NUM" \
        -JLOOP=-1 \
        -l results/run_${RATE}.jtl \
        -e -o results/run_${RATE}_report

    # -------------------------------------------------
    # Extrair métricas simples do JTL
    # -------------------------------------------------
    REQUESTS=$(wc -l < results/run_${RATE}.jtl)
    SUCCESS=$(awk -F',' '$8=="true"{count++} END{print count+0}' results/run_${RATE}.jtl)
    LAT_MEAN=$(awk -F',' '{sum+=$2} END{print sum/NR}' results/run_${RATE}.jtl)
    LAT_P95=$(awk -F',' '{print $2}' results/run_${RATE}.jtl | sort -n | awk 'NR==int(0.95*NR){print $1}')
    THROUGHPUT=$(awk -v rate=$RATE -v duration=$DURATION_NUM 'BEGIN{print rate/duration}')

    echo "$RATE,$REQUESTS,$SUCCESS,$LAT_MEAN,$LAT_P95,$THROUGHPUT" >> "$CSV"

    echo "=== Aguardando cooldown ==="
    sleep 60
done

echo "=== TESTE COMPLETO! Resultados em ./results ==="
