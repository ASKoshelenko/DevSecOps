module "network" {
  source                           = "./modules/01_network"
  project_name                     = var.project_name
  environment                      = var.environment
  location                         = var.location
  vnet_address_space               = var.vnet_address_space
  public_subnet_address_prefix     = var.public_subnet_address_prefix
  private_subnet_address_prefix    = var.private_subnet_address_prefix
  bastion_subnet_address_prefix    = var.bastion_subnet_address_prefix
  monitoring_subnet_address_prefix = var.monitoring_subnet_address_prefix
  mysql_subnet_address_prefix      = var.mysql_subnet_address_prefix
  create_public_ips                = var.create_public_ips
}

module "security" {
  source                        = "./modules/02_security"
  resource_group_name           = module.network.resource_group_name
  location                      = var.location
  project_name                  = var.project_name
  environment                   = var.environment
  public_subnet_id              = module.network.public_subnet_id
  private_subnet_id             = module.network.private_subnet_id
  bastion_subnet_id             = module.network.bastion_subnet_id
  monitoring_subnet_id          = module.network.monitoring_subnet_id
  mysql_subnet_id               = module.network.mysql_subnet_id
  allowed_ip_ranges             = var.allowed_ip_ranges
  public_subnet_address_prefix  = var.public_subnet_address_prefix
  private_subnet_address_prefix = var.private_subnet_address_prefix
}

module "bastion" {
  source                 = "./modules/03_bastion"
  resource_group_name    = module.network.resource_group_name
  location               = var.location
  subnet_id              = module.network.bastion_subnet_id
  project_name           = var.project_name
  environment            = var.environment
  admin_username         = var.vm_config.admin_username
  vm_size                = var.vm_config.size
  public_ip_id           = module.network.public_ip_ids["bastion"]
  admin_ssh_keys         = var.admin_ssh_keys
  os_disk_config         = var.vm_os_disk_config
  source_image_reference = var.vm_source_image_reference
}

module "database" {
  source                        = "./modules/04_database"
  resource_group_name           = module.network.resource_group_name
  location                      = var.location
  project_name                  = var.project_name
  environment                   = var.environment
  mysql_admin_username          = var.mysql_config.admin_username
  mysql_admin_password          = var.mysql_config.admin_password
  mysql_sku_name                = var.mysql_config.sku_name
  mysql_version                 = var.mysql_config.version
  mysql_subnet_id               = module.network.mysql_subnet_id
  private_dns_zone_id           = module.network.private_dns_zone_id
  private_dns_zone_vnet_link_id = module.network.private_dns_zone_vnet_link_id
  mysql_retention_days          = var.mysql_retention_days
}

module "storage" {
  source              = "./modules/05_storage"
  resource_group_name = module.network.resource_group_name
  location            = var.location
  project_name        = var.project_name
  environment         = var.environment
  storage_config      = var.storage_config
  allowed_ip_ranges   = var.allowed_ip_ranges

  depends_on = [module.network]
}

module "monitoring" {
  source                 = "./modules/10_monitoring"
  resource_group_name    = module.network.resource_group_name
  location               = var.location
  subnet_id              = module.network.monitoring_subnet_id
  project_name           = var.project_name
  environment            = var.environment
  admin_username         = var.vm_config.admin_username
  admin_ssh_keys         = var.admin_ssh_keys
  os_disk_config         = var.vm_os_disk_config
  vm_size                = var.vm_config.size
  public_ip_id           = module.network.public_ip_ids["monitoring"]
  source_image_reference = var.vm_source_image_reference
  grafana_password       = var.grafana_password
  azure_subscription_id  = var.azure_subscription_id
  azure_tenant_id        = var.azure_tenant_id # entra_tenant_id
  azure_client_id        = var.azure_client_id # Azure Monitor Datasource
  azure_client_secret    = var.azure_client_secret # Azure Monitor Datasource
  
  depends_on = [module.network, module.security]
}


locals {
  grafana_public_ip = module.network.public_ip_addresses["monitoring"]
}

module "grafana_dashboards" {
  source                 = "./modules/11_grafana_dashboard"
  grafana_public_ip      = module.network.public_ip_addresses["monitoring"]
  grafana_user           = var.grafana_user
  grafana_password       = var.grafana_password
  infinity_client_secret = var.infinity_client_secret
  infinity_client_id     = var.infinity_client_id
  azure_tenant_id        = var.azure_tenant_id
  
  resource_group_name    = module.network.resource_group_name
  azure_subscription_id  = var.azure_subscription_id

  
  providers = {
    grafana = grafana.configured
  }
}

module "app_dotnet" {
  source                            = "./modules/07_app_dotnet"
  resource_group_name               = module.network.resource_group_name
  location                          = var.location
  project_name                      = var.project_name
  environment                       = var.environment
  
  public_subnet_id                  = module.network.public_subnet_id
  private_subnet_id                 = module.network.private_subnet_id
  enable_http2                      = var.enable_http2
  allowed_ip_ranges                 = var.allowed_ip_ranges
  public_subnet_address_prefix      = var.public_subnet_address_prefix
  private_subnet_address_prefix     = var.private_subnet_address_prefix
  storage_account_connection_string = module.storage.primary_connection_string
  mysql_admin_password              = var.mysql_config.admin_password
  mysql_admin_username              = var.mysql_config.admin_username
}

module "email" {
  source                            = "./modules/08_email"
  resource_group_name               = module.network.resource_group_name
  project_name                      = var.project_name
  location                          = var.location
  environment                       = var.environment
  data_location                     = var.data_location
}

module "app_python" {
  source                            = "./modules/09_app_python" # Adjust the path as needed
  resource_group_name               = module.network.resource_group_name
  location                          = var.location
  project_name                      = var.project_name
  environment                       = var.environment

  public_subnet_id                  = module.network.public_subnet_id
  private_subnet_id                 = module.network.private_subnet_id
  enable_http2                      = var.enable_http2
  allowed_ip_ranges                 = var.allowed_ip_ranges
  public_subnet_address_prefix      = var.public_subnet_address_prefix
  private_subnet_address_prefix     = var.private_subnet_address_prefix
  storage_account_connection_string = module.storage.primary_connection_string

  mysql_server_name                 = module.database.mysql_server_name
  mysql_admin_password              = var.mysql_config.admin_password
  mysql_admin_username              = var.mysql_config.admin_username

  smtp_server                       = module.email.smtp_server
  smtp_port                         = module.email.smtp_port
  smtp_username                     = module.email.smtp_username
  smtp_password                     = module.email.smtp_password
  email_connection_string           = module.email.communication_service_primary_connection_string
}
