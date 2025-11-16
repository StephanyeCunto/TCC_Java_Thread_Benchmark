#!/usr/bin/env bash
OUT="results/all.json"
echo "[" > "$OUT"
first=1
for f in results/*.json; do
  # pular o próprio all.json se já existir
  [ "$f" = "$OUT" ] && continue
  # extrair nome base, ex: run_50.json -> run_50
  name=$(basename "$f" .json)
  if [ $first -eq 1 ]; then
    first=0
  else
    echo "," >> "$OUT"
  fi
  jq --arg name "$name" '{name: $name, requests: .requests, success: .success, lat_mean: .latencies.mean, lat_p95: .latencies.p95, throughput: .throughput}' "$f" >> "$OUT"
done
echo "]" >> "$OUT"
echo "Wrote $OUT"


