resource "azurerm_service_plan" "python_plan" {
  name                = "plan-python-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "python_app" {
  name                       = "python-v4-${var.project_name}-${var.environment}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.python_plan.id
  https_only                 = true
  public_network_access_enabled = true  # Consider setting this to false for added security
  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled = false

  lifecycle {
    ignore_changes = [ site_config["app_command_line"], sticky_settings ]
  }

  logs {
    detailed_error_messages = false
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
      python_version        = "3.11"  # Updated to 3.11 as per README
    }
    always_on               = false  # Changed to true for production
    worker_count            = 1
    vnet_route_all_enabled  = true

    ftps_state = "FtpsOnly"
    ip_restriction_default_action = "Deny"
    
    dynamic "ip_restriction" {
      for_each = var.allowed_ip_ranges
      content {
        ip_address  = ip_restriction.value
        action      = "Allow"
        priority    = 100
      }
    }
    ip_restriction {
      action      = "Allow"
      name        = "AzureDevOps"
      priority    = 160
      service_tag = "AzureDevOps"
    }

  }

  app_settings = {
     
    "AzureBlobStorageConfig__ConnectionString" = var.storage_account_connection_string
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "PYTHON_ENABLE_GUNICORN_MULTIWORKERS" = "true"
    
      # Database connection settings
    
    "MYSQL_SERVER_NAME" = var.mysql_server_name
    "MYSQL_DATABASE_NAME" = "marathon-db-${var.project_name}-${var.environment}"
    "MYSQL_USERNAME" = var.mysql_admin_username
    "MYSQL_PASSWORD" = var.mysql_admin_password

    # Construct the database URL for your Python app
    
    "ConnectionStrings__DefaultConnection" = format("Server=\"marathon-itmarathon-prod.mysql.database.azure.com\"; port=\"3306\" UserID = \"%s\";Password=\"%s\";Database=\"%s\";", var.mysql_admin_username, var.mysql_admin_password,"marathon-db-${var.project_name}-${var.environment}")
    "SMTP_PORT"     = var.smtp_port
    "SMTP_USERNAME" = var.smtp_username
    "SMTP_PASSWORD" = var.smtp_password
    "SMTP_HOST"     = "smtp.azurecomm.net"
    "APP_CONFIG__ACCESS_TOKEN__RESET_PASSWORD_TOKEN_SECRET" = "secret"
    "APP_CONFIG__ACCESS_TOKEN__VERIFICATION_TOKEN_SECRET"   = "secret1"
    "APP_CONFIG__DB__ECHO"                                  = "TRUE"
    "APP_CONFIG__DB__ALEMBIC_URL"                           = format("mysql+aiomysql://%s:%s@marathon-itmarathon-prod.mysql.database.azure.com:3306/%s",
      var.mysql_admin_username,
      var.mysql_admin_password,
      "${var.project_name}-${var.environment}")
    "APP_CONFIG__DB__URL"                           = format("mysql+aiomysql://%s:%s@marathon-itmarathon-prod.mysql.database.azure.com:3306/%s",
      var.mysql_admin_username,
      var.mysql_admin_password,
      "${var.project_name}-${var.environment}")
    "APP_CONFIG__EMAIL_CONNECTION_STRING" = var.email_connection_string
  } 


  virtual_network_subnet_id = var.public_subnet_id


  # Enable system assigned managed identity
  identity {
    type = "SystemAssigned"
  }
}
