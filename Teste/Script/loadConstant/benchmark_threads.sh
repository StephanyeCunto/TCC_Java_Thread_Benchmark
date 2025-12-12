#!/bin/bash

# ./benchmark_threads.sh 192.168.3.4

BASE_URL="http://$1:8080/threads"
SSH="ssh stephanye@$1"

JAVA_JAR_PATH="documents/tcc_teste/Teste/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"
LOG_PATH="/Results/logs"
RESULTS_PATH="/Results/results"


close_port() {
    result=$($SSH "lsof -t -i :8080")

    if [[ -n "$result" ]]; then
        $SSH "kill -9 $result"
        echo "Port closed (killed PID $result)"
    else
        echo "Port not used"
    fi

    sleep 10
}

start_jfr() {
    close_port

    $SSH "
        mkdir -p $LOG_PATH
        nohup java -jar $JAVA_JAR_PATH > $LOG_PATH/java.log 2>&1 &
        echo \$! > $LOG_PATH/server.pid
    "
 
    echo 'JFR iniciado'
    sleep 10
}

stop_jfr() {
    $SSH "kill \$(cat $LOG_PATH/server.pid); echo 'JFR parado'"
}

warmup(){
    ENDPOINT="$1"
    j="$2"

    for i in {1..3}; do
        echo "=== Warm-up === $i"

        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
            | tee "$RESULTS_PATH/$ENDPOINT/$j/warmup/bin/warmup$i.bin" \
            | vegeta report --type=json > "$RESULTS_PATH/$ENDPOINT/$j/warmup/json/warmup$i.json"

        curl -s "$BASE_URL/gc"
        sleep 20
    done
}

run_warmup(){
    ENDPOINT="$1"
    j="$2"

    echo "=== Run Warm-up ==="

    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=360s -rate=1000 \
        | tee "$RESULTS_PATH/$ENDPOINT/$j/runWarmup/bin/runWarmup.bin" \
        | vegeta report --type=json > "$RESULTS_PATH/$ENDPOINT/$j/runWarmup/json/runWarmup.json"

    curl -s "$BASE_URL/gc"
    sleep 60
}

loop(){
    ENDPOINT="$1"
    j="$2"

    echo "=== Loop === "

    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
        -duration="600s" \
        -rate="1000" \
        -timeout=0s \
        | tee "$RESULTS_PATH/$ENDPOINT/$j/run/bin/run${j}.bin" \
        | vegeta report --type=json > "$RESULTS_PATH/$ENDPOINT/$j/run/json/run${j}.json"
}

gc(){
    echo "=== GC ==="
    curl -s "$BASE_URL/gc"
    sleep 60
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

    OUTPUT_JSON="${ENDPOINT}${j}.json"

    $SSH "bash documents/tcc_teste/Teste/Script/monitor.sh $PID $ENDPOINT$j.json"

    $SSH "jcmd $PID JFR.start name=${ENDPOINT}${j} settings=profile filename=${RESULTS_PATH}/${ENDPOINT}/${j}/${ENDPOINT}${j}.jfr"

    echo "Monitor e JFR iniciados (PID: $PID)"
}

for j in {1..10}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi

    create_folders "${ENDPOINT}" "${j}"

    start_jfr

    warmup "${ENDPOINT}" "${j}"
    run_warmup "${ENDPOINT}" "${j}"

    gc

    loadMonitor "${ENDPOINT}" "${j}"

    loop "${ENDPOINT}" "${j}"

    stop_jfr

    echo "Aguardando 10 minutos antes do próximo teste..."
    sleep 600
done
