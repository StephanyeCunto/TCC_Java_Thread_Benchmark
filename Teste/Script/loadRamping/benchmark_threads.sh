#!/bin/bash

# ./benchmark_threads.sh "20.195.171.67"

BASE_URL="http://$1:8080/threads"
SSH="ssh stephanye@$1"

JAVA_JAR_PATH="Documents/tcc/Teste/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"
LOG_PATH="Documents/tcc/Teste/Script/LoadConstant/Results/logs"
RESULTS_PATH="Results/results"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."

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
            echo "❌ Falhas detectadas (success=$SUCCESS). Encerrando loop."
            erro=erro+1
            echo "Total de erros até agora: $erro"
        else
            erro=0
        fi

        if [ "$erro" -ge 3 ]; then
            echo "❌ Três falhas consecutivas. Encerrando os testes para $ENDPOINT $j."
            break
        fi

        gc
    done
}

create_folders(){    
    ENDPOINT="$1"
    j="$2"

    echo "Criando pastas para $ENDPOINT $j..."

    mkdir -p "$LOG_PATH"

    mkdir -p "$RESULTS_PATH/$ENDPOINT/$j/warmup/bin"
    mkdir -p "$RESULTS_PATH/$ENDPOINT/$j/warmup/json"

    mkdir -p "$RESULTS_PATH/$ENDPOINT/$j/runWarmup/bin"
    mkdir -p "$RESULTS_PATH/$ENDPOINT/$j/runWarmup/json"

    mkdir -p "$RESULTS_PATH/$ENDPOINT/$j/run/bin"
    mkdir -p "$RESULTS_PATH/$ENDPOINT/$j/run/json"
}

loadMonitor(){
    ENDPOINT="$1"
    j="$2"

    echo "=== Load Monitor ==="

    PID=$($SSH "cat $LOG_PATH/server.pid")

    $SSH "mkdir -p Documents/tcc/Teste/Script/$RESULTS_PATH/loadConstant/$ENDPOINT/$j/monitor"

    $SSH "nohup bash Documents/tcc/TesteScript/monitor.sh $PID Documents/tcc/Teste/Script/$RESULTS_PATH/loadConstant/$ENDPOINT/$j/monitor/monitor.json > /dev/null 2>&1 &"

    echo "Monitor"
}

prepare_environment

for j in {1..20}; do
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

    loadMonitor "${ENDPOINT}" "${j}"

    loop "${ENDPOINT}" "${j}"

    stop_jvm 

    echo "Aguardando 3 minutos antes do próximo teste..."
    sleep 180
done
