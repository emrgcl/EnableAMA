# Enable Hybrid Cloud monitoring with the new Azure Monitoring Agent (AMA)

# Scenario
Contoso has an application which has 4 web servers. 2 of them are azure VMS and 2 of them are On-Premises web Servers with Azure arc enabled.

There is a set of perforamance data to be collected for all servers.
Contoso also requires to filter Event Log collection to optimize consumption.

# Overview
Data Collection Rules can be assoicated with Azure VMs or Arc Enabled Servers. Creating data collection rule and assoicating the resources are two seperate proceses but the portal experience combines these two operations.

Installing the agent is as easy as deploying an extension to an AzureVM or Azure Arc Enabled Server but this is not necesssary because the associated resoruces will pull and install the extension automatically once assoication is added on the data collection rule.

Data collection rules can be created via Json template or again through portal expereince. 

Event Data collections supports Xpath Queries to filter the Event logs.

# Requirements
- Two hyperv guests with Azure arc for servers enabled and connected
- Two Azure Virtual Machines with system-assigned managed identity
- Az.Powershlell 5.4.0 (Requirement for DCR Cmdlets)
- Az.ConnectedMachine 0.2.0
- Az.Monitor 2.4.0
- Powershell 7.0.4 (Version 7 for best practice)
- VSCode Insiders

# Demo Initialization
Before starting the demonstartion make sure you have the modules in the requirements are installed and Imported.

Run the following lines in your Powershell to Import the Parameters.PSD1 and set your variables.

```PowerShell
#Requires -Version 7.0
#Requires -Modules @{ModuleName='Az';ModuleVersion='5.4.0'},@{ModuleName='Az.Accounts';ModuleVersion='2.2.4'},@{ModuleName='Az.ConnectedMachine';ModuleVersion='0.2.0'},@{ModuleName='Az.Monitor';ModuleVersion='2.4.0'}
$ParametersFile = './Parameters.psd1'
$Parameters=Import-PowerShellDataFile -Path $ParametersFile
$VMs = $Parameters.VMs
$ArcEnabledServers = $Parameters.ArcEnabledServers
$ResourceGroupName = $Parameters.ResourceGroupName
$SubscriptionID = $Parameters.SubscriptionID
$DCRName = $Parameters.DCRName
$Location = $Parameters.Location
```

# Demo 1 - Create Data Collection on the portal and use various association options.

You might need to optimize consumption with inclusive or exclusive rules using xpath queries. This also helps if theres data that requires not to be inserterd due to compliance scenarios.

PowerShell Cmdlets for each step below can be found in ***.\Demo.ps1***

1. Create a Data Collection Rule using the 
value of the **$DCRName** variable in **Parameters.psd1** with an Event Log data source using custom and type the below Xpath Query assoicate with *VM1*
    ```
    System!*[System[EventID=7036 and Provider[@Name='Service Control Manager']] and EventData[Data[@Name='param1']='Print Spooler']]
    ```
1. Check if the extension is installed automatically using PowerShell
    ```PowerShell
    $VMs | ForEach-Object {Get-AzVMExtension -VMName $_ -ResourceGroupName $ResourceGroupName | Where-Object {$_.Name -eq 'AzureMonitorWindowsAgent'} | Select-Object -Property VMName,Name,ProvisioningState}
    ```
1. Now add Azure *ArcEnabledServer1* to the association using the Portal
 
1. Check if the extension is installed automatically using PowerShell
    ```PowerShell
    $ArcEnabledServers | ForEach-Object {$MachineName = $_ ;Get-AzConnectedMachineExtension -MachineName $_ -ResourceGroupName $ResourceGroupName -PipelineVariable $ExtensionInfo | Where-Object {$_.Name -eq 'AzureMonitorWindowsAgent'} | Select-Object -Property @{Name='MachineName';Expression={$MachineName}},Name,ProvisioningState}
    ```
1. on VM1 Type the following Powershell command
    ```PowerShell
    Restart-Service -Name Spooler -Verbose
    ```
    > **Note:** At this point we have 2 servers assoicated with the Data Collection Rule we created.
1. Now is time to run the following query on the created workspace
    ```
    Event | take 100
    ```

# Demo 2 - Install the Extension using PowerShell and Assocciate

1. Install the extension using Powershell manually on *VM2*
    ```Powershell
    Set-AzVMExtension -Name AMAWindows -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $ResourceGroupName -VMName $VMs[1] -Location $Location  -TypeHandlerVersion 1.0
    ```
1. Install the extension using Powershell manually on *ArcEnabledServer2*
    ```PowerShell
    New-AzConnectedMachineExtension -Name AMAWindows -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $ResourceGroupName -MachineName $ArcEnabledServers[1] -Location $Location -TypeHandlerVersion 1.0
    ```
1. Check if the extensions are installed manually on the second portion of the servers using powershell using the Demo 1 - Step 2 and Step 4.

    > **Note:** Please note we installed the extensions but not yet assoicated with the data collection rule.
1. Add VM2 association using PowerShell
    ```PowerShell
    $dcr = Get-AzDataCollectionRule -ResourceGroupName $ResourceGroupName -RuleName $dcrName
    $vmId = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachines/$($VMs[1])"
    $dcr | New-AzDataCollectionRuleAssociation -TargetResourceId $VMID -AssociationName "PowerShellBasedAssocVM"
    ```
1. Add ArcEnabledServer2 associations using Powershell
    ```PowerShell
    $dcr = Get-AzDataCollectionRule -ResourceGroupName $ResourceGroupName -RuleName $dcrName
    $ArcEnabledServerID = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.HybridCompute/Machines/$($ArcEnabledServers[1])"
    $dcr | New-AzDataCollectionRuleAssociation -TargetResourceId $ArcEnabledServerID  -AssociationName "PowerShellBasedAssocArc"
    ```
    > **Note:** Now we have all 4 servers associated with the new Data Collection Rule we created.

# Demo 3 - Create and Associate using ARM
Required Templates can be found in ./Templates folder

1. Create DCR using the templates. 
1. Assign VM using templates

# References
- [Install the Azure Monitor agent (preview)](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/azure-monitor-agent-install?context=%2Fazure%2Fvirtual-machines%2Fcontext%2Fcontext&tabs=ARMAgentPowerShell%2CPowerShellWindows%2CPowerShellWindowsArc%2CCLIWindows%2CCLIWindowsArc)