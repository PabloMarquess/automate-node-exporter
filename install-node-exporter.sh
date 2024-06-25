#!/bin/bash

# Detect the architecture
ARCH=$(uname -m)

# Determine the appropriate download link
if [ "$ARCH" == "x86_64" ]; then
    NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz"
    NODE_EXPORTER_DIR="node_exporter-1.8.1.linux-amd64"
elif [ "$ARCH" == "aarch64" ]; then
    NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-arm64.tar.gz"
    NODE_EXPORTER_DIR="node_exporter-1.8.1.linux-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Download and extract node exporter
cd /tmp
wget $NODE_EXPORTER_URL -O node_exporter.tar.gz
tar -xvf node_exporter.tar.gz
cd $NODE_EXPORTER_DIR

# Move node_exporter binary to /usr/local/bin
sudo mv node_exporter /usr/local/bin/

# Create node_exporter user
sudo useradd node_exporter --no-create-home --shell /bin/false

# Set ownership of node_exporter binary
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create the systemd service file
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

# Reload systemd, enable and start node_exporter service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
