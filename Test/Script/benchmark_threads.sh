#!/bin/bash

# ./benchmark_threads.sh "threads/virtual" "http://20.195.171.67:8080" 

ENDPOINT="$1"
BASE_URL="$2"

# Usuário e IP da VM + chave privada
SERVER="azureuser@20.195.171.67"
KEY_PATH="$HOME/.ssh/linux-java-vm_key.pem"
JFR_PATH="/home/azureuser/jfr"
JAVA_JAR_PATH="/home/azureuser/TCC_Java_Thread_Benchmark/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"

# Ajustes de limites (macOS pode não permitir alguns)
ulimit -n 20000
ulimit -s 20000
ulimit -v unlimited

kill_if_port_in_use() {
    PORT=$1
    PID=$(lsof -ti:$PORT)

    if [ -n "$PID" ]; then
        echo "Porta $PORT está ocupada pelo PID $PID. Matando processo..."
        kill -9 $PID
        echo "Processo $PID finalizado."
    else
        echo "Porta $PORT livre."
    fi
}

#############################################
# Função para iniciar JFR remoto
#############################################
start_jfr() {
    kill_if_port_in_use "8080"
    NAME="$1"
    ssh -i "$KEY_PATH" "$SERVER" "
        mkdir -p $JFR_PATH;
        nohup java -XX:StartFlightRecording=filename=$JFR_PATH/$NAME,duration=1500s -jar $JAVA_JAR_PATH
    "
    echo 'JFR iniciado'
    sleep 5
}

# Função para parar JFR remoto
stop_jfr() {
    ssh -i "$KEY_PATH" "$SERVER" "kill \$(cat $JFR_PATH/server.pid); echo 'JFR parado'"
}

# Função para baixar o JFR
download_jfr() {
    NAME="$1"
    scp -i "$KEY_PATH" "$SERVER:$JFR_PATH/$NAME" "results/$NAME"
}

for j in {1..10}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="threads/virtual"
    else
        ENDPOINT="threads/traditional"
    fi
    #############################################
    # WARM-UP
    #############################################
    start_jfr "teste${ENDPOINT}${j}.jfr"
    echo "=== Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
        | tee results/warmup.bin \
        | vegeta report --type=json > "results/${ENDPOINT}/warmup${j}.json"
    echo "Get $BASE_URL/gc"
    sleep 20

    # ############################################
    # PRÉ-CARGA 1000 req/s
    # ############################################
    for i in 1 2; do
        echo "=== Pré-carga 1000 req/s - $i ==="
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=1000 \
            | tee "results/preload${i}.bin" \
            | vegeta report --type=json > "results/${ENDPOINT}${j}/preload_${i}.json"
        echo "Get $BASE_URL/gc"
        sleep 20
    done

    # ############################################
    # LOOP PRINCIPAL
    # ############################################
    for i in {1..150}; do
        RATE=$((50 * i))
        JFR_NAME="run_${RATE}.jfr"


        echo "=== Teste $RATE req/s ==="
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
            -duration="10s" \
            -rate="$RATE" \
            -timeout=0s \
            -max-workers=100000 \
            | tee "results/run_${RATE}.bin" \
            | vegeta report --type=json > "results/${ENDPOINT}${j}/run_${RATE}.json"
        sleep 60
        echo "Get $BASE_URL/gc"
        sleep 20
    done
    stop_jfr   
    download_jfr "teste${ENDPOINT}${j}.jfr"

    echo "=== TESTE ${ENDPOINT} ${j} COMPLETO! Resultados em ./results ==="
done
