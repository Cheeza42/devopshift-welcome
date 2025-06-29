
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.34.0"
    }
    time = {
    source  = "hashicorp/time"
    version = "0.7.2"  # Make sure to use the version that match latest version
    }
  }
}
