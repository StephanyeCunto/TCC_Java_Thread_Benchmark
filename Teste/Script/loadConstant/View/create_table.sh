#!/bin/bash

BASE_DIR="../Results/results"
OUTPUT="table.csv"

echo "carga,run,lat_mean_s,lat_p50_s,lat_p90_s,lat_p95_s,lat_p99_s,lat_max_s,requests,rate,throughput,success,bytes_in_total,cpu_mean,cpu_max,mem_mean,mem_max,rss_mean_kb,rss_max_kb,threads_mean,threads_max" > "$OUTPUT"

find "$BASE_DIR" -type f -path "*/run/json/*.json" | sort | while read -r json; do

   # modelo=$(echo "$json" | awk -F'/' '{print $(NF-5)}')
    carga=$(echo "$json"  | awk -F'/' '{print $(NF-4)}')
    run=$(basename "$json" .json )
    run=${run#run}

    lat_mean=$(jq -r '(.latencies.mean // empty) | . / 1e9' "$json")
    lat_p50=$(jq -r '(.latencies["50th"] // empty) | . / 1e9' "$json")
    lat_p90=$(jq -r '(.latencies["90th"] // empty) | . / 1e9' "$json")
    lat_p95=$(jq -r '(.latencies["95th"] // empty) | . / 1e9' "$json")
    lat_p99=$(jq -r '(.latencies["99th"] // empty) | . / 1e9' "$json")
    lat_max=$(jq -r '(.latencies.max // empty) | . / 1e9' "$json")

    requests=$(jq -r '.requests // empty' "$json")
    rate=$(jq -r '.rate // empty' "$json")
    throughput=$(jq -r '.throughput // empty' "$json")
    success=$(jq -r '.success // empty' "$json")
    bytes_in=$(jq -r '.bytes_in.total // empty' "$json")

    base_run_dir="$(dirname "$(dirname "$(dirname "$json")")")"
    monitor_json="$base_run_dir/monitor/monitor.json"

    if [ -f "$monitor_json" ]; then
        cpu_mean=$(jq -r '[.[].cpu_percent] | add / length' "$monitor_json")
        cpu_max=$(jq -r '[.[].cpu_percent] | max' "$monitor_json")

        mem_mean=$(jq -r '[.[].memory_percent] | add / length' "$monitor_json")
        mem_max=$(jq -r '[.[].memory_percent] | max' "$monitor_json")

        rss_mean=$(jq -r '[.[].rss_kb] | add / length' "$monitor_json")
        rss_max=$(jq -r '[.[].rss_kb] | max' "$monitor_json")

        threads_mean=$(jq -r '[.[].threads] | add / length' "$monitor_json")
        threads_max=$(jq -r '[.[].threads] | max' "$monitor_json")
    else
        cpu_mean=""
        cpu_max=""
        mem_mean=""
        mem_max=""
        rss_mean=""
        rss_max=""
        threads_mean=""
        threads_max=""
    fi

    echo "$carga,$run,$lat_mean,$lat_p50,$lat_p90,$lat_p95,$lat_p99,$lat_max,$requests,$rate,$throughput,$success,$bytes_in,$cpu_mean,$cpu_max,$mem_mean,$mem_max,$rss_mean,$rss_max,$threads_mean,$threads_max" >> "$OUTPUT"

done