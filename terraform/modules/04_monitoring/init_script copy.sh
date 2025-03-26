#!/bin/bash

# Обновление пакетов
apt-get update
apt-get upgrade -y

# Установка основных утилит
apt-get install -y apt-transport-https ca-certificates curl software-properties-common git wget gnupg2 lsb-release

# Настройка timezone
timedatectl set-timezone UTC

# Создание пользователя для Prometheus
useradd --system --no-create-home --shell /bin/false prometheus

# Установка Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.47.1/prometheus-2.47.1.linux-amd64.tar.gz
tar -xvf prometheus-2.47.1.linux-amd64.tar.gz
cd prometheus-2.47.1.linux-amd64/
mkdir -p /data /etc/prometheus
mv prometheus promtool /usr/local/bin/
mv consoles/ console_libraries/ /etc/prometheus/
mv prometheus.yml /etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /etc/prometheus/ /data/

# Создание конфигурации для systemd
cat > /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/data \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries \\
  --web.listen-address=0.0.0.0:9090 \\
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Обновление конфигурации Prometheus для мониторинга Jenkins
cat > /etc/prometheus/prometheus.yml << EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['${jenkins_ip}:8080']

  - job_name: 'netflix'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['${jenkins_ip}:8081']
EOF

# Установка Node Exporter
useradd --system --no-create-home --shell /bin/false node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz
mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter*

# Создание конфигурации для systemd (Node Exporter)
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter --collector.logind

[Install]
WantedBy=multi-user.target
EOF

# Установка Grafana
apt-get install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get -y install grafana

# Директория для provisioning в Grafana
mkdir -p /etc/grafana/provisioning/datasources
mkdir -p /etc/grafana/provisioning/dashboards

# Настройка источников данных в Grafana
cat > /etc/grafana/provisioning/datasources/prometheus.yaml << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
EOF

# Создание директории для dashboards
mkdir -p /var/lib/grafana/dashboards

# Настройка dashboards
cat > /etc/grafana/provisioning/dashboards/dashboards.yaml << EOF
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /var/lib/grafana/dashboards
EOF

# Создание базового дашборда для мониторинга хостов
cat > /var/lib/grafana/dashboards/node-exporter.json << 'EOF'
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "panels": [
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 2,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[1m])) * 100)",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "CPU Usage",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "percent",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    }
  ],
  "refresh": "5s",
  "schemaVersion": 22,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ]
  },
  "timezone": "",
  "title": "Node Exporter Dashboard",
  "uid": "rYdddlPWk",
  "version": 1
}
EOF

# Запуск служб
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl enable node_exporter
systemctl start node_exporter
systemctl enable grafana-server
systemctl start grafana-server

# Изменение пароля администратора Grafana
grafana-cli admin reset-admin-password ${grafana_password}

# Создание README с инструкциями
cat > /home/${admin_username}/README.md << 'EOF'
# DevSecOps на Azure - Мониторинг

## Доступ к сервисам

- Prometheus: http://localhost:9090/
- Grafana: http://localhost:3000/ (admin/${grafana_password})
- Node Exporter: http://localhost:9100/metrics

## Конфигурация

Prometheus настроен на сбор метрик с:
- Node Exporter (локально)
- Jenkins (удаленно)
- Netflix App (удаленно)

## Grafana

Grafana настроена и содержит базовые дашборды для мониторинга системы.
Вы можете импортировать дополнительные дашборды из каталога Grafana.

## Советы

Для импорта дашбордов из библиотеки Grafana:
1. Перейдите в меню "+" и выберите "Import"
2. Введите ID дашборда (например, 1860 для Node Exporter или 9964 для Jenkins)
3. Выберите источник данных Prometheus
4. Нажмите "Import"
EOF

# Назначение прав
chown ${admin_username}:${admin_username} /home/${admin_username}/README.md

# Создание SSH ключа для доступа к Jenkins (опционально)
mkdir -p /home/${admin_username}/.ssh
ssh-keygen -t rsa -N "" -f /home/${admin_username}/.ssh/id_rsa_jenkins
chown -R ${admin_username}:${admin_username} /home/${admin_username}/.ssh
chmod 700 /home/${admin_username}/.ssh
chmod 600 /home/${admin_username}/.ssh/id_rsa_jenkins

echo "Настройка завершена!"

