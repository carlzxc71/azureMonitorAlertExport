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
    "deployedBy"  = "terraform"
    "environment" = "Development"
  }
}

resource "azurerm_resource_group" "rg-monitor-automation" {
  name     = "rg-monitor-automation-001"
  location = "West Europe"

  tags = local.tags
}

resource "azurerm_automation_account" "aa-monitor-automation" {
  name                = "aa-monitorautomation-001"
  location            = azurerm_resource_group.rg-monitor-automation.location
  resource_group_name = azurerm_resource_group.rg-monitor-automation.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned" # Creates a system-assigned identity
  }



  tags = local.tags
}

data "local_file" "script" {
  filename = "C:/Github/azureMonitorAlertExport/src/List-PastAlerts.ps1"
}

resource "azurerm_automation_runbook" "aa-runbook" {
  name                    = "Get-AzureMonitorAlerts"
  location                = azurerm_resource_group.rg-monitor-automation.location
  resource_group_name     = azurerm_resource_group.rg-monitor-automation.name
  automation_account_name = azurerm_automation_account.aa-monitor-automation.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Run this script to get past Azure Monitor Alerts"
  runbook_type            = "PowerShell"

  content = data.local_file.script.content

  tags = local.tags
}

resource "azurerm_automation_schedule" "schedule" {
  name                    = "powershell-automation-schedule"
  resource_group_name     = azurerm_resource_group.rg-monitor-automation.name
  automation_account_name = azurerm_automation_account.aa-monitor-automation.name
  frequency               = "Month"

  monthly_occurrence {
    day        = "Monday"
    occurrence = 1
  }

  description = "Occurs once a month"
}

resource "azurerm_automation_job_schedule" "jobschedule" {
  schedule_name           = azurerm_automation_schedule.schedule.name
  resource_group_name     = azurerm_resource_group.rg-monitor-automation.name
  automation_account_name = azurerm_automation_account.aa-monitor-automation.name
  runbook_name            = azurerm_automation_runbook.aa-runbook.name
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_resource_group.rg-monitor-automation.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.aa-monitor-automation.identity[0].principal_id
}