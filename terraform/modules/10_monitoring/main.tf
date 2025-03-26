# data "template_file" "init_script" {
#   template = file("${path.module}/init_script.sh")
#   vars = {
#     azure_tenant_id       = var.azure_tenant_id
#     azure_client_id       = var.azure_client_id
#     azure_client_secret   = var.azure_client_secret
#     azure_subscription_id = var.azure_subscription_id
#     grafana_password      = var.grafana_password
#     }
#   }

resource "azurerm_network_interface" "monitoring_nic" {
  name                = "mon-nic-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          =  var.public_ip_id
  }
}

resource "azurerm_linux_virtual_machine" "monitoring_vm" {
  name                = "mon-vm-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.monitoring_nic.id,
  ]

  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_keys
    content {
      username   = var.admin_username
      public_key = admin_ssh_key.value
    }
  }

  os_disk {
    name                 = "osdisk-monitoring-vm-${var.project_name}-${var.environment}"
    caching              = var.os_disk_config.caching
    storage_account_type = var.os_disk_config.storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  custom_data = base64encode(
    templatefile("${path.module}/init_script.sh", {
      azure_tenant_id       = var.azure_tenant_id
      azure_client_id       = var.azure_client_id
      azure_client_secret   = var.azure_client_secret
      azure_subscription_id = var.azure_subscription_id
      grafana_password      = var.grafana_password
    })
  )
  
  #custom_data = base64encode(data.template_file.init_script.rendered)

}