# #!/bin/bash
# set -e

# wait_for_apt() {
#   while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
#     echo "Waiting for other apt-get instances to finish..."
#     sleep 1
#   done
# }

# wait_for_nginx() {
#   max_retries=30
#   counter=0

#   while [ $counter -lt $max_retries ]; do
#     if curl -s http://localhost | grep -q "Welcome to nginx"; then
#       echo "Nginx is up and running!"
#       return 0
#     fi
#     echo "Waiting for Nginx to be ready..."
#     sleep 2
#     counter=$((counter+1))
#   done

#   echo "Nginx did not become ready in time."
#   return 1
# }

# wait_for_grafana() {
#   max_retries=30
#   counter=0

#   while [ $counter -lt $max_retries ]; do
#     if curl -s http://localhost:3000/api/health | grep -q "ok"; then
#       echo "Grafana is up and running!"
#       return 0
#     fi
#     echo "Waiting for Grafana to be ready..."
#     sleep 2
#     counter=$((counter+1))
#   done

#   echo "Grafana did not become ready in time."
#   return 1
# }

# # Install necessary packages
# wait_for_apt
# sudo apt-get update
# wait_for_apt
# sudo apt-get install -y apt-transport-https software-properties-common wget
# sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
# echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
# wait_for_apt
# sudo apt-get update
# export PATH=$PATH:/usr/sbin
# wait_for_apt
# sudo apt-get install -y grafana nginx certbot python3-certbot-nginx lsof jq


# # Install Azure Monitor plugin
# sudo grafana-cli plugins install grafana-azure-monitor-datasource
# sudo grafana-cli plugins install yesoreyeram-infinity-datasource

# sudo chmod -R 755 /var/lib/grafana
# sudo chown -R grafana:grafana /var/lib/grafana

# # Add the feature toggle if the section exists for correct working yesoreyeram-infinity-datasource
# sudo sed -i '/^\[feature_toggles\]/a transformationsVariableSupport = true' /etc/grafana/grafana.ini

# # Set for admin custom password in to grafana.ini 
# sed -i "/^;admin_password/s/^;//; s/^admin_password = admin/admin_password = $(echo ${grafana_password} | sed -e 's/[\/&]/\\&/g')/" /etc/grafana/grafana.ini

# # Generate self-signed SSL certificate
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#   -keyout /etc/ssl/private/nginx-selfsigned.key \
#   -out /etc/ssl/certs/nginx-selfsigned.crt \
#   -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# # Configure Nginx
# sudo tee /etc/nginx/sites-available/grafana << EOF
# server {
#     listen 80;
#     server_name _;
#     return 301 https://\$host\$request_uri;
# }

# server {
#     listen 443 ssl;
#     server_name _;

#     ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
#     ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

#     ssl_protocols TLSv1.2 TLSv1.3;
#     ssl_prefer_server_ciphers on;
#     ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;

#     location / {
#         proxy_pass http://localhost:3000;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }
# }
# EOF

# if [ ! -L /etc/nginx/sites-enabled/grafana ]; then
# sudo ln -s /etc/nginx/sites-available/grafana /etc/nginx/sites-enabled/
# fi

# # Check if the default site configuration exists before attempting to remove it
# if [ -e /etc/nginx/sites-enabled/default ]; then
# sudo rm /etc/nginx/sites-enabled/default
# fi


# # Configure Azure Monitor data source
# sudo tee /etc/grafana/provisioning/datasources/azure-monitor.yaml << EOF
# apiVersion: 1

# datasources:
#   - name: Azure Monitor
#     type: grafana-azure-monitor-datasource
#     access: proxy
#     jsonData:
#       cloudName: azuremonitor
#       tenantId: ${azure_tenant_id}
#       clientId: ${azure_client_id}
#       subscriptionId: ${azure_subscription_id}
#     secureJsonData:
#       clientSecret: ${azure_client_secret}

# EOF

# # Enable and start services

# sudo systemctl enable grafana-server
# sudo systemctl start grafana-server
# wait_for_grafana

# sudo chmod -R 755 /var/lib/grafana
# sudo chmod 640 /var/lib/grafana/grafana.db
# sudo chown -R grafana:grafana /var/lib/grafana

# sudo systemctl restart grafana-server
# wait_for_grafana

# sudo systemctl restart nginx
# wait_for_nginx

