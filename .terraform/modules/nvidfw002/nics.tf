# NICs
locals {
  nics_settings = {
    "ip_forwarding"          = false
    "accelerated_networking" = false
  }
  nics = length(var.nics) > 0 ? [for nic in var.nics : {
    ip_address = nic.ip_address
    subnet_id  = nic.subnet_id
    settings   = merge(local.nics_settings, nic.settings)
  }] : [{ ip_address = [{ private_ip = var.ip_address }], subnet_id = var.subnet_id, settings = local.nics_settings }]
}

resource "azurerm_network_interface" "nic" {
  count                         = length(local.nics)
  name                          = "${var.vm_name}_nic-eth${count.index}"
  location                      = var.resource_group.location
  resource_group_name           = var.resource_group.name
  enable_ip_forwarding          = local.nics[count.index].settings["ip_forwarding"]
  enable_accelerated_networking = local.nics[count.index].settings["accelerated_networking"]

  dynamic "ip_configuration" {
    for_each = [
      for ip_address in local.nics[count.index].ip_address : {
        private_ip_address = lookup(ip_address, "private_ip", null)
        public_ip_address  = lookup(ip_address, "public_ip", null)
    }]

    content {
      name                          = ip_configuration.key == 0 ? "${var.vm_name}-SubnetIPConfig" : "${var.vm_name}-AdditionalIP-${ip_configuration.key}"
      subnet_id                     = local.nics[count.index].subnet_id
      private_ip_address_allocation = "static"
      private_ip_address            = ip_configuration.value.private_ip_address
      primary                       = ip_configuration.key == 0 ? true : false
      public_ip_address_id          = ip_configuration.value.public_ip_address
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags["deployed-by"]]
  }
}
