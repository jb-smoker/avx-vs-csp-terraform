locals {
  transit_firenet = {
    azure_east = {
      transit_account     = "azure-account"
      transit_cloud       = "azure"
      transit_cidr        = "10.1.0.0/23"
      transit_region_name = "East US"
      transit_asn         = 65101
      transit_ha_gw       = false
      firenet             = true
    },
    gcp_west = {
      transit_account     = "gcp-account"
      transit_cloud       = "gcp"
      transit_cidr        = "10.2.0.0/23"
      transit_lan_cidr    = "10.149.1.0/24"
      firenet_egress_cidr = "10.149.2.0/24"
      firenet_mgmt_cidr   = "10.149.3.0/24"
      transit_region_name = "us-west1"
      transit_asn         = 65102
      transit_ha_gw       = false
      firenet             = false
    },
  }
}

# Azure Provider
resource "azurerm_resource_group" "transit" {
  name     = "rg-av-avx-east-us-transit"
  location = local.transit_firenet.azure_east.transit_region_name
}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-av-avx-east-us-spoke-1"
  location = local.transit_firenet.azure_east.transit_region_name
}

resource "azurerm_virtual_network" "transit" {
  name                = "avx-east-us-transit"
  location            = azurerm_resource_group.transit.location
  resource_group_name = azurerm_resource_group.transit.name
  address_space       = [local.transit_firenet.azure_east.transit_cidr]
}

resource "azurerm_subnet" "transit_public_ingress_1" {
  name                 = "avx-east-us-transit-Public-FW-ingress-egress-1"
  resource_group_name  = azurerm_resource_group.transit.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [cidrsubnet(local.transit_firenet.azure_east.transit_cidr, 5, 0)]
}

resource "azurerm_subnet" "transit_public_ingress_2" {
  name                 = "avx-east-us-transit-Public-FW-ingress-egress-2"
  resource_group_name  = azurerm_resource_group.transit.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [cidrsubnet(local.transit_firenet.azure_east.transit_cidr, 5, 1)]
}

resource "azurerm_subnet" "transit_mgmt_1" {
  name                 = "avx-east-us-transit-Public-gateway-and-firewall-mgmt-1"
  resource_group_name  = azurerm_resource_group.transit.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [cidrsubnet(local.transit_firenet.azure_east.transit_cidr, 5, 2)]
}

resource "azurerm_subnet" "transit_mgmt_2" {
  name                 = "avx-east-us-transit-Public-gateway-and-firewall-mgmt-2"
  resource_group_name  = azurerm_resource_group.transit.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [cidrsubnet(local.transit_firenet.azure_east.transit_cidr, 5, 3)]
}

resource "azurerm_subnet" "transit_dmz" {
  name                 = "av-gw-avx-east-us-transit-dmz-firewall"
  resource_group_name  = azurerm_resource_group.transit.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [cidrsubnet(local.transit_firenet.azure_east.transit_cidr, 5, 4)]
}

resource "azurerm_subnet" "transit_lan" {
  name                 = "av-gw-avx-east-us-transit-dmz-firewall-lan"
  resource_group_name  = azurerm_resource_group.transit.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [cidrsubnet(local.transit_firenet.azure_east.transit_cidr, 5, 5)]
}

resource "azurerm_subnet" "transit_vng" {
  name                 = "av-gw-avx-east-us-transit-vng-traffic"
  resource_group_name  = azurerm_resource_group.transit.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [cidrsubnet(local.transit_firenet.azure_east.transit_cidr, 5, 6)]
}

resource "azurerm_virtual_network" "spoke" {
  name                = "avx-east-us-spoke-1"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = [cidrsubnet("${trimsuffix(local.transit_firenet.azure_east.transit_cidr, "23")}16", 8, 2)]
}

resource "azurerm_subnet" "spoke_public_1" {
  name                 = "avx-east-us-spoke-1-Public-subnet-1"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(cidrsubnet("${trimsuffix(local.transit_firenet.azure_east.transit_cidr, "23")}16", 8, 2), 4, 1)]
}

