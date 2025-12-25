SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

OUTPUT_TRAD="$SCRIPT_DIR/table_traditional.csv"
OUTPUT_VIRT="$SCRIPT_DIR/table_virtual.csv"

avg(){
    local FILE=$1
    local TYPE=$2
    local FIELD=$3

    jq '[.recording.events[]?
        | select(.type == "'"$TYPE"'")
        | .values.'"$FIELD"'
        | select(. != null)
    ] | if length > 0 then add/length else 0 end' "$FILE"
}

cpu_avg(){
    local user sys
    user=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmUser")
    sys=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmSystem")
    echo "$(echo "($user + $sys) * 100" | bc -l)"
}

native_memory_avg(){
    local FIELD=$1   

    jq --arg field "$FIELD" '
      [.recording.events[]
       | select(.type == "jdk.NativeMemoryUsage")
       | select(.values[$field] != null)
       | {sec: (.values.startTime[0:19]), val: .values[$field]}
      ]
      | group_by(.sec)
      | map([.[] | .val] | add)
      | if length > 0 then add/length else 0 end
      | . / (1024*1024*1024)
    ' "$BASE/Monitor/ram_data.json"
}

heap_used_avg(){
    local bytes

    bytes=$(jq '[.recording.events[]?
        | select(.type == "jdk.GCHeapSummary")
        | .values.heapUsed
        | select(. != null)
    ] | if length > 0 then add/length else 0 end' \
    "$BASE/Monitor/heap_data.json")

    echo "$(echo "$bytes / (1024*1024)" | bc -l)"
}

physical_memory_used_avg(){
    jq '
      [.recording.events[]
       | select(.type == "jdk.PhysicalMemory")
       | select(.values.usedSize != null)
       | .values.usedSize
      ]
      | if length > 0 then add/length else 0 end
      | . / (1024*1024*1024)
    ' "$BASE/Monitor/physical_memory.json"
}

write_header() {
    echo "endpoint,run,lat_mean_s,lat_p50_s,lat_p90_s,lat_p95_s,lat_p99_s,lat_max_s,requests,rate,throughput,success,bytes_in_total,JVM_CPU_pct,Native_Memory_Reserved_GB,Native_Memory_Committed_GB,Physical_Memory_Used_GB,Heap_Used_MB"
}

write_header > "$OUTPUT_TRAD"
write_header > "$OUTPUT_VIRT"

for run in {1..100}; do
    if (( run % 2 == 0 )); then
        endpoint="virtual"
        OUTPUT="$OUTPUT_VIRT"
    else
        endpoint="traditional"
        OUTPUT="$OUTPUT_TRAD"
    fi

    BASE="$SCRIPT_DIR/$endpoint/$run"
    JSON="$BASE/run/json/run${run}.json"

    [[ ! -f "$JSON" ]] && continue

    cpu=$(cpu_avg)
    native_reserved=$(native_memory_avg "reserved")
    native_committed=$(native_memory_avg "committed")
    physical_mem=$(physical_memory_used_avg)
    heap=$(heap_used_avg)

    lat_mean=$(jq -r '(.latencies.mean // 0) / 1e9' "$JSON")
    lat_p50=$(jq -r '(.latencies["50th"] // 0) / 1e9' "$JSON")
    lat_p90=$(jq -r '(.latencies["90th"] // 0) / 1e9' "$JSON")
    lat_p95=$(jq -r '(.latencies["95th"] // 0) / 1e9' "$JSON")
    lat_p99=$(jq -r '(.latencies["99th"] // 0) / 1e9' "$JSON")
    lat_max=$(jq -r '(.latencies.max // 0) / 1e9' "$JSON")

    requests=$(jq -r '.requests // 0' "$JSON")
    rate=$(jq -r '.rate // 0' "$JSON")
    throughput=$(jq -r '.throughput // 0' "$JSON")
    success=$(jq -r '.success // 0' "$JSON")
    bytes_in=$(jq -r '.bytes_in.total // 0' "$JSON")

echo "$endpoint,$run,$lat_mean,$lat_p50,$lat_p90,$lat_p95,$lat_p99,$lat_max,$requests,$rate,$throughput,$success,$bytes_in,$cpu,$native_reserved,$native_committed,$physical_mem,$heap" >> "$OUTPUT"

done

add_average_row() {
    local FILE=$1

    awk -F',' '
    NR==1 { header=$0; next }
    {
        for (i=3; i<=NF; i++) {
            sum[i] += $i
        }
        count++
    }
    END {
        printf "AVG,AVG"
        for (i=3; i<=NF; i++) {
            printf ",%f", sum[i]/count
        }
        printf "\n"
    }' "$FILE" >> "$FILE"
}

add_average_row "$OUTPUT_VIRT"
add_average_row "$OUTPUT_TRAD"