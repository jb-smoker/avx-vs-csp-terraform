locals {
  transit_firenet = {
    azure = {
      transit_account     = "azure-account"
      transit_cloud       = "azure"
      transit_cidr        = "10.1.0.0/23"
      transit_region_name = "East US"
      transit_asn         = 65101
      transit_ha_gw       = false
      firenet             = true
    },
    gcp = {
      transit_account     = "gcp-account"
      transit_cloud       = "gcp"
      transit_cidr        = "10.2.0.0/23"
      transit_lan_cidr    = "10.149.1.0/24"
      firenet_egress_cidr = "10.149.2.0/24"
      firenet_mgmt_cidr   = "10.149.3.0/24"
      transit_region_name = "us-west1"
      transit_asn         = 65102
      transit_ha_gw       = false
      firenet             = true
    },
  }
}

# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit-deployment-framework/aviatrix/latest
module "framework" {
  source  = "terraform-aviatrix-modules/mc-transit-deployment-framework/aviatrix"
  version = "v1.0.1"

  default_firenet_firewall_image = {
    azure = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)",
    gcp   = "Palo Alto Networks VM-Series Next-Generation Firewall BYOL",
  }

  transit_firenet = local.transit_firenet
}

# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest
module "spoke" {
  for_each = local.transit_firenet
  source   = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version  = "1.4.1"

  cloud    = each.value.transit_cloud
  name     = "avx-${replace(lower(each.value.transit_region_name), " ", "-")}-spoke-1"
  cidr     = cidrsubnet("${trimsuffix(each.value.transit_cidr, "23")}16", 8, 2)
  region   = each.value.transit_region_name
  account  = each.value.transit_account
  attached = false
  ha_gw    = false
}

resource "aviatrix_spoke_transit_attachment" "spoke" {
  for_each        = local.transit_firenet
  spoke_gw_name   = module.spoke[each.key].spoke_gateway.gw_name
  transit_gw_name = module.framework.transit[each.key].transit_gateway.gw_name
}
