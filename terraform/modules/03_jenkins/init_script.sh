#!/bin/bash

# Обновление пакетов
apt-get update
apt-get upgrade -y

# Установка основных утилит
apt-get install -y apt-transport-https ca-certificates curl software-properties-common git jq unzip

# Настройка timezone
timedatectl set-timezone UTC

# Установка Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ${admin_username}
systemctl enable docker
systemctl start docker

# Установка Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Установка Java 17
apt-get install -y fontconfig openjdk-17-jre openjdk-17-jdk

# Установка Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io-2023.key | apt-key add -
echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install -y jenkins
usermod -aG docker jenkins
systemctl enable jenkins
systemctl start jenkins

# Ждем запуска Jenkins
sleep 30

# Установка Trivy
apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update
apt-get install -y trivy

# Установка Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Запуск SonarQube как Docker контейнер
mkdir -p /opt/sonarqube/data
mkdir -p /opt/sonarqube/logs
mkdir -p /opt/sonarqube/extensions
chmod -R 777 /opt/sonarqube

docker run -d --name sonar \
  -p 9000:9000 \
  -v /opt/sonarqube/data:/opt/sonarqube/data \
  -v /opt/sonarqube/logs:/opt/sonarqube/logs \
  -v /opt/sonarqube/extensions:/opt/sonarqube/extensions \
  sonarqube:lts-community

# Клонирование проекта Netflix
git clone https://github.com/ASKoshelenko/DevSecOps.git /tmp/netflix
cd /tmp/netflix

# Создаем Dockerfile если его нет
if [ ! -f Dockerfile ]; then
  cat > Dockerfile << 'EOF'
FROM node:16.17.0-alpine as builder
WORKDIR /app
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install
COPY . .
ENV VITE_APP_TMDB_V3_API_KEY="c9cbf23e56e7f8dad215a3a7a3758244"
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN yarn build

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
EOF
fi

# Создаем nginx.conf если его нет
if [ ! -f nginx.conf ]; then
  cat > nginx.conf << 'EOF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF
fi

# Логин в Docker Hub
docker login -u ${docker_username} -p ${docker_password}

# Сборка Docker образа
docker build -t netflix .

# Тегирование и отправка образа в Docker Hub
docker tag netflix ${docker_username}/netflix:latest
docker push ${docker_username}/netflix:latest

# Запуск Netflix контейнера
docker run -d --name netflix -p 8081:80 ${docker_username}/netflix:latest

# Установка Node.js для Jenkins плагинов
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Вывод информации о Jenkins
echo "Jenkins initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword

# Создание Jenkinsfile для pipeline
cat > /tmp/netflix/Jenkinsfile << EOF
pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_CREDS = credentials('docker-creds')
        DOCKER_HUB_REPO = "${docker_username}/netflix"
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/ASKoshelenko/DevSecOps.git'
            }
        }
        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix'''
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Trivy Filesystem Scan') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u \$DOCKER_USERNAME -p \$DOCKER_PASSWORD"
                        sh "docker build -t \$DOCKER_HUB_REPO:latest ."
                        sh "docker push \$DOCKER_HUB_REPO:latest"
                    }
                }
            }
        }
        stage("Trivy Image Scan") {
            steps {
                sh "trivy image \$DOCKER_HUB_REPO:latest > trivyimage.txt"
            }
        }
        stage('Deploy to Container') {
            steps {
                sh 'docker stop netflix || true'
                sh 'docker rm netflix || true'
                sh 'docker run -d --name netflix -p 8081:80 \$DOCKER_HUB_REPO:latest'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'trivyfs.txt,trivyimage.txt', allowEmptyArchive: true
        }
    }
}
EOF

# Создание README с инструкциями
cat > /home/${admin_username}/README.md << 'EOF'
# DevSecOps на Azure - Jenkins

## Доступ к сервисам

- Jenkins: http://localhost:8080/
- SonarQube: http://localhost:9000/ (admin/admin)
- Netflix App: http://localhost:8081/

## Настройка Jenkins

1. Получите начальный пароль администратора:
   ```
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

2. Установите необходимые плагины:
   - Eclipse Temurin Installer
   - SonarQube Scanner
   - NodeJs Plugin
   - OWASP Dependency-Check Plugin
   - Docker Pipeline
   - Docker
   - Email Extension Plugin

3. Настройка Global Tool Configuration:
   - JDK: jdk17 (Eclipse Temurin)
   - NodeJS: node16
   - SonarQube Scanner
   - Dependency-Check

4. Добавьте учетные данные:
   - docker-creds: логин/пароль для Docker Hub
   - Sonar-token: токен для SonarQube

5. Создайте Pipeline для проекта Netflix с использованием предоставленного Jenkinsfile.

## Безопасность

- Trivy установлен для сканирования уязвимостей
- SonarQube настроен для анализа качества кода
- OWASP Dependency-Check для проверки библиотек
EOF

# Назначение прав
chown ${admin_username}:${admin_username} /home/${admin_username}/README.md

echo "Настройка завершена!"