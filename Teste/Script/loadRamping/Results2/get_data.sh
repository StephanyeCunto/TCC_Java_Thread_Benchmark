SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for j in {1..10}; do

    if (( j % 2 == 0)); then
        ROOT_DIR="$SCRIPT_DIR/virtual"
    else
        ROOT_DIR="$SCRIPT_DIR/traditional"
    fi

    jfr print --json --events "jdk.CPULoad,jdk.ExecutionSample" $ROOT_DIR/$j/Monitor/Monitor.jfr > $ROOT_DIR/$j/Monitor/cpu_data.json

    jfr print --json --events "jdk.GCHeapSummary" $ROOT_DIR/$j/Monitor/Monitor.jfr > $ROOT_DIR/$j/Monitor/heap_data.json

    jfr print --json --events "jdk.NativeMemoryUsage" $ROOT_DIR/$j/Monitor/Monitor.jfr > $ROOT_DIR/$j/Monitor/ram_data.json

done