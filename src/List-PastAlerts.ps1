## Set correct subscription

Select-AzSubscription -Subscription "b55e1bab-2d62-42f4-8d58-feeb80f33f7e"

## List past alerts

# Define the start and end time for the custom time range
$startTime = (Get-Date).AddDays(-25)
$endTime = Get-Date -Format yyyy-MM-dd

# Retrieve the alerts for the custom time range
Get-AzAlert -CustomTimeRange "$(Get-Date $startTime -Format yyyy-MM-dd)/$endTime" | Sort-Object StartDateTime

