#!/bin/bash

# ./benchmark_threads.sh "http://20.195.171.67:8080" 

BASE_URL="$1/threads"

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
        nohup java -XX:StartFlightRecording=filename=$JFR_PATH/$NAME,duration=5000s \
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
    scp -i "$KEY_PATH" "$SERVER:$JFR_PATH/$NAME" "results/threads/$NAME"
}

## utilizado no teste sem o warm-up
warmup(){
    ENDPOINT="$1"
    j="$2"
    # for i in {1..3}; do
    #     echo "=== Warm-up === $i"
    #     echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
    #         | tee "results/threads/${ENDPOINT}/${j}/warmup$i.bin" \
    #         | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/warmup$i.json"

    #     saveGet "results/threads/${ENDPOINT}/${j}/warmupGet$i.json"

    #     curl -s "Get $BASE_URL/gc"
    #     sleep 20
    # done

    echo "=== Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
        | tee "results/threads/${ENDPOINT}/${j}/warmup.bin" \
        | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/warmup.json"

    saveGet "results/threads/${ENDPOINT}/${j}/warmupGet.json"

    curl -s "Get $BASE_URL/gc"
    sleep 20
}

preLoad(){
    ENDPOINT="$1"
    j="$2"
    for i in 1 2; do
        echo "=== Pré-carga 500 req/s - $i ==="
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=500 \
            | tee "results/threads/${ENDPOINT}/${j}/preload_${i}.bin" \
            | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/preload_${i}.json"

        saveGet "results/threads/${ENDPOINT}/${j}/preload_Get${i}.json"
        
        curl -s "Get $BASE_URL/gc"
        sleep 60
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
            | tee "results/threads/${ENDPOINT}/${j}/run_${RATE}.bin" \
            | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/run_${RATE}.json"
        sleep 60

        saveGet "results/threads/${ENDPOINT}/${j}/run_Get${RATE}.json"

        curl -s "Get $BASE_URL/gc"
        sleep 20
    done

}

saveGet(){
    ADDRESS="$1"
    sleep 5
    {   echo "{ "Threads":"
     curl -s "$BASE_URL/get" 
    echo "}"
    } > "$ADDRESS"
}

for j in {1..10}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi
    
    start_jfr "${ENDPOINT}${j}.jfr"

    warmup ${ENDPOINT} ${j}

    preLoad ${ENDPOINT} ${j}

    loop ${ENDPOINT} ${j}

    stop_jfr   
    download_jfr "${ENDPOINT}${j}.jfr"

    echo "=== TESTE ${ENDPOINT} ${j} COMPLETO! Resultados em ./results ==="
done