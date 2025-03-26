#!/bin/bash
# Replace <subscription-id> with your actual subscription ID
subscription_id=$(az account show --query id -o tsv)

# Create the service principal and capture the output
sp_output=$(az ad sp create-for-rbac --name "TerraformServicePrincipal" \
    --role "Contributor" \
    --scopes "/subscriptions/$subscription_id" \
    --query '{client_id:appId, client_secret:password, tenant_id:tenant}' \
    -o json)

# Extract individual values
client_id=$(echo $sp_output | jq -r .client_id)
client_secret=$(echo $sp_output | jq -r .client_secret)
tenant_id=$(echo $sp_output | jq -r .tenant_id)

# Output the commands to set environment variables
echo "Run the following commands to set your environment variables:"
echo "export TF_VAR_azure_client_id=$client_id"
echo "export TF_VAR_azure_client_secret=$client_secret"
echo "export TF_VAR_azure_tenant_id=$tenant_id"
echo "export azure_tenant_id=$tenant_id"
echo "export TF_VAR_azure_subscription_id=$subscription_id"
echo "export azure_subscription_id=$subscription_id"