#!/bin/bash

echo "Ensure you have updated all nessacary fields (passwords) and ran create_user_update.sh... checking..."
sleep 5

apt install openjdk-11-jdk -y
echo "OpenJDK 11 has been installed"

apt install maven -y
echo "Maven has been installed"

apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

mkdir certs docker haproxy tomcat

# Directory where the docker-compose.yml file will be created
DIRECTORY="/home/racing/docker/"

# Check if the directory exists; if not, create it
if [ ! -d "$DIRECTORY" ]; then
  mkdir -p "$DIRECTORY"
fi

# Path to the docker-compose.yml file
FILE="$DIRECTORY/docker-compose.yml"

# Write the content to the docker-compose.yml file
cat <<EOL > $FILE
version: '3.8'

services:
  influxdb:
    image: influxdb:2.0
    container_name: influxdb
    ports:
      - "8086:8086"
    volumes:
      - influxdb-storage:/var/lib/influxdb2
    depends_on:
      - grafana
      - haproxy
    networks:
      - monitoring-net
    environment:
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_PASSWORD=CHANGEME!

  tomcat:
    image: tomcat:9
    container_name: tomcat
    ports:
      - "8080:8080"
    volumes:
      - /home/racing/tomcat/:/usr/local/tomcat/webapps/
    networks:
      - monitoring-net

  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana
    depends_on:
      - haproxy
    networks:
      - monitoring-net
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=CHANGEME!

  haproxy:
    image: haproxy:latest
    container_name: haproxy
    ports:
      - "443:443"
    volumes:
      - /home/racing/certs/:/certs/
      - /home/racing/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
    networks:
      - monitoring-net

networks:
  monitoring-net:
    driver: bridge

volumes:
  influxdb-storage:
    driver: local
  grafana-storage:
    driver: local
  sftp-storage:
    driver: local
EOL

echo "docker-compose.yml has been created in $DIRECTORY"

# Directory where the docker-compose.yml file will be created
DIRECTORY2="/home/racing/haproxy/"

# Check if the directory exists; if not, create it
if [ ! -d "$DIRECTORY2" ]; then
  mkdir -p "$DIRECTORY2"
fi

# Path to the docker-compose.yml file
FILE="$DIRECTORY2/haproxy.cfg"

# Write the content to the docker-compose.yml file
cat <<EOL > $FILE

frontend http_front
  mode http
  bind *:443 ssl crt /certs/racing.pem
  default_backend http_back
  timeout client 30s

backend http_back
  mode http
  balance roundrobin
  server tomcat1 tomcat:8080 check
  timeout connect 30s
  timeout server 30s

EOL

echo "haproxy.cfg has been created in $DIRECTORY2"
sleep 3
echo "Now cd to /home/racing/docker and run sudo docker compose up -d"
sleep 3
echo "Log into Influxdb server and name your org ..... Racing"
sleep 3
echo "Now go to data -> buckets tab -> create new bucket and call it... track-data"
sleep 3
echo "Now go to data -> tokens tab -> generate new token and give it"
sleep 3
echo "Now copy the API folder and update InfluxdbDataInject.java file with Bearer Token field and Influxdb Token field"
sleep 3
echo "Once build is completed, run cp /home/racing/api/target/api.war /home/racing/tomcat/api.war"
sleep 3
echo "Once complete, run the command sudo docker restart tomcat and test data ingestion from Torque Pro"
