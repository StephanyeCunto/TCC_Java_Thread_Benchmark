#!/bin/bash

BASE_DIR="../Results/results"
OUTPUT="tabel_runs.csv"

echo "modelo,carga,run,lat_mean_ns,lat_p50_ns,lat_p90_ns,lat_p95_ns,lat_p99_ns,lat_max_ns,requests,rate,throughput,success,bytes_in_total" > "$OUTPUT"

find "$BASE_DIR" -type f -path "*/run/json/*.json" | sort | while read -r json; do

    modelo=$(echo "$json" | awk -F'/' '{print $(NF-5)}')
    carga=$(echo "$json"  | awk -F'/' '{print $(NF-4)}')
    run=$(basename "$json" .json)

    lat_mean=$(jq -r '.latencies.mean // "null"' "$json")
    lat_p50=$(jq -r '.latencies["50th"] // "null"' "$json")
    lat_p90=$(jq -r '.latencies["90th"] // "null"' "$json")
    lat_p95=$(jq -r '.latencies["95th"] // "null"' "$json")
    lat_p99=$(jq -r '.latencies["99th"] // "null"' "$json")
    lat_max=$(jq -r '.latencies.max // "null"' "$json")

    requests=$(jq -r '.requests // "null"' "$json")
    rate=$(jq -r '.rate // "null"' "$json")
    throughput=$(jq -r '.throughput // "null"' "$json")
    success=$(jq -r '.success // "null"' "$json")
    bytes_in=$(jq -r '.bytes_in.total // "null"' "$json")

    echo "$modelo,$carga,$run,$lat_mean,$lat_p50,$lat_p90,$lat_p95,$lat_p99,$lat_max,$requests,$rate,$throughput,$success,$bytes_in" >> "$OUTPUT"

done

echo "✔ Tabela gerada: $OUTPUT"