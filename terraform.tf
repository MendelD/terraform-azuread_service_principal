terraform {
    required_version = ">=1.8.2"

    required_providers {
        azuread = {
            source  = "hashicorp/azuread"
            version = ">=2.48.0"
        }
        azurerm = {
            source  = "hashicorp/azurerm"
            version = ">3.108.0"
        }
    }
}