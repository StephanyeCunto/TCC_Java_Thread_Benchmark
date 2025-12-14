#!/bin/bash

# ./monitor_preciso_threads.sh <PID> <arquivo_saida.json>

PID=$1
OUTPUT=$2

if [ -z "$PID" ]; then
    echo "Uso: ./monitor_preciso_threads.sh <PID> <arquivo_saida.json>"
    exit 1
fi

if [ -z "$OUTPUT" ]; then
    OUTPUT="$2.json"
fi

CPUS=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)

convert_time_to_seconds() {
    t="$1"
    echo "$t" | awk -F: '{
        if (NF==3) { print ($1*3600 + $2*60 + $3) }
        else if (NF==2) { print ($1*60 + $2) }
        else { print $0 }
    }'
}

echo "[" > "$OUTPUT"
FIRST=true

read UT0 ST0 < <(ps -p "$PID" -o utime= -o stime= 2>/dev/null)
CPU0=$(awk "BEGIN{print $(convert_time_to_seconds "$UT0") + $(convert_time_to_seconds "$ST0")}")
TS0=$(date +%s.%N 2>/dev/null)
COUNT=0

while true; do
    START_TS=$(date +%s.%N)

    if ! ps -p "$PID" > /dev/null 2>&1; then
        break
    fi

    read UT ST < <(ps -p "$PID" -o utime= -o stime= 2>/dev/null)
    CPU_NOW=$(awk "BEGIN{print $(convert_time_to_seconds "$UT") + $(convert_time_to_seconds "$ST")}")
    TS_NOW=$(date +%s.%N 2>/dev/null)

    DELTA_CPU=$(awk "BEGIN{print $CPU_NOW - $CPU0}")
    DELTA_T=$(awk "BEGIN{print $TS_NOW - $TS0}")

    if awk "BEGIN{print ($DELTA_T <= 0)}" | grep -q 1; then
        CPU_PERCENT=0
    else
        CPU_PERCENT=$(awk "BEGIN{printf \"%.2f\", ($DELTA_CPU / $DELTA_T) * 100 / ($CPUS)}")
    fi

    CPU0=$CPU_NOW
    TS0=$TS_NOW

    read RSS VSZ MEM_PERCENT THREADS < <(ps -p "$PID" -o rss= -o vsz= -o %mem= -o thcount= 2>/dev/null | awk '{print $1,$2,$3,$4}')
    
    HEAP_RAW=$(vmmap --summary "$PID" 2>/dev/null | awk '/MALLOC/ {sum += $3} END {print sum+0}')
    HEAP=${HEAP_RAW:-0}

    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    RSS=${RSS:-0}
    VSZ=${VSZ:-0}
    MEM_PERCENT=${MEM_PERCENT:-0}
    HEAP=${HEAP:-0}
    THREADS=${THREADS:-0}
    CPU_PERCENT=${CPU_PERCENT:-0.00}

    ENTRY=$(cat <<EOF
{
    "timestamp": "$TIMESTAMP",
    "pid": $PID,
    "cpu_percent": $CPU_PERCENT,
    "memory_percent": $MEM_PERCENT,
    "rss_kb": $RSS,
    "vsz_kb": $VSZ,
    "heap_kb": $HEAP,
    "threads": $THREADS
}
EOF
)

    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "," >> "$OUTPUT"
    fi
    echo "$ENTRY" >> "$OUTPUT"

    COUNT=$((COUNT + 1))

    END_TS=$(date +%s.%N)
    ELAPSED=$(awk "BEGIN {print $END_TS - $START_TS}")
    SLEEP_TIME=$(awk "BEGIN {print 1 - $ELAPSED}")
    if (( $(echo "$SLEEP_TIME > 0" | bc -l) )); then
        sleep $SLEEP_TIME
    fi
done

finish() {
    echo "]" >> "$OUTPUT"
    echo "Pronto: $OUTPUT"
    exit 0
}

trap finish INT TERM EXIT