resource "azurerm_subnet" "spoke_public_2" {
  name                 = "avx-east-us-spoke-1-Public-subnet-2"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(cidrsubnet("${trimsuffix(local.transit_firenet.azure_east.transit_cidr, "23")}16", 8, 2), 4, 3)]
}

resource "azurerm_subnet" "spoke_private_1" {
  name                 = "avx-east-us-spoke-1-Private-subnet-1"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(cidrsubnet("${trimsuffix(local.transit_firenet.azure_east.transit_cidr, "23")}16", 8, 2), 4, 2)]
}

resource "azurerm_subnet" "spoke_private_2" {
  name                 = "avx-east-us-spoke-1-Private-subnet-2"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(cidrsubnet("${trimsuffix(local.transit_firenet.azure_east.transit_cidr, "23")}16", 8, 2), 4, 4)]
}

resource "azurerm_subnet" "spoke_public_gateway_1" {
  name                 = "avx-east-us-spoke-1-Public-gateway-subnet-1"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [cidrsubnet(cidrsubnet("${trimsuffix(local.transit_firenet.azure_east.transit_cidr, "23")}16", 8, 2), 4, 0)]
}

resource "azurerm_route_table" "spoke_public_1" {
  name                          = "avx-east-us-spoke-1-Public-subnet-1-rtb"
  location                      = azurerm_resource_group.spoke.location
  resource_group_name           = azurerm_resource_group.spoke.name
  disable_bgp_route_propagation = false
}

resource "azurerm_route_table" "spoke_public_2" {
  name                          = "avx-east-us-spoke-1-Public-subnet-2-rtb"
  location                      = azurerm_resource_group.spoke.location
  resource_group_name           = azurerm_resource_group.spoke.name
  disable_bgp_route_propagation = false
}

resource "azurerm_route_table" "spoke_private_1" {
  name                          = "avx-east-us-spoke-1-Private-subnet-1-rtb"
  location                      = azurerm_resource_group.spoke.location
  resource_group_name           = azurerm_resource_group.spoke.name
  disable_bgp_route_propagation = false
}

resource "azurerm_route_table" "spoke_private_2" {
  name                          = "avx-east-us-spoke-1-Private-subnet-2-rtb"
  location                      = azurerm_resource_group.spoke.location
  resource_group_name           = azurerm_resource_group.spoke.name
  disable_bgp_route_propagation = false
}

resource "azurerm_subnet_route_table_association" "spoke_public_1" {
  subnet_id      = azurerm_subnet.spoke_public_1.id
  route_table_id = azurerm_route_table.spoke_public_1.id
}

resource "azurerm_subnet_route_table_association" "spoke_public_2" {
  subnet_id      = azurerm_subnet.spoke_public_2.id
  route_table_id = azurerm_route_table.spoke_public_2.id
}

resource "azurerm_subnet_route_table_association" "spoke_private_1" {
  subnet_id      = azurerm_subnet.spoke_private_1.id
  route_table_id = azurerm_route_table.spoke_private_1.id
}

resource "azurerm_subnet_route_table_association" "spoke_private_2" {
  subnet_id      = azurerm_subnet.spoke_private_2.id
  route_table_id = azurerm_route_table.spoke_private_2.id
}

# GCP Provider
module "gcp_spoke" {
  source       = "github.com/terraform-google-modules/terraform-google-network"
  project_id   = var.gcp_project_id
  network_name = "avx-us-west1-spoke-1"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "avx-us-west1-spoke-1"
      subnet_ip     = cidrsubnet("${trimsuffix(local.transit_firenet.gcp_west.transit_cidr, "23")}16", 8, 2)
      subnet_region = local.transit_firenet.gcp_west.transit_region_name
    },
  ]
}

