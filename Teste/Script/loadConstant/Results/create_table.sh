#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/table.csv"

# =========================
# Funções auxiliares
# =========================

# Média genérica de um campo de evento JFR
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

# =========================
# CPU
# =========================

# Média de CPU JVM (user + system) em %
cpu_avg(){
    local user sys
    user=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmUser")
    sys=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmSystem")
    echo "$(echo "($user + $sys) * 100" | bc -l)"
}

# =========================
# Memória Nativa JVM
# =========================

# Média de memória nativa total por segundo (GB)
native_memory_avg(){
    local FIELD=$1   # reserved | committed

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

# =========================
# Heap JVM
# =========================

# Média de heap usado (MB)
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

# =========================
# Memória Física (RAM)
# =========================

# Média de RAM usada do sistema (GB)
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

# =========================
# Cabeçalho CSV
# =========================

echo "endpoint,run,JVM_CPU_pct,Native_Memory_Reserved_GB,Native_Memory_Committed_GB,Physical_Memory_Used_GB,Heap_Used_MB,lat_mean_s,lat_p50_s,lat_p90_s,lat_p95_s,lat_p99_s,lat_max_s,requests,rate,throughput,success,bytes_in_total" \
> "$OUTPUT"

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
    JSON="$BASE/run/json/run${run}.json"

    if [[ ! -f "$JSON" ]]; then
        echo "⚠️ JSON não encontrado: $JSON"
        continue
    fi

    cpu=$(cpu_avg)
    native_reserved=$(native_memory_avg "reserved")
    native_committed=$(native_memory_avg "committed")
    physical_mem=$(physical_memory_used_avg)
    heap=$(heap_used_avg)

    lat_mean=$(jq -r '(.latencies.mean // empty) / 1e9' "$JSON")
    lat_p50=$(jq -r '(.latencies["50th"] // empty) / 1e9' "$JSON")
    lat_p90=$(jq -r '(.latencies["90th"] // empty) / 1e9' "$JSON")
    lat_p95=$(jq -r '(.latencies["95th"] // empty) / 1e9' "$JSON")
    lat_p99=$(jq -r '(.latencies["99th"] // empty) / 1e9' "$JSON")
    lat_max=$(jq -r '(.latencies.max // empty) / 1e9' "$JSON")

    requests=$(jq -r '.requests // empty' "$JSON")
    rate=$(jq -r '.rate // empty' "$JSON")
    throughput=$(jq -r '.throughput // empty' "$JSON")
    success=$(jq -r '.success // empty' "$JSON")
    bytes_in=$(jq -r '.bytes_in.total // empty' "$JSON")

    echo "$endpoint,$run,$cpu,$native_reserved,$native_committed,$physical_mem,$heap,$lat_mean,$lat_p50,$lat_p90,$lat_p95,$lat_p99,$lat_max,$requests,$rate,$throughput,$success,$bytes_in" \
    >> "$OUTPUT"

done
