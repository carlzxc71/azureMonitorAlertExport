## Import Modules

Import-Module -Name Az.Accounts 
Import-Module -Name Az.AlertsManagement 
Import-Module -Name Az.Storage

## Set correct subscription

$ProgressPreference="silentlyContinue"

Disable-AzContextAutosave -Scope Process
  
# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context
  
# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext 
$accountKey = Get-AutomationVariable -Name "accountKey"

## List past alerts

# Define the start and end time for the custom time range
$startTime = (Get-Date).AddDays(-25)
$endTime = Get-Date -Format yyyy-MM-dd

# Retrieve the alerts for the custom time range
$Alerts = Get-AzAlert -CustomTimeRange "$(Get-Date $startTime -Format yyyy-MM-dd)/$endTime" | Select-Object -Property Name,StartDateTime,TargetResource,MonitorCondition,MonitorConditionResolvedDateTime | 
Sort-Object StartDateTime 

# Export data to CSV
$Alerts| Export-Csv -Path ".\alerts.csv" -NoTypeInformation


# Create a storage context using the system-assigned managed identity
$StorageAccountName = "stgazuremonitoralert001"
$context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $accountKey

# Upload the CSV file to Storage Account
$ShareName = "share01"
$DirectoryName = "directory01"
$FileName = "alerts.csv"
$FilePath = ".\alerts.csv"
Set-AzStorageFileContent -ShareName $ShareName -Context $context -Source $FilePath -Path "$DirectoryName/$FileName" -Force


