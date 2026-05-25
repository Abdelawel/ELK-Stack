#!/bin/bash
# =============================================================
# LINUX PROVISIONER: Node A (XFCE + Nginx + Filebeat)
# =============================================================

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "1. Installing Desktop Environment (Ubuntu GNOME), Nginx, and Socat..."
sudo apt-get update
# Pre-configure gdm3 to avoid interactive GUI popups that freeze the build
echo "gdm3 shared/default-x-display-manager select gdm3" | sudo debconf-set-selections
sudo apt-get install -y ubuntu-desktop nginx socat curl

echo "2. Configuring Auto-Login for 'vagrant' user on GDM3..."
sudo sed -i 's/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/g' /etc/gdm3/custom.conf
sudo sed -i 's/#  AutomaticLogin = user1/AutomaticLogin = vagrant/g' /etc/gdm3/custom.conf

echo "3. Installing Filebeat..."
wget -qO filebeat.deb https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.13.0-amd64.deb
sudo dpkg -i filebeat.deb

echo "4. Linking logs for teammate's Custom Filebeat Configuration..."
# Create the specific directory path requested by teammate's filebeat.yml
sudo mkdir -p /chemin/vers/
# Build file if missing and redirect Nginx auth logs
sudo touch /var/log/nginx/access.log
sudo ln -sf /var/log/nginx/access.log /chemin/vers/sample_nginx.log
sudo chmod 755 /var/log/nginx
sudo chmod 644 /var/log/nginx/access.log

echo "5. Applying teammate's filebeat.yml directly (Unmodified)..."
sudo cp /vagrant/linux-vm/filebeat.yml /etc/filebeat/filebeat.yml
sudo chown root:root /etc/filebeat/filebeat.yml
sudo chmod go-w /etc/filebeat/filebeat.yml

echo "6. Implementing TCP Port Forwarding Hack..."
# Teammate's filebeat config tries to output to localhost:9200.
# We will use socat to transparently intercept localhost:9200 and forward it over the vagrant network to the Hub node (192.168.56.10:9200) where Elasticsearch lives.
cat << 'INNER_EOF' | sudo tee /etc/systemd/system/socat-es.service
[Unit]
Description=Socat Forwarder for Elasticsearch
After=network.target

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:9200,fork TCP:192.168.56.10:9200
Restart=always

[Install]
WantedBy=multi-user.target
INNER_EOF

sudo systemctl daemon-reload
sudo systemctl enable socat-es
sudo systemctl start socat-es

echo "7. Starting Networking and Pipelines..."
sudo systemctl enable filebeat
sudo systemctl start filebeat
sudo systemctl restart nginx

echo "Linux Node A provisioned successfully!"
