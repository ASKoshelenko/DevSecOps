resource "azurerm_service_plan" "app_plan" {
  name                = "plan-dotnet-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_windows_web_app" "marathon_dotnet_app" {
  name                       = "dotnet-v4${var.project_name}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.app_plan.id
  https_only                 = true
  public_network_access_enabled = true

  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled = false

  lifecycle {
    ignore_changes = [ site_config["virtual_application"], sticky_settings ]
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = false

    http_logs {
      file_system {
        retention_in_days = 3
        retention_in_mb   = 35
      }
    }
  }

  site_config {
    cors {
      allowed_origins     = [
        "*",
      ]
      support_credentials = false
    }

    application_stack {
      dotnet_version = "v8.0"
    }
    always_on               = false
    worker_count            = 1
    vnet_route_all_enabled  = true

    ftps_state = "FtpsOnly"
    ip_restriction_default_action = "Deny"
    
    dynamic "ip_restriction" {
      for_each = var.allowed_ip_ranges
      content {
        ip_address  = ip_restriction.value
        action = "Allow"
        priority = 100
      }
    }
    ip_restriction {
      action = "Allow"
      name = "AzureDevOps"
      priority = 160
      service_tag = "AzureDevOps"
    }
  }

  app_settings = {
    "AzureBlobStorageConfig__ConnectionString" = var.storage_account_connection_string
    "ConnectionStrings__DefaultConnection" = format("Server=marathon-itmarathon-prod.mysql.database.azure.com;UserID=%s;Password=%s;Database=%s;", var.mysql_admin_username, var.mysql_admin_password,"${var.project_name}-${var.environment}")
    "ASPNETCORE_ENVIRONMENT" = "Development"
    "DiagnosticServices_EXTENSION_VERSION" = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"  = "~1"
    "SnapshotDebugger_EXTENSION_VERSION"       = "~2"
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"          = "true"
    "WEBSITE_RUN_FROM_PACKAGE"                 = "1"
  }

  virtual_network_subnet_id = var.public_subnet_id
}