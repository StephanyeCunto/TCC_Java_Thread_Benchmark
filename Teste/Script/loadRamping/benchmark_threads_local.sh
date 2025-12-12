# JFR_PATH="/run/media/ste/LinuxDisk/tcc/Test/Script/loadRamping/results/threads"
# JAVA_JAR_PATH="/run/media/ste/LinuxDisk/tcc/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"

JFR_PATH="//Users/stephanye/Documents/tcc/Test/Script/loadConstant/results/threads/"
JAVA_JAR_PATH="/Users/stephanye/Documents/tcc/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"

BASE_URL="http://localhost:8080/threads"

close_port() {
    result=$(lsof -t -i :8080)

    if [[ -n $result ]]; then
        kill -9 $result
        echo "Port closed (killed PID $result)"
    else
        echo "Port not used"
    fi

    sleep 10
}

start_jfr(){
    ENDPOINT="$1"
    J="$2"
    NAME="$3"

    close_port

    nohup java -XX:StartFlightRecording=filename=$JFR_PATH/$NAME,duration=5000s \
            -jar $JAVA_JAR_PATH > $JFR_PATH/$ENDPOINT/$J/java$NAME.log 2>&1 &
        echo $! > $JFR_PATH/$ENDPOINT/$J/server.pid

    echo "JFR start"
    sleep 5
}

stop_jfr(){
    ENDPOINT="$1"
    J="$2"
    kill $(cat $JFR_PATH/$ENDPOINT/$J/server.pid);
    echo "JFR stop"
}

warmup(){
    ENDPOINT="$1"
    J="$2"

    for i in {1..3}; do
        echo "=== Warm-up === $i"
        echo "GET $BASE_URL/$ENDPOINT"| vegeta attack -duration=60s -rate=300 \
            | tee "results/threads/${ENDPOINT}/$J/warmup$i.bin" \
            | vegeta report --type=json > "results/threads/${ENDPOINT}/$J/runWarmup$i.json"

        #saveGet
        curl -s "Get $BASE_URL/gc" 
        sleep 20
    done
}

pre_Load(){
    ENDPOINT="$1"
    J="$2"
    echo "=== Run Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=500 \
    | tee "results/threads/${ENDPOINT}/$J/preload.bin" \
    | vegeta report --type=json > "results/threads/${ENDPOINT}/$J/preLoad.json"

    #saveGet

    curl -s "Get $BASE_URL/gc"
    sleep 60
}

loop(){
    ENDPOINT="$1"
    j="$2"

    for i in {5..10}; do
        RATE=$(((1000 * i)))
        echo "=== Teste $RATE req/s ==="
        echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
            -duration="10s" \
            -rate="$RATE" \
            -timeout=70s \
            -keepalive \
            -max-workers=100000 \
            | tee "results/threads/${ENDPOINT}/${j}/run_${RATE}.bin" \
            | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/run_${RATE}.json"
        sleep 60

        curl -s "Get $BASE_URL/gc"
        sleep 20
    done

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

for j in {1..5}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi

    start_jfr ${ENDPOINT} ${j} "${ENDPOINT}${j}.jfr"

#    warmup ${ENDPOINT} ${j}
#    pre_Load ${ENDPOINT} ${j}
    loop ${ENDPOINT} ${j}

    stop_jfr ${ENDPOINT} ${j} 

done

