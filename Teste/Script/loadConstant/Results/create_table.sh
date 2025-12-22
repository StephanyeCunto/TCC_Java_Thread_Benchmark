#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/table.csv"

# Função para calcular média de um campo específico no JSON
avg(){
    jq '[.recording.events[]?
        | select(.type == "'"$2"'")
        | .values.'"$3"'
        | select(. != null)
    ] | if length > 0 then add/length else 0 end' "$1"
}

# Média de CPU (jvmUser + jvmSystem) em %
cpu_avg(){
    user=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmUser")
    sys=$(avg "$BASE/Monitor/cpu_data.json" "jdk.CPULoad" "jvmSystem")
    echo "$(echo "($user + $sys) * 100" | bc -l)"
}

# Média de memória nativa por segundo, campo específico (committed ou reserved)
memory_avg_total(){
    field=$1  # "committed" ou "reserved"
    jq --arg field "$field" '
      [.recording.events[]
       | select(.type == "jdk.NativeMemoryUsage")
       | select(.values[$field] != null)
       | {second: (.values.startTime[0:19]), value: .values[$field]}
      ]
      | group_by(.second)
      | map([.[] | .value] | add)
      | if length > 0 then add / length else 0 end
      | . / (1024*1024*1024)
    ' "$BASE/Monitor/ram_data.json"
}

# Média de heap usado em MB
heap_used_avg(){
    bytes=$(jq '[.recording.events[]?
        | select(.type == "jdk.GCHeapSummary")
        | .values.heapUsed
        | select(. != null)
    ] | if length > 0 then add/length else 0 end' "$BASE/Monitor/heap_data.json")

    echo "$(echo "$bytes / (1024*1024)" | bc -l)"
}

# Cabeçalho da tabela CSV com duas colunas para Native Memory
echo "endpoint,run,JVM_CPU_pct,Native_Memory_Reserved_GB,Native_Memory_Committed_GB,Heap_Used_MB,lat_mean_s,lat_p50_s,lat_p90_s,lat_p95_s,lat_p99_s,lat_max_s,requests,rate,throughput,success,bytes_in_total" >> "$OUTPUT"

# Loop das execuções
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
    native_mem_reserved=$(memory_avg_total "reserved")
    native_mem_committed=$(memory_avg_total "committed")
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

    echo "$endpoint,$run,$cpu,$native_mem_reserved,$native_mem_committed,$heap,$lat_mean,$lat_p50,$lat_p90,$lat_p95,$lat_p99,$lat_max,$requests,$rate,$throughput,$success,$bytes_in" \
    >> "$OUTPUT"

done
