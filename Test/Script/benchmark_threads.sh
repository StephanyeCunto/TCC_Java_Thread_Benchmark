#!/bin/bash

# ./benchmark_threads.sh "http://20.195.171.67:8080/threads" 

BASE_URL="$1"

# Usuário e IP da VM + chave privada
SERVER="azureuser@20.195.171.67"
KEY_PATH="$HOME/.ssh/linux-java-vm_key.pem"
JFR_PATH="/home/azureuser/jfr"
JAVA_JAR_PATH="/home/azureuser/TCC_Java_Thread_Benchmark/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"

# Ajustes de limites (macOS pode não permitir alguns)
ulimit -n 20000
ulimit -s 20000
ulimit -v unlimited

#############################################
# Função para iniciar JFR remoto
#############################################
start_jfr() {
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
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi
    #############################################
    # WARM-UP
    #############################################
    start_jfr "teste${ENDPOINT}${j}.jfr"
    echo "=== Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
        | tee "results/threads/${ENDPOINT}/${j}/warmup.bin" \
        | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/warmup.json"
    curl -s "Get $BASE_URL/gc"
    sleep 20

    # ############################################
    # PRÉ-CARGA 1000 req/s
    # ############################################
    for i in 1 2; do
        echo "=== Pré-carga 500 req/s - $i ==="
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=500 \
            | tee "results/threads/${ENDPOINT}/${j}/preload_${i}.bin" \
            | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/preload_${i}.json"
        curl -s "Get $BASE_URL/gc"
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
            | tee "results/threads/${ENDPOINT}/${j}/run_${RATE}.bin" \
            | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/run_${RATE}.json"
        sleep 60
        curl -s "Get $BASE_URL/gc"
        sleep 20
    done
    stop_jfr   
    download_jfr "teste${ENDPOINT}${j}.jfr"

    echo "=== TESTE ${ENDPOINT} ${j} COMPLETO! Resultados em ./results ==="
done
