data "local_file" "list_past_alerts_script" {
  filename = "../src/List-PastAlerts.ps1"
}

data "azurerm_subscription" "primary" {}

resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.rg_location

  tags = local.tags
}

resource "azurerm_automation_account" "this" {
  name                = var.aa_account_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = var.aa_account_sku

  identity {
    type = "SystemAssigned" # Creates a system-assigned identity
  }

  tags = local.tags
}


resource "azurerm_automation_runbook" "script" {
  name                    = "Get-AzureMonitorAlerts"
  location                = azurerm_resource_group.this.location
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Run this script to get past Azure Monitor Alerts"
  runbook_type            = "PowerShell"

  content = data.local_file.list_past_alerts_script.content

  tags = local.tags
}

resource "azurerm_automation_schedule" "schedule" {
  name                    = "powershell-automation-schedule"
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
  frequency               = "Month"

  monthly_occurrence {
    day        = var.runbook_schedule.day
    occurrence = var.runbook_schedule.occurrence
  }

  description = "Occurs once a month"
}

resource "azurerm_automation_job_schedule" "jobschedule" {
  schedule_name           = azurerm_automation_schedule.schedule.name
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
  runbook_name            = azurerm_automation_runbook.script.name
}

resource "azurerm_automation_variable_string" "secret" {
  name                    = "accountKey"
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
  value                   = azurerm_storage_account.this.primary_access_key
  encrypted               = true
  description             = "Account key for access to Azure Storage Account"
}

resource "azurerm_automation_variable_string" "storage_name_var" {
  name                    = "storageAccountName"
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
  value                   = azurerm_storage_account.this.name
  encrypted               = false
  description             = "The name of the Storage Account"
}

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "monitor_reader" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}

resource "azurerm_storage_account" "this" {
  name                     = var.stg_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = local.tags
}

resource "azurerm_storage_share" "share" {
  name                 = var.stg_share_name
  storage_account_name = azurerm_storage_account.this.name
  quota                = var.stg_share_quota
}

resource "azurerm_storage_share_directory" "directory" {
  name                 = var.stg_directory_name
  share_name           = azurerm_storage_share.share.name
  storage_account_name = azurerm_storage_account.this.name
}