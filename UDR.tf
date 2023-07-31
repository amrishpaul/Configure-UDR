terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "amrish_test" {
  name     = "AMRISH_TEST_RGP"
  location = " EAST US 2"
  tags     = { enviornment = "dev" }
}

resource "azurerm_virtual_network" "AMRISH-VNET-3" {
  name                = "amrish-vnet3"
  address_space       = ["10.90.0.0/16"]
  location            = azurerm_resource_group.amrish_test.location
  resource_group_name = azurerm_resource_group.amrish_test.name
}

resource "azurerm_subnet" "SUBNET-3" {
  name                 = "subnet-3"
  resource_group_name  = azurerm_resource_group.amrish_test.name
  virtual_network_name = azurerm_virtual_network.AMRISH-VNET-3.name
  address_prefixes     = ["10.90.3.0/24"]
}
resource "azurerm_subnet" "SUBNET-4" {
  name                 = "subnet-4"
  resource_group_name  = azurerm_resource_group.amrish_test.name
  virtual_network_name = azurerm_virtual_network.AMRISH-VNET-3.name
  address_prefixes     = ["10.90.4.0/24"]
}

resource "azurerm_virtual_network" "AMRISH-VNET-4" {
  name                = "amrish-vnet4"
  address_space       = ["10.95.0.0/16"]
  location            = azurerm_resource_group.amrish_test.location
  resource_group_name = azurerm_resource_group.amrish_test.name
}

resource "azurerm_subnet" "SUBNET-5" {
  name                 = "subnet-5"
  resource_group_name  = azurerm_resource_group.amrish_test.name
  virtual_network_name = azurerm_virtual_network.AMRISH-VNET-4.name
  address_prefixes     = ["10.95.3.0/24"]
}

resource "azurerm_subnet" "SUBNET-6" {
  name                 = "subnet-6"
  resource_group_name  = azurerm_resource_group.amrish_test.name
  virtual_network_name = azurerm_virtual_network.AMRISH-VNET-4.name
  address_prefixes     = ["10.95.4.0/24"]
}
resource "azurerm_virtual_network_peering" "amrish_Vnet3_Vnet4" {
  name                      = "vnet3to4"
  resource_group_name       = azurerm_resource_group.amrish_test.name
  virtual_network_name      = azurerm_virtual_network.AMRISH-VNET-3.name
  remote_virtual_network_id = azurerm_virtual_network.AMRISH-VNET-4.id
}

resource "azurerm_virtual_network_peering" "amrish_Vnet4_Vnet3" {
  name                      = "vnet4to3"
  resource_group_name       = azurerm_resource_group.amrish_test.name
  virtual_network_name      = azurerm_virtual_network.AMRISH-VNET-4.name
  remote_virtual_network_id = azurerm_virtual_network.AMRISH-VNET-3.id
}

resource "azurerm_route_table" "amrish_rtb" {
  name                          = "AMRISH-RTB"
  location                      = azurerm_resource_group.amrish_test.location
  resource_group_name           = azurerm_resource_group.amrish_test.name
  disable_bgp_route_propagation = false

  route {
    name           = "DMZ-1"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = "dev"
  }
}
resource "azurerm_subnet_route_table_association" "amrish-rtb-association" {
  subnet_id      = azurerm_subnet.SUBNET-4.id
  route_table_id = azurerm_route_table.amrish_rtb.id
}