module "gcp_transit" {
  source       = "github.com/terraform-google-modules/terraform-google-network"
  project_id   = var.gcp_project_id
  network_name = "avx-us-west1-transit"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "avx-us-west1-transit"
      subnet_ip     = local.transit_firenet.gcp_west.transit_cidr
      subnet_region = local.transit_firenet.gcp_west.transit_region_name
    },
  ]
}

module "gcp_transit_egress" {
  source       = "github.com/terraform-google-modules/terraform-google-network"
  project_id   = var.gcp_project_id
  network_name = "avx-us-west1-transit-egress"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "avx-us-west1-transit-egress"
      subnet_ip     = local.transit_firenet.gcp_west.firenet_egress_cidr
      subnet_region = local.transit_firenet.gcp_west.transit_region_name
    },
  ]
}

module "gcp_transit_lan" {
  source       = "github.com/terraform-google-modules/terraform-google-network"
  project_id   = var.gcp_project_id
  network_name = "avx-us-west1-transit-lan"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "avx-us-west1-transit-lan"
      subnet_ip     = local.transit_firenet.gcp_west.transit_lan_cidr
      subnet_region = local.transit_firenet.gcp_west.transit_region_name
    },
  ]
}

module "gcp_transit_mgmt" {
  source       = "github.com/terraform-google-modules/terraform-google-network"
  project_id   = var.gcp_project_id
  network_name = "avx-us-west1-transit-mgmt"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "avx-us-west1-transit-mgmt"
      subnet_ip     = local.transit_firenet.gcp_west.firenet_mgmt_cidr
      subnet_region = local.transit_firenet.gcp_west.transit_region_name
    },
  ]
}

# Aviatrix Provider (for Aviarix Components only)
resource "aviatrix_transit_gateway" "gcp_transit" {
  single_az_ha           = true
  gw_name                = "avx-us-west1-transit"
  vpc_id                 = "${module.gcp_transit.network_name}~-~${var.gcp_project_id}"
  cloud_type             = 4
  vpc_reg                = "${local.transit_firenet.gcp_west.transit_region_name}-b"
  connected_transit      = true
  gw_size                = "n1-highcpu-4"
  account_name           = local.transit_firenet.gcp_west.transit_account
  subnet                 = local.transit_firenet.gcp_west.transit_cidr
  enable_transit_firenet = true
  local_as_number        = local.transit_firenet.gcp_west.transit_asn
  enable_segmentation    = true
  lan_vpc_id             = module.gcp_transit_lan.network_name
  lan_private_subnet     = local.transit_firenet.gcp_west.transit_lan_cidr
  depends_on = [
    module.gcp_transit
  ]
}

resource "aviatrix_spoke_gateway" "gcp_spoke" {
  single_az_ha                      = true
  gw_name                           = "avx-us-west1-spoke-1"
  vpc_id                            = "${module.gcp_spoke.network_name}~-~${var.gcp_project_id}"
  cloud_type                        = 4
  vpc_reg                           = "${local.transit_firenet.gcp_west.transit_region_name}-b"
  gw_size                           = "n1-standard-1"
  account_name                      = local.transit_firenet.gcp_west.transit_account
  subnet                            = module.gcp_spoke.subnets_ips[0]
  manage_transit_gateway_attachment = false
  depends_on = [
    module.gcp_spoke
  ]
}

resource "aviatrix_transit_gateway" "azure_transit" {
  single_az_ha           = true
  gw_name                = "avx-east-us-transit"
  vpc_id                 = "${azurerm_virtual_network.transit.name}:${azurerm_virtual_network.transit.resource_group_name}:${azurerm_virtual_network.transit.guid}"
  cloud_type             = 8
  vpc_reg                = local.transit_firenet.azure_east.transit_region_name
  connected_transit      = true
  gw_size                = "Standard_D3_v2"
  account_name           = local.transit_firenet.azure_east.transit_account
  subnet                 = azurerm_subnet.transit_mgmt_1.address_prefixes[0]
  zone                   = "az-1"
  enable_transit_firenet = true
  local_as_number        = local.transit_firenet.azure_east.transit_asn
  enable_segmentation    = true
  depends_on = [
    azurerm_subnet.transit_dmz,
    azurerm_subnet.transit_lan,
    azurerm_subnet.transit_mgmt_1,
    azurerm_subnet.transit_mgmt_2,
    azurerm_subnet.transit_public_ingress_1,
    azurerm_subnet.transit_public_ingress_2,
    azurerm_subnet.transit_vng
  ]
}

