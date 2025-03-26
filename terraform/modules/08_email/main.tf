resource "azuread_application" "smtp_auth_app" {
  display_name = "smtp_auth_app-${var.project_name}-${var.environment}"
}

resource "azuread_service_principal" "smtp_auth_sp" {
  client_id = azuread_application.smtp_auth_app.client_id
}

resource "azurerm_role_assignment" "smtp_role_assignment" {
  scope              = azurerm_communication_service.marathon_communication_service.id
  role_definition_id = azurerm_role_definition.smtp_send_role.role_definition_resource_id
  #If something goes wrong, you can use the principal_id from the azuread_service_principal.smtp_auth_sp.id
  # principal_id = azuread_service_principal.smtp_auth_sp.id
  principal_id = azuread_service_principal.smtp_auth_sp.object_id
}

resource "azuread_application_password" "smtp_auth_secret" {
  application_id = azuread_application.smtp_auth_app.id
  end_date       = "2099-01-01T01:02:03Z"
}

resource "azurerm_role_definition" "smtp_send_role" {
  name        = "smtp_send_role-${var.project_name}-${var.environment}"
  scope       =  data.azurerm_subscription.current.id
  description = "Custom role for sending emails via SMTP"

  permissions {
    actions = [
      "Microsoft.Communication/CommunicationServices/Read",
      "Microsoft.Communication/EmailServices/Write"
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}


resource "azurerm_communication_service" "marathon_communication_service" {
  name                = "marathon-communication-service-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  # location            = var.location
  data_location       = var.data_location
  # tags = var.marathon_communication_service_tags
}

resource "azurerm_email_communication_service" "marathon_email_communication_service" {
  name                = "email-communication-service-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
  
  # tags = var.marathon_email_communication_service_tags
}

resource "azurerm_email_communication_service_domain" "marathon_email_communication_service_domain" {
  name             = "AzureManagedDomain" # The name must be exectly this, otherwise error
  email_service_id = azurerm_email_communication_service.marathon_email_communication_service.id
  domain_management = "AzureManaged"
  # tags = var.marathon_communication_service_email_domain_tags
}

resource "azurerm_communication_service_email_domain_association" "association" {
  email_service_domain_id  = azurerm_email_communication_service_domain.marathon_email_communication_service_domain.id
  communication_service_id = azurerm_communication_service.marathon_communication_service.id
}


