#!/bin/bash

PID=$1
OUTPUT=$2

OUTPUT=${OUTPUT:-monitor_output.json}
CPUS=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)

convert_time_to_seconds() {
    t="$1"
    if [ -z "$t" ]; then echo 0; return; fi

    echo "$t" | awk -F: '{
        if (NF==3) { print ($1*3600 + $2*60 + $3) }
        else if (NF==2) { print ($1*60 + $2) }
        else if (NF==1) { print $1 }
        else { print 0 }
    }'
}

echo "[" > "$OUTPUT"
FIRST_SAMPLE=true 

CPU0=0
TS0=$(date +%s.%N)

finish() {
    if [ -s "$OUTPUT" ]; then
        if [ "$(tail -c 2 "$OUTPUT" | head -c 1)" == "," ]; then
            truncate -s -1 "$OUTPUT"
        fi
        echo "]" >> "$OUTPUT"
    else
        echo "]" >> "$OUTPUT"
    fi

    echo "Pronto: Dados de monitoramento salvos em: $OUTPUT"
    trap - INT TERM EXIT
    exit 0
}

trap finish INT TERM

while true; do
    START_TS=$(date +%s.%N)

    if ! ps -p "$PID" > /dev/null 2>&1; then
        break
    fi

    READINGS=$(ps -p "$PID" -o utime= -o stime= -o rss= -o vsz= -o %mem= -o thcount= 2>/dev/null)
    
    if [ -z "$READINGS" ]; then
        sleep 0.1
        continue
    fi
    
    read UT ST RSS VSZ MEM_PERCENT THREADS < <(echo "$READINGS")
    
    UT=${UT:-0}
    ST=${ST:-0}
    RSS=${RSS:-0}
    VSZ=${VSZ:-0}
    MEM_PERCENT=${MEM_PERCENT:-0.00}
    THREADS=${THREADS:-0}
    
    CPU_NOW=$(convert_time_to_seconds "$UT")
    CPU_NOW=$(bc -l <<< "$CPU_NOW + $(convert_time_to_seconds "$ST")")
    TS_NOW=$(date +%s.%N)

    if [ "$FIRST_SAMPLE" = true ]; then        
        CPU0=$CPU_NOW
        TS0=$TS_NOW
        FIRST_SAMPLE=false 
        
        
    else
        DELTA_CPU=$(bc -l <<< "$CPU_NOW - $CPU0")
        DELTA_T=$(bc -l <<< "$TS_NOW - $TS0")

        CPU_PERCENT=$(awk "BEGIN {
            DELTA_CPU = $DELTA_CPU;
            DELTA_T = $DELTA_T;
            CPUS = $CPUS;
            
            if (DELTA_T > 0) { 
                TOTAL_USE = (DELTA_CPU / DELTA_T) * 100;
                NORMALIZED = TOTAL_USE / CPUS;
                
                if (NORMALIZED > 100) { 
                    printf \"%.2f\", 100.00 
                } else { 
                    printf \"%.2f\", NORMALIZED 
                }
            } else { 
                printf \"%.2f\", 0.00 
            }
        }")
        
        HEAP_RAW=$(vmmap --summary "$PID" 2>/dev/null | awk '/MALLOC/ {sum+=$3} END {print sum+0}')
        HEAP=$(bc -l <<< "scale=0; $HEAP_RAW / 1024")
        HEAP=${HEAP%.*} 
        HEAP=${HEAP:-0}

        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

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
        if [ "$(wc -l < "$OUTPUT")" -gt 1 ]; then
            echo "," >> "$OUTPUT"
        fi
        echo "$ENTRY" >> "$OUTPUT"

        CPU0=$CPU_NOW
        TS0=$TS_NOW
    fi

    END_TS=$(date +%s.%N)
    ELAPSED=$(bc -l <<< "$END_TS - $START_TS")
    SLEEP_TIME=$(bc -l <<< "1 - $ELAPSED")
    
    if (( $(echo "$SLEEP_TIME > 0" | bc -l) )); then
        sleep "$SLEEP_TIME"
    fi
done

finish