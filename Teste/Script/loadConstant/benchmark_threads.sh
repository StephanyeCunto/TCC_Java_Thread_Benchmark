#!/bin/bash
# Uso: ./benchmark_threads.sh 192.168.3.4

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."

BASE_URL="http://$1:8080/threads"
SSH="ssh stephanye@$1"

JAVA_JAR_PATH="Documents/tcc/Teste/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"
LOG_PATH="Documents/tcc/Teste/Script/LoadConstant/Results/logs"
RESULTS_PATH="Results/results"

source "$ROOT_DIR/prepare_environment.sh"
source "$ROOT_DIR/jvm.sh"
source "$ROOT_DIR/folder.sh"

warmup() {
    ENDPOINT="$1"
    j="$2"

    for i in {1..3}; do
        echo "=== Warm-up $i ==="

        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
            -duration=60s \
            -rate=300 \
            -timeout=70s \
        | tee "$RESULTS_PATH/$ENDPOINT/$j/warmup/bin/warmup$i.bin" \
        | vegeta report --type=json \
        > "$RESULTS_PATH/$ENDPOINT/$j/warmup/json/warmup$i.json"
    done
}

run_warmup() {
    ENDPOINT="$1"
    j="$2"

    echo "=== Run Warm-up ==="

    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
        -duration=120s \
        -rate=1000 \
        -timeout=70s \
    | tee "$RESULTS_PATH/$ENDPOINT/$j/runWarmup/bin/runWarmup.bin" \
    | vegeta report --type=json \
    > "$RESULTS_PATH/$ENDPOINT/$j/runWarmup/json/runWarmup.json"

    gc
}

loop() {
    ENDPOINT="$1"
    j="$2"

    echo "=== Loop principal ==="

    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
        -duration=600s \
        -rate=1000 \
        -timeout=70s \
    | tee "$RESULTS_PATH/$ENDPOINT/$j/run/bin/run$j.bin" \
    | vegeta report --type=json \
    > "$RESULTS_PATH/$ENDPOINT/$j/run/json/run$j.json"
}

prepare_environment

for j in {1..20}; do

    if (( j % 2 == 0 )); then
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi

    echo "=== Teste $j | Endpoint: $ENDPOINT ==="

    create_folders "$ENDPOINT" "$j"

    start_jvm "$ENDPOINT" "$j"

    warmup "$ENDPOINT" "$j"
    run_warmup "$ENDPOINT" "$j"

    loadMonitor "$ENDPOINT" "$j"

    loop "$ENDPOINT" "$j"

    stop_jvm

    echo "Aguardando 10 minutos antes do próximo teste..."
    sleep 600
done
