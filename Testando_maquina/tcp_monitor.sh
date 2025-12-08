#!/bin/bash

# Monitor de Performance para Spring Boot + Vegeta
# Monitora portas efêmeras, CPU, RAM, conexões TCP e emite alertas

# Configurações
OUTPUT_DIR="./monitoring_logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${OUTPUT_DIR}/monitor_${TIMESTAMP}.json"
ALERT_FILE="${OUTPUT_DIR}/alerts_${TIMESTAMP}.log"
SUMMARY_FILE="${OUTPUT_DIR}/summary_${TIMESTAMP}.txt"
INTERVAL=1  # Intervalo de coleta em segundos

# Limites de alerta (ajuste conforme sua máquina)
CPU_LIMIT=80           # % de uso de CPU
MEMORY_LIMIT=80        # % de uso de memória
EPHEMERAL_LIMIT=50000  # Número de portas efêmeras em uso
CONNECTIONS_LIMIT=40000 # Número total de conexões TCP
TIME_WAIT_LIMIT=10000  # Conexões em TIME_WAIT

# Cores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Criar diretório de logs
mkdir -p "$OUTPUT_DIR"

# Arrays para estatísticas
declare -a cpu_samples
declare -a mem_samples
declare -a conn_samples

# Função para emitir alertas
emit_alert() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${RED}[ALERT ${level}] ${timestamp}: ${message}${NC}"
    echo "[ALERT ${level}] ${timestamp}: ${message}" >> "$ALERT_FILE"
}

# Função para obter portas efêmeras configuradas
get_ephemeral_range() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cat /proc/sys/net/ipv4/ip_local_port_range
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        local first=$(sysctl -n net.inet.ip.portrange.first 2>/dev/null || echo "49152")
        local last=$(sysctl -n net.inet.ip.portrange.last 2>/dev/null || echo "65535")
        echo "$first $last"
    fi
}

