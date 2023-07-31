#terraform init -backend-config="beconf.tfvars"
# Create availability set
resource "azurerm_availability_set" "avs_id_prod_hub_fw" {
  name                        = "AVS-ID-PROD-HUB-FW"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rgp_id_prod_hub_fw.name
  managed                     = true
  platform_fault_domain_count = 2
  tags                        = var.tags
}

resource "azurerm_public_ip" "pub_id_prod_hub_fw_public_pri" {
  name                = "NVIDFW001-PIP"
  resource_group_name = azurerm_resource_group.rgp_id_prod_hub_fw.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Basic"
  tags                = var.tags
}

/*
resource "azurerm_public_ip" "pub-id-prod-hub-fw-untrust" {
  name                = "nvidfw001-2-pip-untrust-floating"
  resource_group_name = azurerm_resource_group.rgp_id_prod_hub_fw.name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_public_ip" "pub-id-prod-hub-fw-vpn" {
  name                = "nvidfw001-2-pip-vpn-floating"
  resource_group_name = azurerm_resource_group.rgp_id_prod_hub_fw.name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags
}


## Accept market place agreement
resource "azurerm_marketplace_agreement" "paloalto_license_agreement" {
  publisher = data.azurerm_platform_image.paloalto_image_hub_fw.publisher
  offer     = data.azurerm_platform_image.paloalto_image_hub_fw.offer
  plan      = data.azurerm_platform_image.paloalto_image_hub_fw.sku
}
*/


# PaloAlto FW
module "nvidfw001" {
  source                 = "git::ssh://git@vip-gitlab.staging.nod.nuance.com/cloud/terraform-modules/centos.git?ref=v6.5"
  vm_name                = "nvidfw001"
  resource_group         = azurerm_resource_group.rgp_id_prod_hub_fw
  vm_size                = "Standard_DS4_v2"
  vm_disk_type           = "StandardSSD_LRS"
  sa_diagnostics         = azurerm_storage_account.bootdiag_hub_fw
  availability_set_id    = azurerm_availability_set.avs_id_prod_hub_fw.id
  vm_settings            = { bootstrap_enabled = false }
  enable_datadisk_varlog = false
  tags                   = var.tags
  nics = [{ ip_address = [{ private_ip = "10.186.253.52", public_ip = azurerm_public_ip.pub_id_prod_hub_fw_public_pri.id }]
    subnet_id = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-MGMT"].id
    settings  = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.252.4" }, { private_ip = "10.186.252.6" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-UNTRUST"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.253.4" }, { private_ip = "10.186.253.6" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-TRUST"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.253.20" }, { private_ip = "10.186.253.22" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-DMZ"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.253.36" }, { private_ip = "10.186.253.38" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-VPN"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.253.244" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-HA2"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    }
  ]
  os = {
    publisher = data.azurerm_platform_image.paloalto_image_hub_fw.publisher
    offer     = data.azurerm_platform_image.paloalto_image_hub_fw.offer
    sku       = data.azurerm_platform_image.paloalto_image_hub_fw.sku
    version   = data.azurerm_platform_image.paloalto_image_hub_fw.version
  }
  plan = {
    publisher = data.azurerm_platform_image.paloalto_image_hub_fw.publisher
    product   = data.azurerm_platform_image.paloalto_image_hub_fw.offer
    name      = data.azurerm_platform_image.paloalto_image_hub_fw.sku
  }

}

resource "azurerm_public_ip" "pub_id_prod_hub_fw_public_sec" {
  name                = "NVIDFW002-PIP"
  resource_group_name = azurerm_resource_group.rgp_id_prod_hub_fw.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Basic"
  tags                = var.tags
}


# Palo Alto Secondary FW
module "nvidfw002" {
  source                 = "git::ssh://git@vip-gitlab.staging.nod.nuance.com/cloud/terraform-modules/centos.git?ref=v6.5"
  vm_name                = "nvidfw002"
  resource_group         = azurerm_resource_group.rgp_id_prod_hub_fw
  vm_size                = "Standard_DS4_v2"
  vm_disk_type           = "StandardSSD_LRS"
  sa_diagnostics         = azurerm_storage_account.bootdiag_hub_fw
  availability_set_id    = azurerm_availability_set.avs_id_prod_hub_fw.id
  vm_settings            = { bootstrap_enabled = false }
  enable_datadisk_varlog = false
  tags                   = var.tags

  nics = [{ ip_address = [{ private_ip = "10.186.253.53", public_ip = azurerm_public_ip.pub_id_prod_hub_fw_public_sec.id }]
    subnet_id = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-MGMT"].id
    settings  = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.252.5" }, { private_ip = "10.186.252.7" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-UNTRUST"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.253.5" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-TRUST"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.253.21" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-DMZ"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.253.37" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-VPN"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    },
    { ip_address = [{ private_ip = "10.186.253.245" }]
      subnet_id  = module.vnt_id_prod_hub_fw.subnets["SUB-ID-PROD-HUB-FW-HA2"].id
      settings   = { ip_forwarding = true, accelerated_networking = true }
    }
  ]

  os = {
    publisher = data.azurerm_platform_image.paloalto_image_hub_fw.publisher
    offer     = data.azurerm_platform_image.paloalto_image_hub_fw.offer
    sku       = data.azurerm_platform_image.paloalto_image_hub_fw.sku
    version   = data.azurerm_platform_image.paloalto_image_hub_fw.version
  }

  plan = {
    publisher = data.azurerm_platform_image.paloalto_image_hub_fw.publisher
    product   = data.azurerm_platform_image.paloalto_image_hub_fw.offer
    name      = data.azurerm_platform_image.paloalto_image_hub_fw.sku
  }
  }
 
