## Import Modules

Import-Module -Name Az 
Import-Module -Name Az.Accounts 
Import-Module -Name Az.AlertsManagement 

## Set correct subscription

$ProgressPreference="silentlyContinue"

Disable-AzContextAutosave -Scope Process
  
# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context
  
# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext 

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
$StorageAccountResourceGroup = "rg-monitor-automation-001"
$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName `
                                       -ResourceGroupName $StorageAccountResourceGroup
                                       -UseConnectedAccount `

# Upload the CSV file to Storage Account
$ShareName = "share01"
$DirectoryName = "directory01"
$FileName = "alerts.csv"
$FilePath = ".\alerts.csv"
Set-AzStorageFileContent -ShareName $ShareName -Context $StorageContext -Source $FilePath -Path $DirectoryName/$FileName -Force