# Função para coletar métricas
collect_metrics() {
    local timestamp=$(date +%s)
    local datetime=$(date '+%Y-%m-%d %H:%M:%S')
    local output_type=${1:-"json"}  # "json" ou "display"
    
    # CPU - Normalizado para 100%
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Obter número de cores
        num_cores=$(sysctl -n hw.ncpu)
        # Somar CPU de todos os processos e normalizar
        cpu_total=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.1f", s}')
        cpu_usage=$(awk "BEGIN {printf \"%.1f\", $cpu_total / $num_cores}")
    fi
    
    # Garantir que cpu_usage é um número válido e máximo de 100%
    cpu_usage=${cpu_usage:-0}
    cpu_usage=$(awk "BEGIN {if ($cpu_usage > 100) print 100; else print $cpu_usage}")
    
    # Memória
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        mem_info=$(free | grep Mem)
        mem_total=$(echo $mem_info | awk '{print $2}')
        mem_used=$(echo $mem_info | awk '{print $3}')
        mem_usage=$(awk "BEGIN {printf \"%.2f\", ($mem_used/$mem_total)*100}")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        mem_total=$(sysctl -n hw.memsize)
        mem_total_mb=$((mem_total / 1024 / 1024))
        
        # Cálculo mais preciso para macOS
        mem_stats=$(vm_stat)
        pages_active=$(echo "$mem_stats" | awk '/Pages active/ {print $3}' | sed 's/\.//')
        pages_wired=$(echo "$mem_stats" | awk '/Pages wired down/ {print $4}' | sed 's/\.//')
        pages_compressed=$(echo "$mem_stats" | awk '/Pages occupied by compressor/ {print $5}' | sed 's/\.//')
        
        pages_active=${pages_active:-0}
        pages_wired=${pages_wired:-0}
        pages_compressed=${pages_compressed:-0}
        
        mem_used=$(( (pages_active + pages_wired + pages_compressed) * 4096 ))
        mem_used_mb=$((mem_used / 1024 / 1024))
        mem_usage=$(awk "BEGIN {printf \"%.2f\", ($mem_used/$mem_total)*100}")
    fi
    
    # Garantir valores válidos
    mem_total_mb=${mem_total_mb:-0}
    mem_used_mb=${mem_used_mb:-0}
    mem_usage=${mem_usage:-0}
    
    # Portas efêmeras em uso
    if command -v ss &> /dev/null; then
        ephemeral_ports=$(ss -tan 2>/dev/null | grep -E "ESTAB|TIME-WAIT|FIN-WAIT" | wc -l | tr -d ' ')
    else
        ephemeral_ports=$(netstat -an 2>/dev/null | grep -E "ESTABLISHED|TIME_WAIT|FIN_WAIT" | wc -l | tr -d ' ')
    fi
    
    ephemeral_ports=${ephemeral_ports:-0}
    
    # Conexões TCP por estado
    if command -v ss &> /dev/null; then
        established=$(ss -tan 2>/dev/null | grep ESTAB | wc -l | tr -d ' ')
        time_wait=$(ss -tan 2>/dev/null | grep TIME-WAIT | wc -l | tr -d ' ')
        fin_wait=$(ss -tan 2>/dev/null | grep FIN-WAIT | wc -l | tr -d ' ')
        close_wait=$(ss -tan 2>/dev/null | grep CLOSE-WAIT | wc -l | tr -d ' ')
        syn_sent=$(ss -tan 2>/dev/null | grep SYN-SENT | wc -l | tr -d ' ')
        syn_recv=$(ss -tan 2>/dev/null | grep SYN-RECV | wc -l | tr -d ' ')
    else
        established=$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l | tr -d ' ')
        time_wait=$(netstat -an 2>/dev/null | grep TIME_WAIT | wc -l | tr -d ' ')
        fin_wait=$(netstat -an 2>/dev/null | grep FIN_WAIT | wc -l | tr -d ' ')
        close_wait=$(netstat -an 2>/dev/null | grep CLOSE_WAIT | wc -l | tr -d ' ')
        syn_sent=$(netstat -an 2>/dev/null | grep SYN_SENT | wc -l | tr -d ' ')
        syn_recv=$(netstat -an 2>/dev/null | grep SYN_RECV | wc -l | tr -d ' ')
    fi
    
    # Garantir valores numéricos
    established=${established:-0}
    time_wait=${time_wait:-0}
    fin_wait=${fin_wait:-0}
    close_wait=${close_wait:-0}
    syn_sent=${syn_sent:-0}
    syn_recv=${syn_recv:-0}
    
    total_connections=$((established + time_wait + fin_wait + close_wait + syn_sent + syn_recv))
    
    # Processos Java/Spring Boot
    java_pids=$(pgrep -f "spring-boot\|java.*jar" | tr '\n' ',' | sed 's/,$//')
    java_cpu=0
    java_mem=0
    
    if [ -n "$java_pids" ]; then
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            java_stats=$(ps -p $java_pids -o %cpu,%mem --no-headers 2>/dev/null)
            java_cpu=$(echo "$java_stats" | awk '{sum+=$1} END {printf "%.1f", sum}')
            java_mem=$(echo "$java_stats" | awk '{sum+=$2} END {printf "%.2f", sum}')
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # Normalizar CPU do Java também
            num_cores=$(sysctl -n hw.ncpu)
            IFS=',' read -ra PIDS <<< "$java_pids"
            for pid in "${PIDS[@]}"; do
                if ps -p "$pid" > /dev/null 2>&1; then
                    cpu=$(ps -p "$pid" -o %cpu | tail -n 1 | tr -d ' ')
                    mem=$(ps -p "$pid" -o %mem | tail -n 1 | tr -d ' ')
                    java_cpu=$(awk "BEGIN {printf \"%.1f\", $java_cpu + $cpu}")
                    java_mem=$(awk "BEGIN {printf \"%.2f\", $java_mem + $mem}")
                fi
            done
            # Normalizar para 100%
            java_cpu=$(awk "BEGIN {printf \"%.1f\", $java_cpu / $num_cores}")
            java_cpu=$(awk "BEGIN {if ($java_cpu > 100) print 100; else print $java_cpu}")
        fi
    fi
    
    java_cpu=${java_cpu:-0}
    java_mem=${java_mem:-0}
    
    # File descriptors abertos
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        fd_count=$(lsof -n 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        fd_count=$(lsof -n 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    fi
    
    fd_count=${fd_count:-0}
    
    # Conexões específicas na porta 8080
    if command -v ss &> /dev/null; then
        connections_8080=$(ss -tan 2>/dev/null | grep ":8080" | wc -l | tr -d ' ')
    else
        connections_8080=$(netstat -an 2>/dev/null | grep ":8080" | wc -l | tr -d ' ')
    fi
    
    connections_8080=${connections_8080:-0}
    
    # Range de portas efêmeras
    ephemeral_range=$(get_ephemeral_range | tr '\n' '-' | sed 's/-$//')
    
    # Armazenar amostras para estatísticas
    cpu_samples+=($cpu_usage)
    mem_samples+=($mem_usage)
    conn_samples+=($total_connections)
    
    # Verificar limites e emitir alertas
    if (( $(echo "$cpu_usage > $CPU_LIMIT" | bc -l 2>/dev/null || echo 0) )); then
        emit_alert "HIGH" "CPU usage at ${cpu_usage}% (limit: ${CPU_LIMIT}%)"
    fi
    
    if (( $(echo "$mem_usage > $MEMORY_LIMIT" | bc -l 2>/dev/null || echo 0) )); then
        emit_alert "HIGH" "Memory usage at ${mem_usage}% (limit: ${MEMORY_LIMIT}%)"
    fi
    
    if [ "$ephemeral_ports" -gt "$EPHEMERAL_LIMIT" ]; then
        emit_alert "CRITICAL" "Ephemeral ports usage: ${ephemeral_ports} (limit: ${EPHEMERAL_LIMIT})"
    fi
    
    if [ "$total_connections" -gt "$CONNECTIONS_LIMIT" ]; then
        emit_alert "CRITICAL" "Total TCP connections: ${total_connections} (limit: ${CONNECTIONS_LIMIT})"
    fi
    
    if [ "$time_wait" -gt "$TIME_WAIT_LIMIT" ]; then
        emit_alert "WARNING" "TIME_WAIT connections: ${time_wait} (limit: ${TIME_WAIT_LIMIT})"
    fi
    
    # Retornar baseado no tipo solicitado
    if [ "$output_type" == "display" ]; then
        echo "$cpu_usage|$mem_usage|$total_connections|$time_wait"
    else
        # Retornar JSON
        cat <<EOF
{
  "timestamp": $timestamp,
  "datetime": "$datetime",
  "system": {
    "cpu_usage_percent": $cpu_usage,
    "memory": {
      "total_mb": $mem_total_mb,
      "used_mb": $mem_used_mb,
      "usage_percent": $mem_usage
    },
    "file_descriptors": $fd_count
  },
  "network": {
    "ephemeral_ports_used": $ephemeral_ports,
    "ephemeral_range": "$ephemeral_range",
    "total_connections": $total_connections,
    "connections_by_state": {
      "established": $established,
      "time_wait": $time_wait,
      "fin_wait": $fin_wait,
      "close_wait": $close_wait,
      "syn_sent": $syn_sent,
      "syn_recv": $syn_recv
    },
    "port_8080_connections": $connections_8080
  },
  "application": {
    "java_pids": "$java_pids",
    "java_cpu_percent": $java_cpu,
    "java_memory_percent": $java_mem
  }
}
EOF
    fi
}

# Função para calcular estatísticas
calculate_stats() {
    local -n arr=$1
    local count=${#arr[@]}
    
    if [ $count -eq 0 ]; then
        echo "0|0|0|0"
        return
    fi
    
    # Min, Max, Avg
    local min=${arr[0]}
    local max=${arr[0]}
    local sum=0
    
    for val in "${arr[@]}"; do
        sum=$(awk "BEGIN {printf \"%.2f\", $sum + $val}")
        if (( $(echo "$val < $min" | bc -l) )); then
            min=$val
        fi
        if (( $(echo "$val > $max" | bc -l) )); then
            max=$val
        fi
    done
    
    local avg=$(awk "BEGIN {printf \"%.2f\", $sum / $count}")
    
    echo "$min|$max|$avg|$count"
}

# Função para análise dos resultados do Vegeta
analyze_vegeta_results() {
    local success_rate=$1
    
    echo -e "\n${YELLOW}=== Análise dos Resultados do Vegeta ===${NC}" | tee -a "$SUMMARY_FILE"
    
    if (( $(echo "$success_rate < 90" | bc -l) )); then
        emit_alert "CRITICAL" "Success rate muito baixo: ${success_rate}% - Possíveis causas: esgotamento de portas efêmeras, timeout de conexões, sobrecarga do servidor"
    fi
    
    echo -e "\n${GREEN}Causas Prováveis dos Erros 'operation timed out':${NC}" | tee -a "$SUMMARY_FILE"
    echo "1. Esgotamento de portas efêmeras locais (cliente)" | tee -a "$SUMMARY_FILE"
    echo "2. Limite de file descriptors atingido" | tee -a "$SUMMARY_FILE"
    echo "3. Backlog de conexões TCP cheio no servidor" | tee -a "$SUMMARY_FILE"
    echo "4. Timeout de conexões devido a sobrecarga" | tee -a "$SUMMARY_FILE"
    echo "5. Muitas conexões em TIME_WAIT" | tee -a "$SUMMARY_FILE"
    
    echo -e "\n${GREEN}Soluções Recomendadas:${NC}" | tee -a "$SUMMARY_FILE"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "\n${BLUE}Configurações para macOS:${NC}" | tee -a "$SUMMARY_FILE"
        echo "1. Aumentar range de portas efêmeras:" | tee -a "$SUMMARY_FILE"
        echo "   sudo sysctl -w net.inet.ip.portrange.first=10000" | tee -a "$SUMMARY_FILE"
        echo "   sudo sysctl -w net.inet.ip.portrange.last=65535" | tee -a "$SUMMARY_FILE"
        echo "" | tee -a "$SUMMARY_FILE"
        echo "2. Reduzir tempo de TIME_WAIT:" | tee -a "$SUMMARY_FILE"
        echo "   sudo sysctl -w net.inet.tcp.msl=1000" | tee -a "$SUMMARY_FILE"
        echo "" | tee -a "$SUMMARY_FILE"
        echo "3. Aumentar file descriptors:" | tee -a "$SUMMARY_FILE"
        echo "   ulimit -n 65535" | tee -a "$SUMMARY_FILE"
        echo "" | tee -a "$SUMMARY_FILE"
    else
        echo -e "\n${BLUE}Configurações para Linux:${NC}" | tee -a "$SUMMARY_FILE"
        echo "1. Aumentar range de portas efêmeras:" | tee -a "$SUMMARY_FILE"
        echo "   echo '1024 65535' | sudo tee /proc/sys/net/ipv4/ip_local_port_range" | tee -a "$SUMMARY_FILE"
        echo "" | tee -a "$SUMMARY_FILE"
        echo "2. Reduzir tempo de TIME_WAIT:" | tee -a "$SUMMARY_FILE"
        echo "   echo '1' | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse" | tee -a "$SUMMARY_FILE"
        echo "   echo '30' | sudo tee /proc/sys/net/ipv4/tcp_fin_timeout" | tee -a "$SUMMARY_FILE"
        echo "" | tee -a "$SUMMARY_FILE"
        echo "3. Aumentar file descriptors:" | tee -a "$SUMMARY_FILE"
        echo "   ulimit -n 65535" | tee -a "$SUMMARY_FILE"
        echo "" | tee -a "$SUMMARY_FILE"
    fi
    
    echo "4. Ajustar application.properties do Spring Boot:" | tee -a "$SUMMARY_FILE"
    echo "   server.tomcat.accept-count=1000" | tee -a "$SUMMARY_FILE"
    echo "   server.tomcat.max-connections=10000" | tee -a "$SUMMARY_FILE"
    echo "   server.tomcat.threads.max=500" | tee -a "$SUMMARY_FILE"
}

# Função para gerar resumo
generate_summary() {
    echo -e "\n${GREEN}=== Resumo Estatístico ===${NC}" | tee -a "$SUMMARY_FILE"
    
    cpu_stats=$(calculate_stats cpu_samples)
    mem_stats=$(calculate_stats mem_samples)
    conn_stats=$(calculate_stats conn_samples)
    
    IFS='|' read -r cpu_min cpu_max cpu_avg cpu_count <<< "$cpu_stats"
    IFS='|' read -r mem_min mem_max mem_avg mem_count <<< "$mem_stats"
    IFS='|' read -r conn_min conn_max conn_avg conn_count <<< "$conn_stats"
    
    echo "" | tee -a "$SUMMARY_FILE"
    echo "CPU Usage:" | tee -a "$SUMMARY_FILE"
    echo "  Min: ${cpu_min}% | Max: ${cpu_max}% | Avg: ${cpu_avg}%" | tee -a "$SUMMARY_FILE"
    echo "" | tee -a "$SUMMARY_FILE"
    echo "Memory Usage:" | tee -a "$SUMMARY_FILE"
    echo "  Min: ${mem_min}% | Max: ${mem_max}% | Avg: ${mem_avg}%" | tee -a "$SUMMARY_FILE"
    echo "" | tee -a "$SUMMARY_FILE"
    echo "Total Connections:" | tee -a "$SUMMARY_FILE"
    echo "  Min: ${conn_min} | Max: ${conn_max} | Avg: ${conn_avg}" | tee -a "$SUMMARY_FILE"
    echo "" | tee -a "$SUMMARY_FILE"
    echo "Total de amostras coletadas: ${cpu_count}" | tee -a "$SUMMARY_FILE"
}

# Main loop
echo -e "${GREEN}=== Monitor de Performance Iniciado ===${NC}"
echo "Logs serão salvos em: $LOG_FILE"
echo "Alertas serão salvos em: $ALERT_FILE"
echo "Sistema detectado: $OSTYPE"
echo "Pressione Ctrl+C para parar"
echo ""

# Iniciar arquivo JSON
echo "[" > "$LOG_FILE"
first_entry=true

trap ctrl_c INT
function ctrl_c() {
    echo -e "\n${YELLOW}Finalizando monitoramento...${NC}"
    
    # Fechar JSON
    if [ "$first_entry" = false ]; then
        echo "" >> "$LOG_FILE"
    fi
    echo "]" >> "$LOG_FILE"
    
    # Gerar resumo
    generate_summary
    
    # Análise baseada nos resultados do Vegeta fornecidos
    analyze_vegeta_results 85.31
    
    echo -e "\n${GREEN}Arquivos gerados:${NC}"
    echo "  Logs JSON: $LOG_FILE"
    echo "  Alertas: $ALERT_FILE"
    echo "  Resumo: $SUMMARY_FILE"
    exit 0
}

while true; do
    # Coletar JSON
    json_output=$(collect_metrics "json")
    
    # Escrever JSON no arquivo
    if [ "$first_entry" = true ]; then
        echo "$json_output" >> "$LOG_FILE"
        first_entry=false
    else
        echo "," >> "$LOG_FILE"
        echo "$json_output" >> "$LOG_FILE"
    fi
    
    # Coletar dados para display
    display_data=$(collect_metrics "display")
    
    # Display no terminal
    IFS='|' read -r cpu mem conns tw <<< "$display_data"
    echo -ne "\r$(date '+%H:%M:%S') | CPU: ${cpu}% | MEM: ${mem}% | Conns: ${conns} | TIME_WAIT: ${tw}    "
    
    sleep $INTERVAL
done