resource "aviatrix_spoke_gateway" "azure_spoke" {
  single_az_ha                      = true
  gw_name                           = "avx-east-us-spoke-1"
  vpc_id                            = "${azurerm_virtual_network.spoke.name}:${azurerm_virtual_network.spoke.resource_group_name}:${azurerm_virtual_network.spoke.guid}"
  cloud_type                        = 8
  vpc_reg                           = local.transit_firenet.azure_east.transit_region_name
  gw_size                           = "Standard_B1ms"
  account_name                      = local.transit_firenet.azure_east.transit_account
  subnet                            = azurerm_subnet.spoke_public_gateway_1.address_prefixes[0]
  zone                              = "az-1"
  manage_transit_gateway_attachment = false
}

resource "aviatrix_firenet" "azure" {
  vpc_id                               = aviatrix_transit_gateway.azure_transit.vpc_id
  inspection_enabled                   = true
  egress_enabled                       = false
  manage_firewall_instance_association = false
  tgw_segmentation_for_egress_enabled  = false
  hashing_algorithm                    = "5-Tuple"
}

resource "aviatrix_firewall_instance" "azure" {
  firewall_name          = "avx-east-us-transit-az1-fw1"
  firewall_size          = "Standard_D3_v2"
  vpc_id                 = aviatrix_transit_gateway.azure_transit.vpc_id
  firewall_image         = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  firewall_image_id      = "paloaltonetworks:vmseries1:byol:9.1.0"
  firewall_image_version = "9.1.0"
  egress_subnet          = azurerm_subnet.transit_public_ingress_1.address_prefixes[0]
  firenet_gw_name        = azurerm_virtual_network.transit.name
  username               = "fwadmin"
  password               = var.azure_fw_password
  management_subnet      = azurerm_subnet.transit_mgmt_1.address_prefixes[0]
}

resource "aviatrix_firewall_instance_association" "azure" {
  vpc_id               = aviatrix_transit_gateway.azure_transit.vpc_id
  firenet_gw_name      = azurerm_virtual_network.transit.name
  instance_id          = aviatrix_firewall_instance.azure.instance_id
  firewall_name        = aviatrix_firewall_instance.azure.firewall_name
  lan_interface        = aviatrix_firewall_instance.azure.lan_interface
  management_interface = aviatrix_firewall_instance.azure.management_interface
  egress_interface     = aviatrix_firewall_instance.azure.egress_interface
  attached             = true
}

resource "aviatrix_spoke_transit_attachment" "azure_spoke" {
  spoke_gw_name   = aviatrix_spoke_gateway.azure_spoke.gw_name
  transit_gw_name = aviatrix_transit_gateway.azure_transit.gw_name
}

resource "aviatrix_spoke_transit_attachment" "gcp_spoke" {
  spoke_gw_name   = aviatrix_spoke_gateway.gcp_spoke.gw_name
  transit_gw_name = aviatrix_transit_gateway.gcp_transit.gw_name
}

resource "aviatrix_transit_gateway_peering" "transit_gateway_peering_1" {
  transit_gateway_name1 = aviatrix_transit_gateway.gcp_transit.gw_name
  transit_gateway_name2 = aviatrix_transit_gateway.azure_transit.gw_name
  gateway1_excluded_network_cidrs = [
    "0.0.0.0/0"
  ]
  gateway2_excluded_network_cidrs = [
    "0.0.0.0/0"
  ]
}
