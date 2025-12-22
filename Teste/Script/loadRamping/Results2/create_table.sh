#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/table.csv"

avg(){
    jq '[.recording.events[]?
        | select(.type == "'"$2"'")
        | .values.'"$3"'
        | select(. != null)
    ] | if length > 0 then add/length else 0 end' "$1"
}

memory_avg(){
    jq '[.recording.events[]?
        | select(.type == "jdk.NativeMemoryUsage")
        | select(.values.type == "'"$2"'")
        | .values.'"$3"'
        | select(. != null)
    ] | if length > 0 then add/length else 0 end' "$1"
}

cpu_avg(){
    user=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmUser")
    sys=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmSystem")
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
    for t in "${TYPES[@]}"; do
        v=$(memory_avg "$BASE/Monitor/ram_data.json" "$t" committed)
        total=$(echo "$total + $v" | bc -l)
    done

    echo "$(echo "$total / (1024*1024*1024)" | bc -l)"
}

heap_used_avg(){
    bytes=$(jq '[.recording.events[]?
        | select(.type == "jdk.GCHeapSummary")
        | .values.heapUsed
        | select(. != null)
    ] | if length > 0 then add/length else 0 end' "$BASE/Monitor/heap_data.json")

    echo "$(echo "$bytes / (1024*1024)" | bc -l)"
}

requests(){
    JSON_DIR="$BASE/run/json"

    find "$JSON_DIR" -type f -name "run*.json" \
    | while read -r f; do
        req=$(jq -r '.requests // 0' "$f")
        run_num=$(basename "$f" .json | sed 's/^run//')
        echo "$req $run_num"
      done \
    | sort -nr \
    | head -1 \
    | awk '{ print $2 - 150 }'
}

echo "endpoint,run,Requests,JVM_CPU_pct,Native_Memory_GB,Heap_Used_MB" >> "$OUTPUT"


for run in {1..10}; do

    if (( run % 2 == 0 )); then
        endpoint="virtual"
    else
        endpoint="traditional"
    fi

    BASE="$SCRIPT_DIR/$endpoint/$run"

    cpu=$(cpu_avg)
    native_mem=$(memory_avg_total)
    heap=$(heap_used_avg)
    requests=$(requests)

    echo "$endpoint,$run,$requests,$cpu,$native_mem,$heap" >> "$OUTPUT"

done