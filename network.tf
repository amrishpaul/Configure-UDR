
#terraform init -backend-config="beconf.tfvars"
locals {
  ma_vpn_endpoint   = "192.135.86.217"
  wa_vpn_endpoint   = "8.39.197.11"
  stage_ma_endpoint = "184.75.195.2/32"
}
module "vnt_id_prod_niw" {
  source         = "git::ssh://git@vip-gitlab.staging.nod.nuance.com/cloud/terraform-modules/vnet.git?ref=v6.3"
  vnet_name      = "VNT-ID-PROD-NIW"
  resource_group = azurerm_resource_group.rgp-id-prod-niw
  address_space  = ["10.186.216.0/21"]
  subnets = [
	{ name          = "SUB-ID-PROD-NIW-DB"
      address_prefix         = "10.186.216.0/26"
      network_security_rules = []
      routes = [
        { name           = "Route-to-VNT-DMZ-PROD"
          address_prefix = "10.186.192.0/21"
        next_hop = "10.186.192.69" },
        { name = "Default-to-Trust",
        address_prefix = "0.0.0.0/0" },
        { name = "Route-to-SUB-ID-PROD-NIW-RC",
        address_prefix = "10.186.217.0/24" },
        { name = "Route-to-SUB-ID-PROD-NIW-KQY",
        address_prefix = "10.186.220.0/23" },
        { name = "Route-to-SUB-ID-PROD-NIW-AGENT",
        address_prefix = "10.186.218.0/23" }
      ]
      service_endpoints = []
      subnet_settings   = {}
    },
	{ name          = "SUB-ID-PROD-NIW-RC"
      address_prefix         = "10.186.217.0/24"
      network_security_rules = []
      routes = [
        { name           = "Route-to-VNT-DMZ-PROD"
          address_prefix = "10.186.192.0/21"
        next_hop = "10.186.192.69" },
        { name = "Default-to-Trust",
        address_prefix = "0.0.0.0/0" },
        { name = "Route-to-SUB-ID-PROD-NIW-DB",
        address_prefix = "10.186.216.0/26" },
        { name = "Route-to-SUB-ID-PROD-NIW-KQY",
        address_prefix = "10.186.220.0/23" },
        { name = "Route-to-SUB-ID-PROD-NIW-AGENT",
        address_prefix = "10.186.218.0/23" }
      ]
      service_endpoints = []
      subnet_settings   = {}
    },
	{ name          = "SUB-ID-PROD-NIW-AGENT"
      address_prefix         = "10.186.218.0/23"
      network_security_rules = []
      routes = [
        { name           = "Route-to-VNT-DMZ-PROD"
          address_prefix = "10.186.192.0/21"
        next_hop = "10.186.192.69" },
        { name = "Default-to-Trust",
        address_prefix = "0.0.0.0/0" },
        { name = "Route-to-SUB-ID-PROD-NIW-RC",
        address_prefix = "10.186.217.0/24" },
        { name = "Route-to-SUB-ID-PROD-NIW-KQY",
        address_prefix = "10.186.220.0/23" },
        { name = "Route-to-SUB-ID-PROD-NIW-DB",
        address_prefix = "10.186.216.0/26" }
      ]
      service_endpoints = []
      subnet_settings   = {}
    },
	{ name          = "SUB-ID-PROD-NIW-KQY"
      address_prefix         = "10.186.220.0/23"
      network_security_rules = []
      routes = [
        { name           = "Route-to-VNT-DMZ-PROD"
          address_prefix = "10.186.192.0/21"
        next_hop = "10.186.192.69" },
        { name = "Default-to-Trust",
        address_prefix = "0.0.0.0/0" },
        { name = "Route-to-SUB-ID-PROD-NIW-RC",
        address_prefix = "10.186.217.0/24" },
        { name = "Route-to-SUB-ID-PROD-NIW-AGENT",
        address_prefix = "10.186.218.0/23" },
        { name = "Route-to-SUB-ID-PROD-NIW-DB",
        address_prefix = "10.186.216.0/26" }

      ]
      service_endpoints = []
      subnet_settings   = {}
    },
	{ name          = "SUB-ID-PROD-NIW-VIPS"
      address_prefix         = "10.186.223.0/24"
      network_security_rules = []
      routes = [
        { name           = "Route-to-VNT-DMZ-PROD"
          address_prefix = "10.186.192.0/21"
        next_hop = "10.186.192.69" },
        { name = "Default-to-Trust",
      address_prefix = "0.0.0.0/0" }        
      ]
      service_endpoints = []
      subnet_settings   = {}
    }	
  ]
  dns_servers = ["10.186.206.11", "10.186.206.12"]
  firewall_ip = "10.186.192.69"
  peerings = [{ vnet = data.azurerm_virtual_network.vnt-id-prod-dmz2,    settings = {local = {}, remote = {}, bidirectional = true } }]

  # If you need to peer with another VNET in another subscription, you need to provide explicitely the providers block
  #providers      = {
  #  azurerm.local  = azurerm # default provider
  #  azurerm.remote = azurerm # provider for the other subscription of the remote VNET
  #}

  tags = var.tags
}
