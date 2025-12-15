#!/bin/bash

# ./benchmark_threads.sh "20.195.171.67"

BASE_URL="http://$1:8080/threads"
SSH="ssh stephanye@$1"

JAVA_JAR_PATH="documents/tcc_teste/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"
LOG_PATH="documents/tcc_teste/Test/Script/LoadRamping/Results/logs"
RESULTS_PATH="Results/results"

prepare_environment() {
    echo "=== Preparando ambiente no servidor (macOS Apple Silicon) ==="

    SENHA_SUDO="120504"

    $SSH "
        echo '>> ulimit (max files)'
        ulimit -n 1048576 || true

        echo '>> sysctl macOS (files & network)'
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxfiles=1048576
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxfilesperproc=1048576

        echo '>> sysctl macOS (TCP buffers)'
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.sendspace=2097152
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.recvspace=2097152
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.msl=1000
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.delayed_ack=0

        echo '>> sysctl macOS (EPHEMERAL PORT RANGE)'
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.ip.portrange.first=1024
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.ip.portrange.last=65535

        echo '>> Conferência portas efêmeras'
        sysctl net.inet.ip.portrange.first
        sysctl net.inet.ip.portrange.last

        echo '>> Informações do sistema'
        uname -a
        sysctl -n hw.ncpu
        sysctl -n hw.memsize | awk '{print \$1/1024/1024/1024 \" GB\"}'
        ulimit -n
    "
}

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

start_jvm() {
    ENDPOINT="$1"
    j="$2"

    close_port
    prepare_environment

    $SSH "
        mkdir -p $LOG_PATH/$ENDPOINT
        nohup java -jar $JAVA_JAR_PATH > $LOG_PATH/$ENDPOINT/java${j}.log 2>&1 &
        echo \$! > $LOG_PATH/server.pid
    "

    echo 'jvm iniciado'
    sleep 10
}

stop_jvm() {
    $SSH "kill \$(cat $LOG_PATH/server.pid); echo 'jvm parado'"
}

warmup(){
    ENDPOINT="$1"
    j="$2"

    for i in {1..3}; do
        echo "=== Warm-up === $i"

        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
            | tee "$RESULTS_PATH/$ENDPOINT/$j/warmup/bin/warmup$i.bin" \
            | vegeta report --type=json > "$RESULTS_PATH/$ENDPOINT/$j/warmup/json/warmup$i.json"
    done
}

loop(){
    ENDPOINT="$1"
    j="$2"

    for i in {1..20}; do
        RATE=$((50 * i))
        echo "=== Teste $RATE req/s ==="

        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
            -duration="10s" \
            -rate="$RATE" \
            -timeout=0s \
            | tee "$RESULTS_PATH/$ENDPOINT/$j/run/bin/run${RATE}.bin" \
            | vegeta report --type=json > "$RESULTS_PATH/$ENDPOINT/$j/run/json/run${RATE}.json"

        gc
        sleep 60
    done
}

gc(){
    echo "=== GC ==="
    sleep 60
    curl -s "$BASE_URL/gc"
    sleep 20
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

    $SSH "mkdir -p documents/tcc_teste/Test/Script/$RESULTS_PATH/loadConstant/$ENDPOINT/$j/monitor"

    $SSH "nohup bash documents/tcc_teste/Test/Script/monitor.sh $PID documents/tcc_teste/Test/Script/$RESULTS_PATH/loadConstant/$ENDPOINT/$j/monitor/monitor.json > /dev/null 2>&1 &"

    echo "Monitor"
}

for j in {1..10}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi

    create_folders "${ENDPOINT}" "${j}"

    start_jvm "${ENDPOINT}" "${j}"

    warmup "${ENDPOINT}" "${j}"

    gc

    loadMonitor "${ENDPOINT}" "${j}"

    loop "${ENDPOINT}" "${j}"

    stop_jvm 

    echo "Aguardando 10 minutos antes do próximo teste..."
    sleep 600
done
