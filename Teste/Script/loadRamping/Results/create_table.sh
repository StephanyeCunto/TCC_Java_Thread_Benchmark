#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/table.csv"

# =========================
# Funções auxiliares
# =========================

avg(){
    jq '[.recording.events[]?
        | select(.type == "'"$2"'")
        | .values.'"$3"'
        | select(. != null and . != 0)
    ] | if length > 0 then add/length else empty end' "$1"
}

native_memory_avg(){
    local FIELD=$1   

    jq --arg field "$FIELD" '
      [.recording.events[]
       | select(.type == "jdk.NativeMemoryUsage")
       | select(.values[$field] != null and .values[$field] != 0)
       | {sec: (.values.startTime[0:19]), val: .values[$field]}
      ]
      | group_by(.sec)
      | map([.[] | .val] | add)
      | if length > 0 then add/length else empty end
      | . / (1024*1024*1024)
    ' "$BASE/Monitor/ram_data.json"
}

cpu_avg(){
    user=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmUser")
    sys=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmSystem")

    if [[ -z "$user" || -z "$sys" ]]; then
        echo ""
        return
    fi

    echo "$(echo "($user + $sys) * 100" | bc -l)"
}

memory_avg_total(){
    TYPES=(
        "Java Heap" "Class" "Thread" "Thread Stack" "Code" "GC"
        "GCCardSet" "Compiler" "JVMCI" "Internal" "Other" "Symbol"
        "Native Memory Tracking" "Shared class space" "Arena Chunk"
        "Tracing" "Logging" "Arguments" "Module" "Safepoint"
        "Synchronization" "Metaspace" "Object Monitors"
    )

    total=0
    found=0

    for t in "${TYPES[@]}"; do
        v=$(memory_avg "$BASE/Monitor/ram_data.json" "$t" committed)
        if [[ -n "$v" && "$v" != "0" ]]; then
            total=$(echo "$total + $v" | bc -l)
            found=1
        fi
    done

    if [[ "$found" -eq 1 ]]; then
        echo "$(echo "$total / (1024*1024*1024)" | bc -l)"
    fi
}

heap_used_avg(){
    bytes=$(jq '[.recording.events[]?
        | select(.type == "jdk.GCHeapSummary")
        | .values.heapUsed
        | select(. != null and . != 0)
    ] | if length > 0 then add/length else empty end' "$BASE/Monitor/heap_data.json")

    if [[ -n "$bytes" ]]; then
        echo "$(echo "$bytes / (1024*1024)" | bc -l)"
    fi
}

requests(){
    JSON_DIR="$BASE/run/json"

    find "$JSON_DIR" -type f -name "run*.json" \
    | while read -r f; do
        req=$(jq -r '.requests // 0' "$f")
        [[ "$req" != "0" ]] && echo "$req $(basename "$f" .json | sed 's/^run//')"
      done \
    | sort -nr \
    | head -1 \
    | awk '{ print $2 - 150 }'
}

# =========================
# Cabeçalho CSV
# =========================

echo "endpoint,run,Requests,JVM_CPU_pct,Native_Memory_GB,Heap_Used_MB" > "$OUTPUT"

# =========================
# Loop principal
# =========================

for run in {1..10}; do

    if (( run % 2 == 0 )); then
        endpoint="virtual"
    else
        endpoint="traditional"
    fi

    BASE="$SCRIPT_DIR/$endpoint/$run"

    cpu=$(cpu_avg)
    native_mem=$(native_memory_avg "committed")
    heap=$(heap_used_avg)
    req=$(requests)

    # Só grava se nenhum campo for vazio ou zero
    if [[ -n "$cpu" && -n "$native_mem" && -n "$heap" && -n "$req" ]]; then
        echo "$endpoint,$run,$req,$cpu,$native_mem,$heap" >> "$OUTPUT"
    fi

done
