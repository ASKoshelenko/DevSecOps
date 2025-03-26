terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.7.0"
    }
  }
}

resource "grafana_data_source" "azure_cost_analysis" {
  type = "yesoreyeram-infinity-datasource"
  name = "Azure Cost Analysis Infinity"
  
  json_data_encoded = jsonencode({
    authenticationType         = "oauth2"
    tlsAuth                    = false
    tlsAuthWithCACert          = false
    oauthPassThru              = false
    customHealthCheckEnabled   = true
    customHealthCheckUrl       = "https://login.microsoftonline.com/${var.azure_tenant_id}/oauth2/token"
    allowedHosts               = [
      "https://management.azure.com/",
      "https://login.microsoftonline.com/${var.azure_tenant_id}/oauth2/token",
      "https://management.azure.com/subscriptions?api-version=2020-01-01"
    ]
    oauth2 = {
      client_id  = var.infinity_client_id
      token_url  = "https://login.microsoftonline.com/${var.azure_tenant_id}/oauth2/token"
      scopes     = []
      authStyle  = 2 # Value 2 is In Header
    }
    oauth2EndPointParamsName1 = "resource"
    defaultUrl                = "https://management.azure.com/subscriptions?api-version=2020-01-01"
  })
  
  secure_json_data_encoded = jsonencode({
    oauth2ClientSecret         = var.infinity_client_secret
    oauth2EndPointParamsValue1 = "https://management.azure.com/"
  })
}

resource "grafana_dashboard" "azure_vm_dashboard" {
  # for_each    = { for file in var.dashboard_files : basename(file) => file }
  config_json = templatefile("${path.module}/dashboards/16432_rev1_vm.json", {
    Subscription     = var.azure_subscription_id
    subscription_id  = var.azure_subscription_id
    ResourceGroup    = var.resource_group_name
  })
}

# Dashboard configuration loaded from file with variable substitution
resource "grafana_dashboard" "azure_cost_analysis" {
  config_json = templatefile("${path.module}/dashboards/21134_rev1_cost.json", {
    datasource_type = grafana_data_source.azure_cost_analysis.type
    datasource_uid  = grafana_data_source.azure_cost_analysis.uid
    subscription_id = var.azure_subscription_id

   depends_on = [grafana_data_source.azure_cost_analysis]
  })
}

resource "grafana_dashboard" "azure_multi_webapp_dashboard" {
  config_json = templatefile("${path.module}/dashboards/webapp.json", {
    datasource_name = "Azure Monitor"
    subscription_id = var.azure_subscription_id
    resource_group  = var.resource_group_name
  })
}
