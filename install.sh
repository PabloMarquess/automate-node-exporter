#!/bin/bash

# Verifica arquitetura;
ARCH=$(uname -m)

# Determina o Link apropriado;
if [ "$ARCH" == "x86_64" ]; then
    NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v1.9.0/node_exporter-1.9.0.linux-amd64.tar.gz"
    NODE_EXPORTER_DIR="node_exporter-1.9.0.linux-amd64"
elif [ "$ARCH" == "aarch64" ]; then
    NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v1.9.0/node_exporter-1.9.0.linux-arm64.tar.gz"
    NODE_EXPORTER_DIR="node_exporter-1.9.0.linux-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Baixa e extrai o node-exporter
cd /tmp
wget $NODE_EXPORTER_URL -O node_exporter.tar.gz
tar -xvf node_exporter.tar.gz
cd $NODE_EXPORTER_DIR

# Move o binario do node-exporter  para /usr/local/bin
sudo mv node_exporter /usr/local/bin/

# Cria o node-exporter user
sudo useradd node_exporter --no-create-home --shell /bin/false

# Seta as permissão para o binario do node-exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Cria o arquivo de service do systemd
sudo bash -c 'cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF'

# Racarregando systemd, enable e start do node-exporter service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
