#terraform init -backend-config="beconf.tfvars"
locals {
  ma_vpn_endpoint   = "192.135.86.217"
  wa_vpn_endpoint   = "8.39.197.11"
  stage_ma_endpoint = "184.75.195.2/32"
}

module "vnt_id_prod_hub_fw" {
  source         = "git::ssh://git@vip-gitlab.staging.nod.nuance.com/terraform/terraform-modules/vnet.git?ref=v6.0"
  vnet_name      = "VNT-ID-PROD-HUB-FW"
  resource_group = azurerm_resource_group.rgp_id_prod_hub_fw
  address_space  = ["10.186.252.0/23"]
  dns_servers    = ["10.186.206.11", "10.186.206.12"]
  firewall_ip    = "10.186.253.5"
  tags           = var.tags

  subnets = [
    { name                   = "SUB-ID-PROD-HUB-FW-UNTRUST"
      address_prefix         = "10.186.252.0/24"
      subnet_settings        = {}
      service_endpoints      = []
      network_security_rules = []
      routes = []
    },
    { name                   = "SUB-ID-PROD-HUB-FW-TRUST"
      address_prefix         = "10.186.253.0/28"
      subnet_settings        = {}
      service_endpoints      = []
      network_security_rules = []
      routes = []
    },
    { name                   = "SUB-ID-PROD-HUB-FW-DMZ"
      address_prefix         = "10.186.253.16/28"
      subnet_settings        = {}
      service_endpoints      = []
      network_security_rules = []
      routes = []
    },
    { name              = "SUB-ID-PROD-HUB-FW-VPN"
      address_prefix    = "10.186.253.32/28"
      subnet_settings   = {}
      service_endpoints = []
      network_security_rules = [
        { name                       = "VPN-PEERS-ALLOW_IN"
          priority                   = "200"
          direction                  = "Inbound"
          protocol                   = "*"
          source_address_prefixes    = join(",", [local.ma_vpn_endpoint, local.wa_vpn_endpoint])
          destination_address_prefix = "10.186.253.32/28"
        }
      ]
      routes = []
    },
    { name              = "SUB-ID-PROD-HUB-FW-MGMT"
      address_prefix    = "10.186.253.48/28"
      subnet_settings   = {}
      service_endpoints = []
      network_security_rules = [
        { name                    = "ALLOW-MA-STG-PUB_HTTPS"
          priority                = "110"
          direction               = "Inbound"
          protocol                = "TCP"
          source_address_prefixes = local.stage_ma_endpoint
          destination_port_ranges = "443,22"
        },
        { name                    = "ALLOW-WA-MA-JUMPBOX-SUBNET"
          priority                = "120"
          direction               = "Inbound"
          protocol                = "TCP"
          source_address_prefixes = "10.40.42.64/27,10.52.42.64/27"
          destination_port_ranges = "443,22"
        }
      ]
      routes = [
        { name           = "Pvt-to-Trust", 
                          address_prefix = "10.0.0.0/8",
			                    next_hop       = "10.186.253.5" }
      ]
    },
    { name                   = "SUB-ID-PROD-HUB-FW-HA2"
      address_prefix         = "10.186.253.240/28"
      subnet_settings        = {}
      service_endpoints      = []
      network_security_rules = []
      routes                 = []
    }
    ]

 # peerings = [
 #   { vnet     = data.azurerm_virtual_network.vnt-id-prod-oss,
 #     settings = {}
 #   }
 # ]
}
