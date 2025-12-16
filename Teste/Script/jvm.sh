close_port() {
    result=$($SSH "lsof -t -i :8080")

    if [[ -n "$result" ]]; then
        $SSH "kill -9 $result"
        echo "Port closed (killed PID $result)"
        sleep 10
    else
        echo "Port not used"
    fi
}

start_jvm() {
    ENDPOINT="$1"
    j="$2"

    close_port

    $SSH "
        mkdir -p $LOG_PATH/$ENDPOINT
        nohup java -jar --enable-native-access=ALL-UNNAMED $JAVA_JAR_PATH > $LOG_PATH/$ENDPOINT/java${j}.log 2>&1 &
        echo \$! > $LOG_PATH/server.pid
    "
 
    echo 'jvm iniciado'
    sleep 10
}

stop_jvm() {
    $SSH "kill \$(cat $LOG_PATH/server.pid); echo 'jvm parado'"
}

gc(){
    echo "=== GC ==="
    sleep 60
    curl -s "$BASE_URL/gc"
    sleep 20
}