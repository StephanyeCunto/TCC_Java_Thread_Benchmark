#!/bin/bash

# ./benchmark_threads.sh "20.195.171.67"

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

warmup(){
    ENDPOINT="$1"
    j="$2"

    echo "=== Warm-up === "

    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 -timeout=70s \
        | tee "$RESULTS_PATH/$ENDPOINT/$j/warmup/bin/warmup.bin" \
        | vegeta report --type=json > "$RESULTS_PATH/$ENDPOINT/$j/warmup/json/warmup.json"
}

runWarmup(){
    ENDPOINT="$1"
    j="$2"

    for i in {1..3}; do
    sleep 20
    
        echo "=== RunWarm-up === $i"

        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=1000 -timeout=70s \
            | tee "$RESULTS_PATH/$ENDPOINT/$j/runWarmup/bin/runWarmup$i.bin" \
            | vegeta report --type=json > "$RESULTS_PATH/$ENDPOINT/$j/runWarmup/json/runWarmup$i.json"
    done
}

loop() {
    ENDPOINT="$1"
    j="$2"
    erro=0

    for i in {1..200}; do
        RATE=$((50 * i))
        echo "=== Teste $RATE req/s ==="

        JSON_FILE="$RESULTS_PATH/$ENDPOINT/$j/run/json/run${RATE}.json"

        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
            -duration=10s \
            -rate="$RATE" \
            -timeout=70s \
            | tee "$RESULTS_PATH/$ENDPOINT/$j/run/bin/run${RATE}.bin" \
            | vegeta report --type=json > "$JSON_FILE"

        SUCCESS=$(jq '.success' "$JSON_FILE")

        if (( $(echo "$SUCCESS < 1.0" | bc -l) )); then
            echo "❌ Falhas detectadas (success=$SUCCESS)."
            erro=$((erro + 1))
            echo "Total de erros até agora: $erro"
        else
            erro=0
        fi

        if (( erro >= 3 )); then
            echo "❌ Três falhas consecutivas. Encerrando os testes para $ENDPOINT $j."
            break
        fi

        gc
    done
    }

prepare_environment

for j in {1..10}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi

    create_folders "${ENDPOINT}" "${j}"

    start_jvm "${ENDPOINT}" "${j}"

    warmup "${ENDPOINT}" "${j}"

    runWarmup "${ENDPOINT}" "${j}"

    gc

    $SSH 'mkdir -p '$SERVER_DIR/"$RESULTS_PATH"'/'"$ENDPOINT"'/'"$j"'/Monitor/'

    $SSH 'jcmd $(cat '"$LOG_PATH"'/server.pid) JFR.start name='"Monitor"'  duration=670s   settings=profile filename='"$SERVER_DIR"'/'"$RESULTS_PATH"'/'"$ENDPOINT"'/'"$j"'/Monitor/'

    loop "${ENDPOINT}" "${j}"

    $SSH 'jcmd $(cat '"$LOG_PATH"'/server.pid) JFR.stop name='"Monitor"' '
    stop_jvm 

    echo "Aguardando 1 minuto antes do próximo teste..."
    sleep 60
done
