#!/bin/bash

# ./benchmark_threads.sh "http://20.195.171.67:8080" 

BASE_URL="$1"

SERVER="azureuser@20.195.171.67"
KEY_PATH="$HOME/.ssh/linux-java-vm_key.pem"
JFR_PATH="/home/azureuser/jfr"
JAVA_JAR_PATH="/home/azureuser/TCC_Java_Thread_Benchmark/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"


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

stop_jfr() {
    ssh -i "$KEY_PATH" "$SERVER" "kill \$(cat $JFR_PATH/server.pid); echo 'JFR parado'"
}

download_jfr() {
    NAME="$1"
    scp -i "$KEY_PATH" "$SERVER:$JFR_PATH/$NAME" "results/$NAME"
}

warmup(){
    ENDPOINT="$1"
    j="$2"
    echo "=== Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=1s -rate=300 \
        | tee "results/${ENDPOINT}/${j}/warmup.bin" \
        | vegeta report --type=json > "results/${ENDPOINT}/${j}/warmup.json"

    saveGet "results/${ENDPOINT}/${j}/warmupGet.json"

    curl -s "Get $BASE_URL/gc"
    sleep 20
}

load(){
    ENDPOINT="$1"
    j="$2"
    for i in 1 2; do
        echo "=== Pré-carga 1000 req/s - $i ==="
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=1000 \
            | tee "results/${ENDPOINT}/${j}/preload_${i}.bin" \
            | vegeta report --type=json > "results/${ENDPOINT}/${j}/preload_${i}.json"

        saveGet "results/${ENDPOINT}/${j}/preload_${i}Get.json"
        
        curl -s "Get $BASE_URL/gc"
        sleep 20
    done
}

loop(){
    ENDPOINT="$1"
    j="$2"
    for i in {1..20}; do
        RATE=$((50 * i))
        JFR_NAME="run_${RATE}.jfr"


        echo "=== Teste $RATE req/s ==="
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
            -duration="10s" \
            -rate="$RATE" \
            -timeout=0s \
            -max-workers=100000 \
            | tee "results/${ENDPOINT}/${j}/run_${RATE}.bin" \
            | vegeta report --type=json > "results/${ENDPOINT}/${j}/run_${RATE}.json"
        sleep 60

        saveGet "results/${ENDPOINT}/${j}/run_${RATE}Get.json"

        curl -s "Get $BASE_URL/gc"
        sleep 20
    done

}

saveGet(){
    ADRRES="$1"
    sleep 20
    echo $ADRRES
        echo "GET $BASE_URL/get"| vegeta attack -duration=1s -rate=1 \
        | vegeta report --type=json > $ADRRES
}

for j in {1..10}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="threads/virtual"
    else
        ENDPOINT="threads/traditional"
    fi
    
    start_jfr "${ENDPOINT}${j}.jfr"

    warmup ${ENDPOINT} ${j}

    load ${ENDPOINT} ${j}

    loop ${ENDPOINT} ${j}

    stop_jfr   
    download_jfr "${ENDPOINT}${j}.jfr"

    echo "=== TESTE ${ENDPOINT} ${j} COMPLETO! Resultados em ./results ==="
done