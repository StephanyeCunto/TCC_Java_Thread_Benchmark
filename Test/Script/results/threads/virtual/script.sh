#!/bin/bash

# Arquivo de saída
OUTPUT="all.json"

# Começa o array
echo "[" > $OUTPUT

# Conta quantos arquivos temos para saber quando não adicionar vírgula extra
FILES=(run_*.json)
TOTAL=${#FILES[@]}
COUNT=0

for FILE in "${FILES[@]}"; do
    COUNT=$((COUNT+1))
    
    # Remove possíveis quebras de linha no final do arquivo
    CONTENT=$(cat "$FILE" | tr -d '\n')
    
    # Adiciona vírgula se não for o último
    if [ $COUNT -lt $TOTAL ]; then
        echo "$CONTENT," >> $OUTPUT
    else
        echo "$CONTENT" >> $OUTPUT
    fi
done

# Fecha o array
echo "]" >> $OUTPUT

echo "Todos os arquivos foram unidos em $OUTPUT"
