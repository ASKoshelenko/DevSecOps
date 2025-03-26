resource "azurerm_storage_account" "storage" {
  name                     = lower(replace("st${var.project_name}${var.environment}", "-", "")) 
  resource_group_name      = var.resource_group_name
  allow_nested_items_to_be_public = false
  cross_tenant_replication_enabled = false
  location                 = var.location
  account_tier             = var.storage_config.account_tier
  account_replication_type = var.storage_config.account_replication_type

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
  }

  network_rules {
    default_action             = "Allow"
    ip_rules                   = [for cidr in var.allowed_ip_ranges : element(split("/", cidr), 0)]
    virtual_network_subnet_ids = []
    bypass                     = ["AzureServices"]
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_storage_account.storage]
  create_duration = "30s"
}

resource "azurerm_storage_container" "devsecops_container" {
  name                  = var.storage_config.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"

  depends_on = [time_sleep.wait_30_seconds]

  lifecycle {
    create_before_destroy = true
  }
}