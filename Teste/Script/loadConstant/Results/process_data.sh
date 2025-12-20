#!/bin/bash

for j in {1..2}; do
	if [ $(($j % 2)) -eq 0 ]; then
		BASE_DIR="./virtual"
	else
		BASE_DIR="./traditional"
	fi

	process_jfr() {
		local jfr_file="$1"
		local monitor_dir="$(dirname "$jfr_file")"
		local output_dir="$monitor_dir/json"
		local base_name="$(basename "$jfr_file" .jfr)"

		mkdir -p "$output_dir"

		echo "▶ Processing: $jfr_file"

		jfr print --json \
			--events "jdk.CPULoad" \
			"$jfr_file" \
			> "$output_dir/${base_name}_cpu.json"

		jfr print --json \
			--events "jdk.GCHeapSummary" \
			"$jfr_file" \
			> "$output_dir/${base_name}_heap.json"

		jfr print --json \
			--events "jdk.ThreadStatistics" \
			"$jfr_file" \
			> "$output_dir/${base_name}_threads.json"

		jfr print --json \
			--events "jdk.PhysicalMemory" \
			"$jfr_file" \
			> "$output_dir/${base_name}_ram.json"

		echo "✔ JSONs gerados em: $output_dir"
	}

	find "$BASE_DIR" -type d -name "Monitor" | while read monitor_dir; do
		for jfr_file in "$monitor_dir"/*.jfr; do
			[ -f "$jfr_file" ] && process_jfr "$jfr_file"
		done
	done

	echo "All JFR files processed ${BASE_DIR}!"
	
done
