JFR_PATH="/Users/stephanye/Documents/tcc/Test/Script/loadConstant"
JAVA_JAR_PATH="/Users/stephanye/Documents/tcc/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"

BASE_URL="http://192.168.1.3:8080/threads"

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
    mkdir -p $JFR_PATH/results/threads

    close_port
    nohup java -XX:StartFlightRecording=filename=$JFR_PATH/results/threads/$NAME,dumponexit=true \
        -jar $JAVA_JAR_PATH > $JFR_PATH/java$NAME.log 2>&1 &
    sleep 1

    PID=$(pgrep -f "benchmark-server-0.0.1-SNAPSHOT.jar")
    echo $PID > $JFR_PATH/server.pid
    echo "JFR started with PID $PID"

    sleep 5
}

stop_jfr(){
    if [[ -f $JFR_PATH/server.pid ]]; then
        PID=$(cat $JFR_PATH/server.pid)
        kill $PID
        echo "JFR stopped (killed PID $PID)"
        rm -f $JFR_PATH/server.pid
    else
        echo "No PID file found"
    fi
}

warmup(){
    ENDPOINT="$1"
    J="$2"

    mkdir -p "results/threads/${ENDPOINT}/$J"

    for i in {1..3}; do
        echo "=== Warm-up === $i"
        echo "GET $BASE_URL/$ENDPOINT"| vegeta attack -duration=60s -rate=700 \
            | tee "results/threads/${ENDPOINT}/$J/warmup$i.bin" \
            | vegeta report --type=json > "results/threads/${ENDPOINT}/$J/runWarmup$i.json"

        curl -s "$BASE_URL/gc"
        sleep 20
    done
}

run_warmup(){
    ENDPOINT="$1"
    J="$2"
    
    mkdir -p "results/threads/${ENDPOINT}/$J"
    
    echo "=== Run Warm-up ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=180s -rate=7000 \
    | tee "results/threads/${ENDPOINT}/$J/warmup.bin" \
    | vegeta report --type=json > "results/threads/${ENDPOINT}/$J/runWarmup.json"

    curl -s "$BASE_URL/gc"
    sleep 60
}

loop(){
    ENDPOINT="$1"
    j="$2"

    mkdir -p "results/threads/${ENDPOINT}/${j}"

    echo "=== Loop ==="
    echo "GET $BASE_URL/$ENDPOINT"| vegeta attack \
        -duration="600s" \
        -rate="7500" \
        -timeout=0s \
        -max-workers=100000 \
        | tee "results/threads/${ENDPOINT}/${j}/run.bin" \
        | vegeta report --type=json > "results/threads/${ENDPOINT}/${j}/run.json"
}

monitor() {
    PID=$1
    FILE=$2

    mkdir -p "$(dirname "$FILE")"
    
    echo "time,cpu,mem,rss_mb,ephemeral_ports" > "$FILE"

    while kill -0 "$PID" 2>/dev/null; do
        cpu=$(ps -p $PID -o %cpu= 2>/dev/null || echo "0")
        mem=$(ps -p $PID -o %mem= 2>/dev/null || echo "0")
        rss=$(ps -p $PID -o rss= 2>/dev/null | awk '{printf "%.2f", $1/1024}')

        if command -v ss >/dev/null 2>&1; then
            ports=$(ss -tan state established '( sport >= :1024 )' 2>/dev/null | tail -n +2 | wc -l)
        else
            ports=$(netstat -an 2>/dev/null | awk '/ESTABLISHED/ && $4 ~ /:([1-9][0-9]{3,4}|[1-5][0-9]{4}|6[0-5][0-5][0-3][0-5])/ {count++} END {print count+0}')
        fi

        echo "$(date +%s);$cpu;$mem;$rss;$ports" >> "$FILE"
        sleep 1
    done
}

for j in {1..10}; do
    if [ $(($j % 2)) -eq 0 ]; then
        ENDPOINT="virtual"
    else
        ENDPOINT="traditional"
    fi

    start_jfr "${ENDPOINT}${j}.jfr"
    PID=$(cat $JFR_PATH/server.pid)

    # warmup
    monitor $PID "results/threads/${ENDPOINT}/$j/stats_warmup_${ENDPOINT}${j}.csv" &
    MONITOR_PID=$!
    warmup ${ENDPOINT} ${j}
    kill $MONITOR_PID 2>/dev/null

    # run_warmup
    monitor $PID "results/threads/${ENDPOINT}/$j/stats_run_warmup_${ENDPOINT}${j}.csv" &
    MONITOR_PID=$!
    run_warmup ${ENDPOINT} ${j}
    kill $MONITOR_PID 2>/dev/null

    # loop
    monitor $PID "results/threads/${ENDPOINT}/$j/stats_loop_${ENDPOINT}${j}.csv" &
    MONITOR_PID=$!
    loop ${ENDPOINT} ${j}
    kill $MONITOR_PID 2>/dev/null

    stop_jfr
done