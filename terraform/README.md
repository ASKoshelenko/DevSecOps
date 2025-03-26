# DevSecOps проект на Azure с использованием Terraform

Этот проект создает инфраструктуру DevSecOps в Azure с использованием Terraform. Проект включает в себя Jenkins, SonarQube, Grafana, Prometheus и другие инструменты DevSecOps для развертывания и мониторинга приложения Netflix Clone.

## Архитектура

Проект развертывает следующие компоненты:

- **Сеть**: Виртуальная сеть Azure с подсетями для Jenkins и мониторинга
- **Виртуальные машины**:
  - Jenkins VM с предустановленными Docker, SonarQube и Netflix Clone
  - Monitoring VM с предустановленными Prometheus и Grafana
- **Хранилище**: Azure Storage Account для хранения артефактов
- **Контейнеры**: Azure Container Registry для хранения Docker образов

## Требования

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.0.0)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Подписка Azure с достаточными правами
- SSH ключи для доступа к виртуальным машинам

## Начало работы

1. **Клонируйте репозиторий**:
   ```
   git clone <url-репозитория>
   cd terraform-azure-devsecops
   ```

2. **Настройте переменные**:
   Отредактируйте файл `terraform.tfvars` согласно вашим требованиям или создайте новый файл с вашими параметрами.

3. **Инициализируйте Terraform**:
   ```
   terraform init
   ```

4. **Проверьте план развертывания**:
   ```
   terraform plan
   ```

5. **Выполните развертывание**:
   ```
   terraform apply
   ```

6. **Получите выходные данные для доступа к ресурсам**:
   ```
   terraform output
   ```

## Доступ к ресурсам после развертывания

После успешного развертывания вы получите доступ к следующим компонентам:

- **Jenkins**: http://<jenkins_vm_public_ip>:8080/
  - Начальный пароль администратора можно получить через SSH или из вывода Terraform
  
- **SonarQube**: http://<jenkins_vm_public_ip>:9000/
  - Логин: admin, пароль: admin (рекомендуется изменить после первого входа)
  
- **Netflix Clone**: http://<jenkins_vm_public_ip>:8081/
  
- **Grafana**: http://<monitoring_vm_public_ip>:3000/
  - Логин: admin, пароль: определен в terraform.tfvars
  
- **Prometheus**: http://<monitoring_vm_public_ip>:9090/

## Настройка CI/CD Pipeline

1. **Настройка Jenkins**:
   - Установите необходимые плагины: Jenkins Pipeline, SonarQube Scanner, Docker Pipeline
   - Настройте учетные данные для доступа к Azure Container Registry
   - Создайте pipeline используя файл Jenkinsfile из репозитория проекта

2. **Настройка SonarQube**:
   - Создайте новый токен доступа в SonarQube
   - Добавьте токен в Jenkins для интеграции с SonarQube

3. **Настройка Grafana**:
   - Добавьте дополнительные дашборды для мониторинга Jenkins и приложения

## Безопасность

Проект включает в себя следующие компоненты безопасности:

- Анализ кода с помощью SonarQube
- Сканирование уязвимостей с помощью Trivy
- Ограничение доступа к ресурсам через Network Security Groups
- OWASP Dependency Check для проверки зависимостей

## Модули

Проект состоит из следующих модулей Terraform:

- **01_network**: Создание виртуальной сети и подсетей
- **02_security**: Настройка Network Security Groups и правил доступа
- **03_jenkins**: Развертывание виртуальной машины для Jenkins и SonarQube
- **04_monitoring**: Развертывание виртуальной машины для Grafana и Prometheus
- **05_storage**: Создание Azure Storage Account
- **06_container_registry**: Создание Azure Container Registry

## Удаление ресурсов

Для удаления всех созданных ресурсов выполните:

```
terraform destroy
```

## Лицензия

[MIT](LICENSE)