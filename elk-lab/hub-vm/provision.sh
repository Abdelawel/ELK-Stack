#!/bin/bash
# =============================================================
# HUB PROVISIONER: Desktop + Docker + Auto-Login + ELK 
# =============================================================

export DEBIAN_FRONTEND=noninteractive

# 1. Install Lightweight Desktop (XFCE)
echo "Installing Desktop Environment..."
sudo apt-get update
sudo apt-get install -y xfce4 xfce4-goodies lightdm

# 2. CONFIGURE AUTO-LOGIN (No Credentials Mode)
echo "Configuring Auto-Login for 'vagrant' user..."
sudo mkdir -p /etc/lightdm/lightdm.conf.d
cat <<EOF | sudo tee /etc/lightdm/lightdm.conf.d/autologin.conf
[Seat:*]
autologin-user=vagrant
autologin-user-timeout=0
EOF

# 3. Install Docker and Docker Compose
echo "Installing Docker Engine..."
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 4. Start ELK Stack
echo "Starting ELK Stack foundation..."
cd /vagrant/hub-vm
if [ -f "docker-compose.yml" ]; then
    sudo docker compose up -d
fi

echo "Hub is ready! Visit http://192.168.56.10:5601 for Kibana."
echo "Machine will auto-login to XFCE on next boot."
