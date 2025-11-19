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

warmup(){
    ENDPOINT="$1"
    j="$2"

    for i in {1..3}; do
        echo "=== Warm-up === $i"
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
            | tee "results/threads/${ENDPOINT}/$j/warmup$i.bin" \
            | vegeta report --type=json > "results/threads/${ENDPOINT}/$j/warmup$i.json"

        saveGet "results/threads/${ENDPOINT}/$j/warmupGet$i.json"

        curl -s "Get $BASE_URL/gc"
        sleep 20
    done
}

run_warmup(){
    ENDPOINT="$1"
    j="$2"
    echo "=== Run Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=360s -rate=700 \
        | tee "results/threads/${ENDPOINT}/$j/warmup.bin" \
        | vegeta report --type=json > "results/threads/${ENDPOINT}/$j/runWarmup.json"

    saveGet "results/threads/${ENDPOINT}/$j/runWarmupGet$i.json"

    curl -s "Get $BASE_URL/gc"
    sleep 60
}

loop(){
    ENDPOINT="$1"
    j="$2"

    echo "=== Loop === "
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
        -duration="600s" \
        -rate="700" \
        -timeout=0s \
        -max-workers=100000 \
        | tee "results/threads/${ENDPOINT}/${j}/run.bin" \
        | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/run.json"
    
    saveGet "results/threads/${ENDPOINT}/${j}/run_Get.json"
}

saveGet(){
    ADDRESS="$1"
    sleep 5 
    {   echo "{ "Threads":"
     curl -s "$BASE_URL/get" 
    echo "}"
    } > "$ADDRESS"
}

for j in {2..10}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi

    start_jfr "${ENDPOINT}${j}.jfr"

    warmup ${ENDPOINT} ${j}
    run_warmup ${ENDPOINT} ${j}
    loop ${ENDPOINT} ${j}

    stop_jfr   
    download_jfr "${ENDPOINT}${j}.jfr"

done