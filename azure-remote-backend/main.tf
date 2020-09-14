terraform {
    # Set the required configuration for the script so we are executing with the same provider version ever time...
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "2.27.0"
        }

        random = {
            source = "hashicorp/random"
            version = "2.3.0"
        }
    }
}

# Configure the Azure Provider...
provider "azurerm" {
    features {}
    environment = "production"
}
