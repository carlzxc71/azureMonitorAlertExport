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

return $Alerts
