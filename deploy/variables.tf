// Resource group variables
variable "rg_name" {
  description = "The name of the Resource Group"
  type        = string
  default     = "rg-monitor-automation-001"
}

variable "rg_location" {
  description = "The location of the resource group"
  type        = string
}

// Automation account variables
variable "aa_account_name" {
  description = "The name of the Automation Account"
  type        = string
  default     = "aa-monitorautomation-001"
}

variable "aa_account_sku" {
  description = "The SKU of the Automation Account"
  type        = string
  default     = "Basic"
}

variable "runbook_schedule" {
  description = "The schedule set for the Automation Account Runbook"
  type = object({
    day        = string
    occurrence = number
  })
  default = {
    day        = "Monday"
    occurrence = 1
  }
}

// Storage account variables
variable "stg_name" {
  description = "The name of the Storage Account"
  type        = string
  default     = "stgazuremonitoralert001"
}

variable "stg_share_name" {
  description = "The name of the File Share inside Azure Storage"
  type        = string
  default     = "share01"
}

variable "stg_share_quota" {
  description = "Quota for the File Share storage"
  type        = number
  default     = 5
}

variable "stg_directory_name" {
  description = "The name of the Directory inside the File Share"
  type        = string
  default     = "directory01"
}