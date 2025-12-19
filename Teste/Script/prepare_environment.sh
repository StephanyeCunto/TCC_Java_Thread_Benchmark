
LOG_PATH="Documents/tcc/Teste/Script/LoadConstant/Results/logs"

prepare_environment(){
    echo "=== Preparando ambiente no servidor (macOS Apple Silicon) ==="

    SENHA_SUDO="120504"

    $SSH "
        ulimit -n unlimited
        ulimit -s 65532

        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxfiles=1048576
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxfilesperproc=1048576
        echo '$SENHA_SUDO' | sudo sysctl -w kern.ipc.somaxconn=4096
        echo '$SENHA_SUDO' | sudo sysctl -w kern.ipc.maxsockbuf=8388608

        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxproc=10000
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxprocperuid=10000

        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.sendspace=2097152
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.recvspace=2097152
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.msl=250
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.delayed_ack=0

        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.ip.portrange.first=1024
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.ip.portrange.last=65535
    "

    ulimit -n unlimited
    ulimit -s 65532

    sudo sysctl -w fs.file-max=1048576
    sudo sysctl -w fs.nr_open=1048576

    sudo sysctl -w net.core.somaxconn=4096
    sudo sysctl -w net.core.netdev_max_backlog=16384
    sudo sysctl -w net.core.rmem_max=8388608
    sudo sysctl -w net.core.wmem_max=8388608
    sudo sysctl -w net.core.rmem_default=262144
    sudo sysctl -w net.core.wmem_default=262144

    sudo sysctl -w kernel.pid_max=100000
    sudo sysctl -w kernel.threads-max=100000

    sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 2097152"
    sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 2097152"
    sudo sysctl -w net.ipv4.tcp_fin_timeout=15
    sudo sysctl -w net.ipv4.tcp_tw_reuse=1
    sudo sysctl -w net.ipv4.tcp_syncookies=1

    sudo sysctl -w net.ipv4.ip_local_port_range="1024 65535"

}

prepare_environment