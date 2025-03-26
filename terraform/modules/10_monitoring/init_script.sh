#!/bin/bash
set -e

wait_for_apt() {
  while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
    echo "Waiting for other apt-get instances to finish..."
    sleep 1
  done
}

wait_for_nginx() {
  max_retries=30
  counter=0

  while [ $counter -lt $max_retries ]; do
    if curl -s http://localhost | grep -q "Welcome to nginx"; then
      echo "Nginx is up and running!"
      return 0
    fi
    echo "Waiting for Nginx to be ready..."
    sleep 2
    counter=$((counter+1))
  done

  echo "Nginx did not become ready in time."
  return 1
}

wait_for_grafana() {
  max_retries=30
  counter=0

  while [ $counter -lt $max_retries ]; do
    if curl -s http://localhost:3000/api/health | grep -q "ok"; then
      echo "Grafana is up and running!"
      return 0
    fi
    echo "Waiting for Grafana to be ready..."
    sleep 2
    counter=$((counter+1))
  done

  echo "Grafana did not become ready in time."
  return 1
}

# Install necessary packages
wait_for_apt
sudo apt-get update
wait_for_apt
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
wait_for_apt
sudo apt-get update
export PATH=$PATH:/usr/sbin
wait_for_apt
sudo apt-get install -y grafana nginx certbot python3-certbot-nginx lsof jq


# Install Azure Monitor plugin
sudo grafana-cli plugins install grafana-azure-monitor-datasource
sudo grafana-cli plugins install yesoreyeram-infinity-datasource

sudo chmod -R 755 /var/lib/grafana
sudo chown -R grafana:grafana /var/lib/grafana

# Add the feature toggle if the section exists for correct working yesoreyeram-infinity-datasource
sudo sed -i '/^\[feature_toggles\]/a transformationsVariableSupport = true' /etc/grafana/grafana.ini

# Set for admin custom password in to grafana.ini 
sed -i "/^;admin_password/s/^;//; s/^admin_password = admin/admin_password = $(echo ${grafana_password} | sed -e 's/[\/&]/\\&/g')/" /etc/grafana/grafana.ini

# Generate self-signed SSL certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Configure Nginx
sudo tee /etc/nginx/sites-available/grafana << EOF
server {
    listen 80;
    server_name _;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name _;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

if [ ! -L /etc/nginx/sites-enabled/grafana ]; then
sudo ln -s /etc/nginx/sites-available/grafana /etc/nginx/sites-enabled/
fi

# Check if the default site configuration exists before attempting to remove it
if [ -e /etc/nginx/sites-enabled/default ]; then
sudo rm /etc/nginx/sites-enabled/default
fi


# Configure Azure Monitor data source
sudo tee /etc/grafana/provisioning/datasources/azure-monitor.yaml << EOF
apiVersion: 1

datasources:
  - name: Azure Monitor
    type: grafana-azure-monitor-datasource
    access: proxy
    jsonData:
      cloudName: azuremonitor
      tenantId: ${azure_tenant_id}
      clientId: ${azure_client_id}
      subscriptionId: ${azure_subscription_id}
    secureJsonData:
      clientSecret: ${azure_client_secret}

EOF

# Enable and start services

sudo systemctl enable grafana-server
sudo systemctl start grafana-server
wait_for_grafana

sudo chmod -R 755 /var/lib/grafana
sudo chmod 640 /var/lib/grafana/grafana.db
sudo chown -R grafana:grafana /var/lib/grafana

sudo systemctl restart grafana-server
wait_for_grafana

sudo systemctl restart nginx
wait_for_nginx

