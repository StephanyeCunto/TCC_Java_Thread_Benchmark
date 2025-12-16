#!/bin/bash

PID=$1
OUTPUT=$2

OUTPUT=${OUTPUT:-monitor_output.json}
CPUS=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)

if [ -z "$PID" ]; then
    echo "Uso: $0 <PID> [arquivo_saida.json]"
    exit 1
fi

echo "[" > "$OUTPUT"
FIRST=true

finish() {
    if tail -n 1 "$OUTPUT" | grep -q '},'; then
        sed -i '' '$ s/},/}/' "$OUTPUT"
    fi
    echo "]" >> "$OUTPUT"
    echo "Pronto: dados salvos em $OUTPUT"
    exit 0
}

trap finish INT TERM

while ps -p "$PID" > /dev/null 2>&1; do
    START_TS=$(date +%s.%N)

    READINGS=$(ps -p "$PID" \
        -o %cpu= \
        -o %mem= \
        -o rss= \
        -o vsz= \
        -o thcount= 2>/dev/null)

    if [ -z "$READINGS" ]; then
        sleep 1
        continue
    fi

    read CPU_PERCENT MEM_PERCENT RSS VSZ THREADS <<< "$READINGS"

    CPU_PERCENT=${CPU_PERCENT:-0.00}
    MEM_PERCENT=${MEM_PERCENT:-0.00}
    RSS=${RSS:-0}
    VSZ=${VSZ:-0}
    THREADS=${THREADS:-0}

    HEAP_RAW=$(vmmap --summary "$PID" 2>/dev/null | awk '/MALLOC/ {sum+=$3} END {print sum+0}')
    HEAP=$((HEAP_RAW / 1024))
    HEAP=${HEAP:-0}

    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if [ "$FIRST" = false ]; then
        echo "," >> "$OUTPUT"
    fi
    FIRST=false

    cat <<EOF >> "$OUTPUT"
{
    "timestamp": "$TIMESTAMP",
    "pid": $PID,
    "cpu_percent": $(printf "%.2f" "$CPU_PERCENT"),
    "memory_percent": $(printf "%.2f" "$MEM_PERCENT"),
    "rss_kb": $RSS,
    "vsz_kb": $VSZ,
    "heap_kb": $HEAP,
    "threads": $THREADS
}
EOF

    END_TS=$(date +%s.%N)
    ELAPSED=$(echo "$END_TS - $START_TS" | bc -l)
    SLEEP_TIME=$(echo "1 - $ELAPSED" | bc -l)

    if (( $(echo "$SLEEP_TIME > 0" | bc -l) )); then
        sleep "$SLEEP_TIME"
    fi
done

finish
