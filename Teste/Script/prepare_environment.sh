
LOG_PATH="Documents/tcc/Teste/Script/LoadConstant/Results/logs"

prepare_environment(){
    echo "=== Preparando ambiente no servidor (macOS Apple Silicon) ==="

    SENHA_SUDO="120504"

    $SSH "
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxfiles=1048576
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxfilesperproc=1048576
        echo '$SENHA_SUDO' | sudo sysctl -w kern.ipc.somaxconn=4096
        echo '$SENHA_SUDO' | sudo sysctl -w kern.ipc.maxsockbuf=8388608

        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxproc=2000
        echo '$SENHA_SUDO' | sudo -S sysctl -w kern.maxprocperuid=2000

        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.sendspace=2097152
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.recvspace=2097152
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.msl=250
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.tcp.delayed_ack=0

        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.ip.portrange.first=1024
        echo '$SENHA_SUDO' | sudo -S sysctl -w net.inet.ip.portrange.last=65535
    "

    echo "=== Preparando ambiente no cliente (linux) ==="

    sudo -S sysctl -w fs.file-max=1048576
    sudo -S sysctl -w net.core.somaxconn=4096
    sudo -S sysctl -w net.core.rmem_max=8388608
    sudo -S sysctl -w net.core.wmem_max=8388608
    sudo -S sysctl -w kernel.pid_max=200000
    sudo -S sysctl -w net.ipv4.tcp_rmem="4096 87380 2097152"
    sudo -S sysctl -w net.ipv4.tcp_wmem="4096 65536 2097152"
    sudo -S sysctl -w net.ipv4.tcp_fin_timeout=15
    sudo -S sysctl -w net.ipv4.tcp_tw_reuse=1
    sudo -S sysctl -w net.ipv4.ip_local_port_range="1024 65535"

}
prepare_environment