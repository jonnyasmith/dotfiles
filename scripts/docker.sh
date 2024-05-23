# Add Docker's official GPG key:
sudo nala update
sudo nala install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo nala update

sudo nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER

sudo mkdir /opt/portainer

sudo tee /opt/portainer/docker-compose.yml > /dev/null <<EOF
services:

  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    restart: always
    ports:
      - "9000:9000"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "/opt/portainer/data:/data"
EOF

sudo service docker start
cd /opt/portainer
sudo docker compose up -d
cd
