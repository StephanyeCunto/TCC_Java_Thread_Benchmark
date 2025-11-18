#!/bin/bash

# $1 = nome do json gerado
# $2 = nome dos jsons existentes

load(){
    for i in {1..1}; do
        if [ $(($i % 2)) -eq 0 ]; then
            ENDPOINT="virtual"
        else
            ENDPOINT="traditional"
        fi
        OUTPUT=json/${ENDPOINT}/$1${i}.json
        
        echo "[" > $OUTPUT
        for j in {1..20}; do
            RATE=$((50 * j))
            FILES=${ENDPOINT}/${i}/$2${RATE}.json
            TOTAL=${#FILES[@]}

            for FILE in "${FILES[@]}"; do
                CONTENT=$(cat "$FILE" | tr -d '\n')

                if [ ${j} -lt 20 ]; then
                    echo "$CONTENT," >> $OUTPUT
                else
                    echo "$CONTENT" >> $OUTPUT
                fi
            done
        done
        echo "]" >> $OUTPUT
    done
}

loadExecucao(){
    load "Execucao" "run_"
}

loadGet(){
    load "GET" "run_GET"
}

loadExecucao
loadGet
