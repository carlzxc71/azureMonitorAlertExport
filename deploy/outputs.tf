output "automation_account_name" {
  description = "The name of the Automation Account"
  value       = azurerm_automation_account.account.name
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.stg.name
}