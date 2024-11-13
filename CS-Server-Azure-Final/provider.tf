provider "azurerm" {
  features {}

  subscription_id   = ""
  tenant_id         = ""
  client_id         = ""
  client_secret     = ""
}





terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "~>2.0"
      version = "3.45.0"
    }
    #namecheap = {
    #  source = "namecheap/namecheap"
    #  version = "2.1.0"
    #}
    #cloudflare = {
    #  source = "cloudflare/cloudflare"
    #  version = "3.31.0"
    #}
    random = {
      source = "hashicorp/random"
      version = "2.3.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.3"
    }

  }
}

