Here is the updated `README.md` file with the commands for each module, including the usage of the `terraform.tfvars` file:

---

# Azure Infrastructure Project for IT Marathon

This project sets up an Azure infrastructure using Terraform, including virtual networks, Linux VMs, MySQL Flexible Server, storage accounts, App Services, and monitoring solutions.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 0.14.x)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- An active Azure subscription
- [Git](https://git-scm.com/downloads)

## Project Structure

```
devops/terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
├── modules/
│   ├── 01_network/
│   ├── 02_security/
│   ├── 03_bastion/
│   ├── 04_database/
│   ├── 05_storage/
│   ├── 07_app_dotnet/
│   ├── 08_email/
│   ├── 09_app_python/
│   ├── 10_monitoring/
│   └── 11_grafana_dashboard/
├── terraform.tfvars
└── README.md
```

## Configuration

1. Clone this repository:
   ```
   git clone <repository-url>
   cd devops/terraform
   ```

2. Create a `terraform.tfvars` file in the `devops/terraform` directory and set the required variables. Use the following template and adjust the values as needed:

   ```hcl
   location                        = "North Europe"
   project_name                    = "itmarathon"
   environment                     = "prod"
   vnet_address_space              = ["10.0.0.0/16"]
   public_subnet_address_prefix    = "10.0.4.0/24"
   private_subnet_address_prefix   = "10.0.5.0/24"
   bastion_subnet_address_prefix   = "10.0.6.0/24"
   monitoring_subnet_address_prefix = "10.0.7.0/24"
   mysql_subnet_address_prefix     = "10.0.3.0/24"
   data_location                   = "Europe"

   allowed_ip_ranges = [
     "X.X.X.X/32",  # Replace with your IP ranges
   ]

   vm_config = {
     size           = "Standard_B1s"
     admin_username = "azureuser"
   }

   admin_ssh_keys = [
     "ssh-rsa AAAAB...",  # Replace with your public SSH key
   ]

   mysql_config = {
     admin_username = "mysqladmin"
     admin_password = "SecurePassword123!"
     sku_name       = "B_Standard_B1s"
     version        = "8.0.21"
   }

   storage_config = {
     account_tier             = "Standard"
     account_replication_type = "LRS"
     container_name           = "itmarathoncontainer"
   }

   grafana_password = "SecureGrafanaPassword123!"
   grafana_user     = "admin"

   azure_subscription_id = "your-subscription-id"
   azure_tenant_id       = "your-tenant-id"
   azure_client_id       = "your-client-id"
   azure_client_secret   = "your-client-secret"

   infinity_client_id     = "your-infinity-client-id"
   infinity_client_secret = "your-infinity-client-secret"

   mysql_retention_days = "7"

   enable_http2 = true

   ssl_certificate_password = "SecureCertPassword123!"
   ```

3. Ensure you have the necessary Azure credentials set up. You can authenticate using the Azure CLI:
   ```
   az login
   ```

## Usage

### Initialize Terraform

Initialize Terraform to download the required providers and set up the backend:

```
terraform init
```

### Plan and Apply the Infrastructure by Modules

To apply changes for specific modules with the `terraform.tfvars` file, follow the commands below:

1. **Network (01_network)**  
   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.network
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.network
   ```

2. **Security (02_security)**  
   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.security
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.security
   ```

3. **Bastion (03_bastion)**  
   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.bastion
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.bastion
   ```

4. **Database (04_database)**  
   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.database
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.database
   ```

5. **Storage (05_storage)**  
   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.storage
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.storage
   ```

6. **App .NET (07_app_dotnet)**  
   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.app_dotnet
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.app_dotnet
   ```

7. **Email (08_email)**  
   Register Communication service:
   ```
   az provider register --namespace Microsoft.Communication
   ```

   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.email
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.email
   ```

8. **App Python (09_app_python)**  
   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.app_python
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.app_python
   ```

9. **Monitoring (10_monitoring)**  
   Plan:
   ```
   terraform plan -var-file=terraform.tfvars -target=module.monitoring
   ```
   Apply:
   ```
   terraform apply -var-file=terraform.tfvars -target=module.monitoring
   ```

10. **Grafana Dashboard (11_grafana_dashboard)**  
    Plan:
    ```
    terraform plan -var-file=terraform.tfvars -target=module.grafana_dashboard
    ```
    Apply:
    ```
    terraform apply -var-file=terraform.tfvars -target=module.grafana_dashboard
    ```

### Apply the Entire Infrastructure

To apply the entire infrastructure, without targeting specific modules:

```
terraform apply -var-file=terraform.tfvars
```

When prompted, type `yes` to confirm the changes.

### Destroy the Infrastructure

To remove all created resources when you're done:

```
terraform destroy -var-file=terraform.tfvars
```

## Accessing Resources

- **Grafana**: Access Grafana using the public IP of the monitoring VM. The URL and credentials will be output after successful deployment.
- **App Services**: URLs for the deployed .NET and Python applications will be provided in the Terraform output.
- **Database**: Connection strings and server information for the MySQL database will be available in the output.

## Security Notes

- Access to resources is restricted to specified IP ranges in the `allowed_ip_ranges` variable.
- Sensitive information (passwords, keys) should be managed securely. Consider using Azure Key Vault for production deployments.
- Review and adjust network security group rules as needed for your security requirements.

## Customization

- Modify the `terraform.tfvars` file to adjust resource configurations, sizing, and other parameters.
