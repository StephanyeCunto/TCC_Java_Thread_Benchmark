#!/bin/bash

# ./benchmark_threads.sh "http://20.195.171.67:8080" 

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

close_port() {
    result=$(ssh -i "$KEY_PATH" "$SERVER" "lsof -t -i :8080")

    if [[ -n "$result" ]]; then
        ssh -i "$KEY_PATH" "$SERVER" "kill -9 $result"
        echo "Port closed (killed PID $result)"
    else
        echo "Port not used"
    fi

    sleep 10
}

start_jfr() {
    NAME="$1"

    close_port

    ssh -i "$KEY_PATH" "$SERVER" "
        nohup java -XX:StartFlightRecording=filename=$JFR_PATH/$NAME,duration=1500s \
            -jar $JAVA_JAR_PATH > $JFR_PATH/java.log 2>&1 &
        echo \$! > $JFR_PATH/server.pid" 

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

for j in {1..1}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="threads/virtual"
    else
        ENDPOINT="threads/traditional"
    fi
    #############################################
    # WARM-UP
    #############################################
    start_jfr "${ENDPOINT}${j}.jfr"
    echo "=== Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
        | tee "results/${ENDPOINT}/${j}/warmup.bin" \
        | vegeta report --type=json > "results/${ENDPOINT}/${j}/warmup.json"
    curl -s "Get $BASE_URL/gc"
    sleep 20

    # # ############################################
    # # PRÉ-CARGA 1000 req/s
    # # ############################################
    for i in 1 2; do
        echo "=== Pré-carga 1000 req/s - $i ==="
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=1000 \
            | tee "results/${ENDPOINT}/${j}/preload_${i}.bin" \
            | vegeta report --type=json > "results/${ENDPOINT}/${j}/preload_${i}.json"
        curl -s "Get $BASE_URL/gc"
        sleep 20
    done

    # # ############################################
    # # LOOP PRINCIPAL
    # # ############################################
    # for i in {1..150}; do
    #     RATE=$((50 * i))
    #     JFR_NAME="run_${RATE}.jfr"


    #     echo "=== Teste $RATE req/s ==="
    #     echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
    #         -duration="10s" \
    #         -rate="$RATE" \
    #         -timeout=0s \
    #         -max-workers=100000 \
    #         | tee "results/${ENDPOINT}/${j}/run_${RATE}.bin" \
    #         | vegeta report --type=json > "results/${ENDPOINT}/${j}/run_${RATE}.json"
    #     sleep 60
    #     curl -s "Get $BASE_URL/gc"
    #     sleep 20
    # done
    stop_jfr   
    download_jfr "${ENDPOINT}${j}.jfr"

    echo "=== TESTE ${ENDPOINT} ${j} COMPLETO! Resultados em ./results ==="
done