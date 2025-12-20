#!/bin/bash
# Uso: ./benchmark_threads.sh 192.168.3.4

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."

BASE_URL="http://$1:8080/threads"
SSH="ssh stephanye@$1"

SERVER_DIR="Documents/tcc/Teste/Script/LoadConstant"
JAVA_JAR_PATH="Documents/tcc/Teste/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"
LOG_PATH="$SERVER_DIR/Results/logs"
RESULTS_PATH="Results/"

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

for j in {1..10}; do

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

    $SSH 'mkdir -p '$SERVER_DIR/"$RESULTS_PATH"'/'"$ENDPOINT"'/'"$j"'/Monitor/'

    $SSH 'jcmd $(cat '"$LOG_PATH"'/server.pid) JFR.start name='"Monitor"'  duration=670s   settings=profile filename='"$SERVER_DIR"'/'"$RESULTS_PATH"'/'"$ENDPOINT"'/'"$j"'/Monitor/Monitor.jfr'

    loop "$ENDPOINT" "$j"

    $SSH 'jcmd $(cat '"$LOG_PATH"'/server.pid) JFR.stop name='"Monitor"' '

    stop_jvm

    echo "Aguardando 1 minuto antes do próximo teste..."
    sleep 60
done
