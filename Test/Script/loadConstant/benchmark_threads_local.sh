
JFR_PATH="/Users/stephanye/Library/Mobile Documents/com~apple~CloudDocs/Documents/tcc/Test/Script/loadConstant/"
JAVA_JAR_PATH="/Users/stephanye/Library/Mobile Documents/com~apple~CloudDocs/Documents/tcc/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"

BASE_URL="localhost:8080/threads"

close_port() {
    result=$(lsof -t -i :8080)
    echo $result

    if [[ -n $result ]]; then
        kill -9 $result
        echo "Port closed (killed PID $result)"
    else
        echo "Port not used"
    fi

    sleep 10
}

start_jfr(){
    NAME="$1"

    close_port

    nohup java -XX:StartFlightRecording=filename=$JFR_PATH/results/threads/$NAME,duration=5000s \
            -jar $JAVA_JAR_PATH > $JFR_PATH/java$NAME.log 2>&1 &
        echo \$! > $JFR_PATH/server.pid

    echo "JFR start"
    sleep 5
}

stop_jfr(){
    kill \$(cat $JFR_PATH/server.pid);
    echo "JFR stop"
}

warmup(){
    ENDPOINT="$1"
    J="$2"

    for i in {1..3}; do
    echo "=== Warm-up === $i"
    echo "GET $BASE_URL/$ENDPOINT"| vegeta attack -duration=360s -rate=700 \
        | tee "results/threads/${ENDPOINT}/$J/warmup$i.bin" \
        | vegeta report --type=json > "results/threads/${ENDPOINT}/$J/runWarmup.json"

    #saveGet
    curl -s "Get $BASE_URL/gc"
    sleep 20
}

run_warmup(){
    ENDPOINT="$1"
    J="$2"
    echo "=== Run Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=360s -rate=700 \
    | tee "results/threads/${ENDPOINT}/$J/warmup.bin" \
    | vegeta report --type=json > "results/threads/${ENDPOINT}/$J/runWarmup.json"

    #saveGet

    curl -s "Get $BASE_URL/gc"
    sleep 60
}

loop(){
    ENDPOINT="$1"
    j="$2"

    echo "=== Loop ==="
    echo "GET $BASE_URL/$ENDPOINT"| vegeta attack \
        -duration="60s" \
        -rate="700" \
        -timeout=0s \
        -max-workers=100000 \
        | tee "results/threads/${ENDPOINT}/${j}/run.bin" \
        | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/run.json"

    #saveGet
}

saveGet(){
    ADRRES="$1"
    sleep 5
    {   echo "{ "Threads": "
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
    run_warmup ${ENDPOINT} ${j}
    loop ${ENDPOINT} ${j}

    stop_jfr   

done

