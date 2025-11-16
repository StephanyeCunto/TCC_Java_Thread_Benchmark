#!/bin/bash

# ./benchmark_threads.sh "threads/virtual" "http://20.195.171.67:8080" "S" "output" "final" "10s"

ENDPOINT="$1"
BASE_URL="$2"
METHOD="$3"
OUTPUT="$4"
TAG="$5"
DURATION="$6"

# Usuário e IP da VM + chave privada
SERVER="azureuser@20.195.171.67"
KEY_PATH="$HOME/.ssh/linux-java-vm_key.pem"
JFR_PATH="/home/azureuser/jfr"
JAVA_JAR_PATH="/home/azureuser/TCC_Java_Thread_Benchmark/Test/Serve_Test/benchmark-server/target/benchmark-server-0.0.1-SNAPSHOT.jar"

mkdir -p results
CSV="results/results.csv"
echo "rate,requests,success,latency_mean,lat_p95,throughput" > "$CSV"

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
        nohup java \
            -XX:+FlightRecorder \
            -XX:StartFlightRecording=filename=$JFR_PATH/$NAME,settings=profile,dumponexit=true \
            -jar $JAVA_JAR_PATH \
            > $JFR_PATH/server.log 2>&1 &
        echo \$! > $JFR_PATH/server.pid
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

#############################################
# WARM-UP
#############################################
start_jfr "teste.jfr"

echo "=== Warm-up ==="
echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=300 \
    | tee results/warmup.bin \
    | vegeta report
sleep 20

#############################################
# PRÉ-CARGA 1000 req/s
#############################################
for i in 1 2; do
    echo "=== Pré-carga 1000 req/s - $i ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack -duration=60s -rate=1000 \
        | tee "results/preload${i}.bin" \
        | vegeta report    
    sleep 20
done

#############################################
# LOOP PRINCIPAL
#############################################
for i in {1..150}; do
    RATE=$((50 * i))
    JFR_NAME="run_${RATE}.jfr"


    echo "=== Teste $RATE req/s ==="
    echo "GET $BASE_URL/$ENDPOINT" | vegeta attack \
        -duration="$DURATION" \
        -rate="$RATE" \
        -timeout=120s \
        -max-workers=100000 \
        | tee "results/run_${RATE}.bin" \
        | vegeta report --type=json > "results/run_${RATE}.json"

    REQUESTS=$(jq '.requests' "results/run_${RATE}.json")
    SUCCESS=$(jq '.success' "results/run_${RATE}.json")
    LAT_MEAN=$(jq '.latencies.mean' "results/run_${RATE}.json")
    LAT_P95=$(jq '.latencies.p95' "results/run_${RATE}.json")
    THROUGHPUT=$(jq '.throughput' "results/run_${RATE}.json")
    echo "$RATE,$REQUESTS,$SUCCESS,$LAT_MEAN,$LAT_P95,$THROUGHPUT" >> "$CSV"

 

    echo "=== Cooldown ==="
    sleep 60
done

stop_jfr   
download_jfr "teste.jfr"

echo "=== TESTE COMPLETO! Resultados em ./results ==="
