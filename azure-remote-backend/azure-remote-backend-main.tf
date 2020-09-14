# Generate a random storage name for the state file.
resource "random_string" "state-file-name" {
    length = 5
    upper = false
    number = true
    lower = true
    special = false
}

# Create a Resource Group for the State File Backend
resource "azurerm_resource_group" "state-rg" {
    name = "${lower(var.company)}-tf-state-rg"
    location = var.location
    
    lifecycle {
        prevent_destroy = false
    }
    
    tags = {
        environment = var.environment
    }
}

# Create a Storage Account for the State File.
resource "azurerm_storage_account" "state-store-acc" {
    depends_on = [azurerm_resource_group.state-rg]
    
    name = "${lower(var.company)}-tf${random_string.state-file-name.result}"
    resource_group_name = azurerm_resource_group.state-rg.name
    location = azurerm_resource_group.state-rg.location
    
    account_kind = "StorageV2"
    account_tier = "Standard"
    access_tier = "Hot"
    account_replication_type = "ZRS"
    
    enable_https_traffic_only = true

    lifecycle {
        prevent_destroy = false
    }

    tags = {
        environment = var.environment
    }
}

# Create a Storage Container for the Core State File
resource "azurerm_storage_container" "core-container" {
    depends_on = [azurerm_storage_account.state-store-acc]

    name = "core-tfstate"
    storage_account_name = azurerm_storage_account.state-store-acc.name
}