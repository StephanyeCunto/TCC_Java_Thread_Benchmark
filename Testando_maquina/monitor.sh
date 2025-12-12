#!/bin/bash

OUTPUT="monitor_gargalo.json"
INTERVAL=1
TARGET_IP="192.168.1.6"
TARGET_PORT="8080"

echo "[" > $OUTPUT

while true; do
    TS=$(date -Iseconds)

    # CPU
    CPU=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')

    # Load
    LOAD=$(sysctl -n vm.loadavg | awk '{print $2, $3, $4}')

    # Ephemeral port range
    EP_START=$(sysctl net.inet.ip.portrange.first | awk '{print $2}')
    EP_END=$(sysctl net.inet.ip.portrange.last | awk '{print $2}')
    EP_TOTAL=$((EP_END - EP_START))

    # Active ephemeral ports
    EP_USED=$(netstat -an | grep "$TARGET_IP" | wc -l)

    # Count TCP states
    SYN_SENT=$(netstat -an | grep SYN_SENT | wc -l)
    EST=$(netstat -an | grep ESTABLISHED | wc -l)
    TIMEW=$(netstat -an | grep TIME_WAIT | wc -l)

    # Java info
    JAVA_PID=$(pgrep java)
    THREADS=$(ps -M $JAVA_PID | wc -l)
    FD_USED=$(lsof -p $JAVA_PID 2>/dev/null | wc -l)

    # Test HTTP latency
    CURL_LAT=$(curl -o /dev/null -s -w "%{time_total}" http://$TARGET_IP:$TARGET_PORT/threads/traditional)

    # Determine gargalo
    GARGALO="NORMAL"

    if (( EP_USED > EP_TOTAL * 80 / 100 )); then
        GARGALO="PORTAS_EFEMERAS_SATURADAS"
    fi

    if (( SYN_SENT > 10000 )); then
        GARGALO="MUITOS_SYN_SENT_HANDSHAKE_TRAVADO"
    fi

    if (( $(echo "$CURL_LAT > 1" | bc -l) )); then
        GARGALO="ALTA_LATENCIA"
    fi

    if (( $(echo "$CPU > 90" | bc -l) )); then
        GARGALO="CPU_NO_LIMITE"
    fi

    JSON=$(cat <<EOF
{
  "timestamp": "$TS",
  "cpu": "$CPU",
  "load": "$LOAD",
  "ephemeral_used": "$EP_USED",
  "ephemeral_total": "$EP_TOTAL",
  "syn_sent": "$SYN_SENT",
  "established": "$EST",
  "time_wait": "$TIMEW",
  "java_threads": "$THREADS",
  "fds_used": "$FD_USED",
  "latency_sec": "$CURL_LAT",
  "gargalo_detectado": "$GARGALO"
},
EOF
)

    echo "$JSON" >> $OUTPUT

    echo "[Alerta] $TS → Gargalo detectado: $GARGALO" 

    sleep $INTERVAL
done

echo "]" >> $OUTPUT
