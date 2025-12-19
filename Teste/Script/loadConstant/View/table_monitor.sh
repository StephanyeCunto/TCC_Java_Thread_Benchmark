#!/bin/bash

BASE_DIR="../Results/results"
OUTPUT="monitor_avg_full.csv"

# Cabeçalho do CSV
echo "tipo,run,cpu_mean,cpu_max,mem_percent_mean,mem_percent_max,rss_mb_mean,rss_mb_max,virtual_mb_mean,virtual_mb_max,heap_mb_mean,heap_mb_max,threads_mean,threads_max,ports_mean,ports_max" > "$OUTPUT"

# Buscar todos os monitor.json
find "$BASE_DIR" -type f -name "monitor.json" | sort | while read -r monitor_json; do

    # Extrair tipo, carga e run da estrutura de pastas
    tipo=$(echo "$monitor_json" | awk -F'/' '{print $(NF-2)}')       # traditional ou virtual
    run=$(echo "$monitor_json" | awk -F'/' '{print $(NF-3)}')       # pasta do run

    # Calcular médias e máximos usando jq
    cpu_mean=$(jq '[.[].cpu_percent] | add / length' "$monitor_json")
    cpu_max=$(jq '[.[].cpu_percent] | max' "$monitor_json")

    mem_percent_mean=$(jq '[.[].memory_percent] | add / length' "$monitor_json")
    mem_percent_max=$(jq '[.[].memory_percent] | max' "$monitor_json")

    rss_mb_mean=$(jq '[.[].memory_rss_mb] | add / length' "$monitor_json")
    rss_mb_max=$(jq '[.[].memory_rss_mb] | max' "$monitor_json")

    virtual_mb_mean=$(jq '[.[].memory_virtual_mb] | add / length' "$monitor_json")
    virtual_mb_max=$(jq '[.[].memory_virtual_mb] | max' "$monitor_json")

    heap_mb_mean=$(jq '[.[].memory_heap_mb] | add / length' "$monitor_json")
    heap_mb_max=$(jq '[.[].memory_heap_mb] | max' "$monitor_json")

    threads_mean=$(jq '[.[].threads] | add / length' "$monitor_json")
    threads_max=$(jq '[.[].threads] | max' "$monitor_json")

    ports_mean=$(jq '[.[].ports] | add / length' "$monitor_json")
    ports_max=$(jq '[.[].ports] | max' "$monitor_json")

    # Escrever linha no CSV
    echo "$tipo,$run,$cpu_mean,$cpu_max,$mem_percent_mean,$mem_percent_max,$rss_mb_mean,$rss_mb_max,$virtual_mb_mean,$virtual_mb_max,$heap_mb_mean,$heap_mb_max,$threads_mean,$threads_max,$ports_mean,$ports_max" >> "$OUTPUT"

done
