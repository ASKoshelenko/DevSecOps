module "network" {
  source                   = "./modules/01_network"
  project_name             = var.project_name
  environment              = var.environment
  location                 = var.location
  vnet_address_space       = var.vnet_address_space
  jenkins_subnet_prefix    = var.jenkins_subnet_prefix
  monitoring_subnet_prefix = var.monitoring_subnet_prefix
  create_public_ips        = var.create_public_ips
}

module "security" {
  source                   = "./modules/02_security"
  resource_group_name      = module.network.resource_group_name
  location                 = var.location
  project_name             = var.project_name
  environment              = var.environment
  jenkins_subnet_id        = module.network.jenkins_subnet_id
  monitoring_subnet_id     = module.network.monitoring_subnet_id
  allowed_ip_ranges        = var.allowed_ip_ranges
  jenkins_subnet_prefix    = var.jenkins_subnet_prefix
  monitoring_subnet_prefix = var.monitoring_subnet_prefix
}

module "storage" {
  source              = "./modules/05_storage"
  resource_group_name = module.network.resource_group_name
  location            = var.location
  project_name        = var.project_name
  environment         = var.environment
  storage_config      = var.storage_config
  allowed_ip_ranges   = var.allowed_ip_ranges
}

module "jenkins" {
  source                 = "./modules/03_jenkins"
  resource_group_name    = module.network.resource_group_name
  location               = var.location
  subnet_id              = module.network.jenkins_subnet_id
  project_name           = var.project_name
  environment            = var.environment
  admin_username         = var.vm_config.admin_username
  admin_password         = var.admin_password
  vm_size                = var.vm_config.size
  public_ip_id           = module.network.public_ip_ids["jenkins"]
  admin_ssh_keys         = var.admin_ssh_keys
  os_disk_config         = var.vm_os_disk_config
  source_image_reference = var.vm_source_image_reference
  tmdb_api_key           = var.tmdb_api_key
  docker_username        = var.docker_username
  docker_password        = var.docker_password
}

module "monitoring" {
  source                 = "./modules/04_monitoring"
  resource_group_name    = module.network.resource_group_name
  location               = var.location
  subnet_id              = module.network.monitoring_subnet_id
  project_name           = var.project_name
  environment            = var.environment
  admin_username         = var.vm_config.admin_username
  admin_password         = var.admin_password
  admin_ssh_keys         = var.admin_ssh_keys
  os_disk_config         = var.vm_os_disk_config
  vm_size                = var.vm_config.size
  public_ip_id           = module.network.public_ip_ids["monitoring"]
  source_image_reference = var.vm_source_image_reference
  grafana_password       = var.grafana_password
  azure_subscription_id  = var.azure_subscription_id
  azure_tenant_id        = var.azure_tenant_id
  azure_client_id        = var.azure_client_id
  azure_client_secret    = var.azure_client_secret
  jenkins_ip             = module.network.public_ip_addresses["jenkins"]
}