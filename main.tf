terraform {
  # Set the required configuration for the script so we are executing with the same provider version ever time...
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.27.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = "core-tfstate"
    key                  = "core.vmcompany.tf.state"
    access_key           = ""
  }
}

# Configure the Azure Provider...
provider "azurerm" {
  features {}
  environment = "production"
}

# Create a resource group for our application.
resource "azurerm_resource_group" "vending-machine-rg" {
  name     = "vending-machines-rg"
  location = "West Europe"
}

# Create a virtual network to access our vending machine resources.
resource "azurerm_virtual_network" "vending-machine-vnet" {
  name                = "vending-machine-vnet"
  resource_group_name = azurerm_resource_group.vending-machine-rg.name
  location            = azurerm_resource_group.vending-machine-rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "vending-machine-snet" {
  name                 = "vending-machine-snet"
  resource_group_name  = azurerm_resource_group.vending-machine-rg.name
  virtual_network_name = azurerm_virtual_network.vending-machine-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vending-machine-inet" {
  name                = "vending-machine-inet"
  location            = azurerm_resource_group.vending-machine-rg.location
  resource_group_name = azurerm_resource_group.vending-machine-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vending-machine-snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vending-machine-linux" {
  name                = "vending-machine-linux"
  resource_group_name = azurerm_resource_group.vending-machine-rg.name
  location            = azurerm_resource_group.vending-machine-rg.location
  size                = "Standard_F2"
  admin_username      = "hello_world"

  network_interface_ids = [
    azurerm_network_interface.vending-machine-inet.id
  ]

  admin_ssh_key {
    username   = "hello_world"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}