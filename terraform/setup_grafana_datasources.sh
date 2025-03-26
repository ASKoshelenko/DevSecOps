#!/bin/bash

# Azure subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using Subscription ID: $SUBSCRIPTION_ID"

# Get the tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
export TF_VAR_azure_tenant_id="$TENANT_ID"

# Function to create app registration and service principal
create_app_and_sp() {
    local app_name=$1
    local role=$2
    
    echo "Creating app registration '$app_name'..."
    local app_info=$(az ad app create --display-name "$app_name" --sign-in-audience AzureADMyOrg)
    local app_id=$(echo $app_info | jq -r '.appId')

    echo "Creating client secret..."
    local client_secret=$(az ad app credential reset --id $app_id --append --query password -o tsv)

    echo "Creating service principal..."
    az ad sp create --id $app_id

    echo "Assigning $role role..."
    az role assignment create --assignee $app_id --role "$role" --scope "/subscriptions/$SUBSCRIPTION_ID"

    echo "$app_id:$client_secret"
}

extract_credentials() {
    local creds="$1"
    local last_line=$(echo "$creds" | tail -n 1)
    local app_id=$(echo "$last_line" | grep -oE '^[^:]+')
    local client_secret=$(echo "$last_line" | grep -oE '[^:]+$')
    echo "${app_id} ${client_secret}"
}

# Check and setup Infinity datasource
if [ -z "${TF_VAR_infinity_client_id}" ] || [ -z "${TF_VAR_infinity_client_secret}" ]; then
    echo "Infinity datasource credentials not found. Creating new ones."
    infinity_creds=$(create_app_and_sp "Grafana-Infinity-Datasource-0000" "Cost Management Contributor")
    read TF_VAR_infinity_client_id TF_VAR_infinity_client_secret <<< $(extract_credentials "$infinity_creds")
    
    # Export variables
    export TF_VAR_infinity_client_id
    export TF_VAR_infinity_client_secret

    # # Check and display values
    # echo "TF_VAR_infinity_client_id: ${TF_VAR_infinity_client_id}"
    # echo "TF_VAR_infinity_client_secret: ${TF_VAR_infinity_client_secret}"

else
    echo "Existing Infinity datasource credentials found. Using them."
fi

# Check and setup Azure Monitor datasource
if [ -z "${TF_VAR_azure_client_id}" ] || [ -z "${TF_VAR_azure_client_secret}" ]; then
    echo "Azure Monitor datasource credentials not found. Creating new ones."
    azure_monitor_creds=$(create_app_and_sp "Grafana-Azure-Monitor-0000" "Monitoring Reader")
    read TF_VAR_azure_client_id TF_VAR_azure_client_secret <<< $(extract_credentials "$azure_monitor_creds")
    export TF_VAR_azure_client_id 
    export TF_VAR_azure_client_secret

    # echo "TF_VAR_azure_client_id: ${TF_VAR_azure_client_id}"
    # echo "TF_VAR_azure_client_secret: ${TF_VAR_azure_client_secret}"

else
    echo "Existing Azure Monitor datasource credentials found. Using them."
fi

# Output the set environment variables and important information
echo ""
echo "Important information for Grafana configuration:"
echo "Azure Monitor:"
echo "TF_VAR_azure_client_id: $TF_VAR_azure_client_id"
echo "TF_VAR_azure_client_secret: [Hidden for security. Use the TF_VAR_azure_client_secret environment variable]"
echo "Infinity Datasource:"
echo "TF_VAR_infinity_client_id: $TF_VAR_infinity_client_id"
echo "TF_VAR_infinity_client_secret: [Hidden for security. Use the TF_VAR_infinity_client_secret environment variable]"
echo "Common:"
echo "Tenant ID: $TF_VAR_azure_tenant_id"
echo "Subscription ID: $SUBSCRIPTION_ID"

echo ""
echo "To use these variables in your Terraform configuration, reference them as:"
echo "var.infinity_client_id"
echo "var.infinity_client_secret"
echo "var.azure_tenant_id"
echo "var.azure_client_id"
echo "var.azure_client_secret"

echo ""
echo "Next steps:"
echo "1. Configure in .tfvars user grafana_user = \"admin\" and grafana_password = \"Your Password\""
echo "2. Run terraform apply -target=module.monitoring for deploy Monitoring_VM with Grafana Server, 'Infinity data source' and 'Azure Monitor' plugins."
echo "3. Run terraform apply -target=module.grafana_dashboards for configure 'Infinity data source' plugin and provision three dashboards - cost/ vm metrics/ web app services metrics."

# Note: These environment variables will only be available in the current shell session.
# For persistent use, consider adding them to your shell profile or using a secure secret management system.
