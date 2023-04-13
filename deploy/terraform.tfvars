// Resource group variables
rg_name     = "rg-monitor-automation-001"
rg_location = "West Europe"

// Automation account variables
aa_account_name = "aa-monitorautomation-001"
aa_account_sku  = "Basic"
runbook_schedule = {
  day        = "Monday"
  occurrence = 1
}

## Storage account configuration
stg_name           = "stgazuremonitoralert001"
stg_share_name     = "share01"
stg_share_quota    = 5
stg_directory_name = "directory01"
