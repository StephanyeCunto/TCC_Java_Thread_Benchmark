
LOG_PATH="Documents/tcc/Teste/Script/LoadConstant/Results/logs"

prepare_environment(){
    echo "=== Preparando ambiente no servidor (macOS Apple Silicon) ==="

    SENHA_SUDO="120504"

    $SSH "
        echo '>> ulimit (max files)'
        ulimit -n unlimited
        ulimit -s 65532

        echo '>> sysctl macOS (files & network)'
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxfiles=1048576
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxfilesperproc=1048576
        echo '$SENHA_SUDO' | sudo sysctl -w kern.ipc.somaxconn=4096
        echo '$SENHA_SUDO' | sudo sysctl -w kern.ipc.maxsockbuf=8388608

        echo '>> sysctl macOS (processes)'
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxproc=10000
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxprocperuid=10000

        echo '>> sysctl macOS (TCP buffers)'
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.sendspace=2097152
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.recvspace=2097152
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.msl=250
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.delayed_ack=0

        echo '>> sysctl macOS (EPHEMERAL PORT RANGE)'
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.ip.portrange.first=1024
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.ip.portrange.last=65535

        echo '>> Conferência portas efêmeras'
        sysctl net.inet.ip.portrange.first
        sysctl net.inet.ip.portrange.last

        echo '>> Informações do sistema'
        uname -a
        sysctl -n hw.ncpu
        sysctl -n hw.memsize | awk '{print \$1/1024/1024/1024 \" GB\"}'
        ulimit -n
    "
}

loadMonitor() {
    ENDPOINT="$1"
    j="$2"
    ADRESS="$3"

    echo "=== Load Monitor ==="

    PID=$($SSH "cat $LOG_PATH/server.pid" 2>/dev/null)

    $SSH "mkdir -p Documents/tcc/Teste/Script/$ADRESS/$RESULTS_PATH/$ENDPOINT/$j/monitor"

    $SSH "
        nohup bash Documents/tcc/Teste/Script/monitor.sh \
        $PID \
        Documents/tcc/Teste/Script/$ADRESS/$RESULTS_PATH/$ENDPOINT/$j/monitor/monitor.json \
        > /dev/null 2>&1 &
    "
}


