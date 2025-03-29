output "resource_group_name" {
  value = module.network.resource_group_name
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "jenkins_vm_public_ip" {
  value = module.network.public_ip_addresses["jenkins"]
}

output "monitoring_vm_public_ip" {
  value = module.network.public_ip_addresses["monitoring"]
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "jenkins_admin_password" {
  value     = "Используйте команду: 'ssh ${var.vm_config.admin_username}@${module.network.public_ip_addresses["jenkins"]} \"sudo cat /var/lib/jenkins/secrets/initialAdminPassword\"'"
  sensitive = false
}

output "jenkins_url" {
  value = "http://${module.network.public_ip_addresses["jenkins"]}:8080"
}

output "sonarqube_url" {
  value = "http://${module.network.public_ip_addresses["jenkins"]}:9000 (используйте admin/admin при первом входе)"
}

output "grafana_url" {
  value = "http://${module.network.public_ip_addresses["monitoring"]}:3000"
}

output "grafana_login" {
  value = "admin"
}

output "prometheus_url" {
  value = "http://${module.network.public_ip_addresses["monitoring"]}:9090"
}

output "netflix_app_url" {
  value = "http://${module.network.public_ip_addresses["jenkins"]}:8081"
}