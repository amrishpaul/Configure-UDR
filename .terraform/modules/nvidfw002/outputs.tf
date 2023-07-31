output "id" {
  value = azurerm_linux_virtual_machine.centos_virtual_machine.id
}

output "name" {
  value = azurerm_linux_virtual_machine.centos_virtual_machine.name
}

output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.centos_virtual_machine.virtual_machine_id
}

output "primary_nic" {
  value = length(azurerm_network_interface.nic) > 0 ? azurerm_network_interface.nic[0] : null
}

output "nics" {
  value = azurerm_network_interface.nic[*]
}

output "os" {
  value = var.image_id != null ? var.image_id : "${var.os["publisher"]} ${var.os["offer"]} ${var.os["sku"]}"
}

output "identity" {
  value = length(azurerm_linux_virtual_machine.centos_virtual_machine.identity) > 0 ? lookup(azurerm_linux_virtual_machine.centos_virtual_machine.identity[0], "principal_id") : null
}

output "vm_settings" {
  value = local.vm_settings
}
