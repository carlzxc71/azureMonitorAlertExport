# Automating Alert Extraction with Azure Automation, powershell & Terraform

## Note

You can use the guide in this repo to install this solution. You can find a similar guide on my website with some more images here.\
[Blogpost name](URL)

## Pre-requisites
You will need a few things to follow along:

- An Azure Subscription
- AZ CLI & Terraform installed

winget (Windows)
```CLI
winget install -e --id Hashicorp.Terraform
winget install -e --id Microsoft.AzureCLI
```

homebrew (Mac):
```CLI
brew install terraform
brew install azure-cli
```

- Git (To clone the repo)
winget (Windows):
```CLI
winget install -e --id Git.Git
```


homebrew (Mac):
```CLI
brew install git
```

## Deployment
First we need to clone the git repo with all the code we require. You can run the following command:

```CLI
git clone https://github.com/carlzxc71/azureMonitorAlertExport.git
cd azureMonitorAlertExport
cd deploy
```

You should be sitting in the deploy folder in your terminal now. Next we should sign into Azure:

```CLI
az login -t <tenant-id>
```

Make sure you are logged into the correct tenant and set your context to the correct Azure Subscription. If you want to switch to another subscription in your tenant enter:

```CLI
az account set -s <subscription-id>
```

Next we want to innitiate our Terraform workspace. You can do this whilst sitting in the deploy folder and type the following in to your terminal:

```CLI
terraform init
```

Next we want to run a plan to see what will be created:

```CLI
terraform plan
```

We will add 11 "items"

- Resource group
- Automation Account
- Runbook jobschedule
- Schedule
- Runbook
- Automation variable
- Role assignment Contributor (Scope RG)
- Role assignment Monitoring Reader (Scope Subscription)
- Storage account (Will host the CSV file)
- Share
- Directory
- If you are ready you can deploy all the items with:

```CLI
terraform apply -auto-approve
```

## Post configuration & testing

There are some things that we need to complete in the portal after Terraform has deployed all resources. This could most definately also be automated as well with Terraform as we need to import powershell modules into the automation account.


- Go to your Automation Account, if you did not change the name you can search for **aa-monitorautomation-001**
- In the left pane select **Modules**
- Select **+ Add a module**
- Select **Browse from gallery** & **Click here to browse from gallery**
- Search for **Az.Accounts** & click **Select**
- Set the runtime version to **5.1** & **Import**
- Repeat steps 3-6 but with **Az.Alertsmanagement** (You may receive the error that it has a dependency to Az.Accounts, just wait some more time to allow the import of the previous - module complete)
- Wait for the import to be completed for both modules. Status should go from **Importing** to **Available**

Now to test:

- In the left pane of the Automation Account select **Runbooks**
- Select **Get-AzureMonitorAlerts**
- You can select **</> View** to view the powershell script in its entirity
- Now we want to select **> Start**
- Wait until you have a Status: Completed and verify you do not have any warnings or errors.
- To verify successful output to the Storage Account browse to it in the Azure Portal, the name if left default is: **stgazuremonitoralert001**
- In the left pane select **File Shares** and select **share01**
- Select **directory01** to view your `alerts.csv` file

## Note

If you wish to change any values of variables when deploying this solution you can do so by updating the following file: `terraform.tfvars` inside the `deploy` folder. 
