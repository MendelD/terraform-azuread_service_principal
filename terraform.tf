terraform {
    required_version = ">=1.8.2"

    required_providers {
        azuread = {
            source  = "hashicorp/azuread"
            version = ">=2.48.0"
        }
    }
}