terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~> 2.24.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.91.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.6.0"
    }
  }
  required_version = ">= 1.3.0"
}
