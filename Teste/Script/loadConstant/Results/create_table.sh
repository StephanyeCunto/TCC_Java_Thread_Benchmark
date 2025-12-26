#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

OUTPUT_TRAD="$SCRIPT_DIR/table_traditional.csv"
OUTPUT_VIRT="$SCRIPT_DIR/table_virtual.csv"

write_header() {
    echo "run,lat_mean_s,lat_p50_s,lat_p90_s,lat_p95_s,lat_p99_s,lat_max_s,requests,rate,throughput,success,bytes_in_total,cpu_mean_pct,cpu_max_pct,mem_used_mb,mem_max_mb,heap_used_mb,heap_max_mb"
}

cpu_mean_max(){
    jq '
      [.recording.events[]
       | select(.type == "jdk.CPULoad")
       | (.values.jvmUser + .values.jvmSystem) * 100
      ] as $v
      | {
          mean: (if ($v|length)>0 then ($v|add/length) else 0 end),
          max:  (if ($v|length)>0 then ($v|max) else 0 end)
        }
    ' "$BASE/Monitor/cpu_data.json"
}

native_memory_committed_mb(){
    jq '
      [.recording.events[]
       | select(.type == "jdk.NativeMemoryUsage")
       | select(.values.committed != null)
       | .values.committed
      ] as $v
      | if ($v|length)>0 then ($v|add/length)/(1024*1024) else 0 end
    ' "$BASE/Monitor/ram_data.json"
}

heap_used_mean_max(){
    jq '
      [.recording.events[]
       | select(.type == "jdk.GCHeapSummary")
       | .values.heapUsed
      ] as $v
      | {
          mean: (if ($v|length)>0 then ($v|add/length)/(1024*1024) else 0 end),
          max:  (if ($v|length)>0 then ($v|max)/(1024*1024) else 0 end)
        }
    ' "$BASE/Monitor/heap_data.json"
}

write_header > "$OUTPUT_TRAD"
write_header > "$OUTPUT_VIRT"

for run in {1..100}; do

    if (( run % 2 == 0 )); then
        ENDPOINT="virtual"
        OUTPUT="$OUTPUT_VIRT"
    else
        ENDPOINT="traditional"
        OUTPUT="$OUTPUT_TRAD"
    fi

    BASE="$SCRIPT_DIR/$ENDPOINT/$run"
    JSON="$BASE/run/json/run${run}.json"

    [[ ! -f "$JSON" ]] && continue

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

    cpu_stats=$(cpu_mean_max)
    cpu_mean=$(echo "$cpu_stats" | jq -r '.mean')
    cpu_max=$(echo "$cpu_stats" | jq -r '.max')

    mem_stats=$(native_memory_committed_mb)
    mem_used=$(echo "$mem_stats" | jq -r '.mean')
    mem_max=$(echo "$mem_stats" | jq -r '.max')

    heap_stats=$(heap_used_mean_max)
    heap_used=$(echo "$heap_stats" | jq -r '.mean')
    heap_max=$(echo "$heap_stats" | jq -r '.max')

    echo "$run,$lat_mean,$lat_p50,$lat_p90,$lat_p95,$lat_p99,$lat_max,$requests,$rate,$throughput,$success,$bytes_in,$cpu_mean,$cpu_max,$mem_used,$mem_max,$heap_used,$heap_max" >> "$OUTPUT"

done
