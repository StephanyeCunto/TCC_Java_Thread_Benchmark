#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_TRAD="$SCRIPT_DIR/table_traditional.csv"
OUTPUT_VIRT="$SCRIPT_DIR/table_virtual.csv"

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

rate() { 
    JSON_DIR="$BASE/run/json"

    find "$JSON_DIR" -type f -name "run*.json" | while read -r f; do 
        req=$(jq -r '.rate // 0' "$f") 
        [[ "$req" != "0" ]] && echo "$req $(basename "$f" .json | sed 's/^run//')" 
    done | sort -nr | sed -n "3p" | awk '{ print $1  }'
}


echo "endpoint,run,Rate,JVM_CPU_pct,Native_Memory_GB,Heap_Used_MB" > "$OUTPUT_TRAD"
echo "endpoint,run,Rate,JVM_CPU_pct,Native_Memory_GB,Heap_Used_MB" > "$OUTPUT_VIRT"

for run in {1..20}; do

    if (( run % 2 == 0 )); then
        endpoint="virtual"
        OUTPUT="$OUTPUT_VIRT"
    else
        endpoint="traditional"
        OUTPUT="$OUTPUT_TRAD"
    fi

    BASE="$SCRIPT_DIR/$endpoint/$run"

    cpu=$(cpu_avg)
    native_mem=$(native_memory_avg "committed")
    heap=$(heap_used_avg)
    req=$(rate)

    echo "$endpoint,$run,$req,$cpu,$native_mem,$heap" >> "$OUTPUT"

done

echo "✅ Tabelas geradas:"
echo " - Traditional: $OUTPUT_TRAD"
echo " - Virtual: $OUTPUT_VIRT"
