terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.48.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  tags = {
    "deployedBy" = "terraform"
  }
}

resource "azurerm_resource_group" "rg-monitor-automation" {
  name     = "rg-monitor-automation"
  location = "West Europe"

  tags = local.tags
}

resource "azurerm_storage_account" "stg-monitorautomation" {
  name                     = "stgmonitorautomation"
  resource_group_name      = azurerm_resource_group.rg-monitor-automation.name
  location                 = azurerm_resource_group.rg-monitor-automation.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "azurerm_service_plan" "plan-monitoralerts" {
  name                = "plan-monitoralerts"
  resource_group_name = azurerm_resource_group.rg-monitor-automation.name
  location            = azurerm_resource_group.rg-monitor-automation.location
  os_type             = "Windows"
  sku_name            = "Y1"

  tags = local.tags
}

resource "azurerm_windows_function_app" "func-monitoralerts" {
  name                = "func-monitoralerts"
  resource_group_name = azurerm_resource_group.rg-monitor-automation.name
  location            = azurerm_resource_group.rg-monitor-automation.location

  storage_account_name       = azurerm_storage_account.stg-monitorautomation.name
  storage_account_access_key = azurerm_storage_account.stg-monitorautomation.primary_access_key
  service_plan_id            = azurerm_service_plan.plan-monitoralerts.id

  identity {
    type = "SystemAssigned"
  }


  site_config {
    application_stack {
      powershell_core_version = 7.2
    }
  }

  tags = local.tags
}