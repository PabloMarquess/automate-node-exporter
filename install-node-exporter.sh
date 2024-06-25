#!/bin/bash

# Determina a arquitetura do sistema
architecture=$(uname -m)

# Define a URL base para o download
base_url="https://github.com/prometheus/node_exporter/releases/download/v1.8.1"

# Escolhe o arquivo correto baseado na arquitetura
case $architecture in
  x86_64)
    file="node_exporter-1.8.1.linux-amd64.tar.gz"
    ;;
  aarch64)
    file="node_exporter-1.8.1.linux-arm64.tar.gz"
    ;;
  *)
    echo "Arquitetura não suportada: $architecture"
    exit 1
    ;;
esac

# Download do Node Exporter
cd /tmp
wget "${base_url}/${file}"

# Descompacta o arquivo
tar -xzf "${file}"

# Move o binário para o local adequado
sudo mv "node_exporter-1.8.1.linux-${architecture}/node_exporter" /usr/local/bin

# Cria o usuário node_exporter
sudo useradd node_exporter --no-create-home --shell /bin/false

# Ajusta as permissões
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Cria o serviço systemd
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
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
EOF

# Recarrega o systemd, habilita e inicia o serviço
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
