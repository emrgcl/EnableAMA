#Requires -Version 7.0
#Requires -Modules @{ModuleName='Az';ModuleVersion='5.4.0'},@{ModuleName='Az.ConnectedMachine';ModuleVersion='0.2.0'}

$ParametersFile = './Parameters.psd1'
$Parameters=Import-PowerShellDataFile -Path $ParametersFile
$VMs = $Parameters.VMs
$ArcEnabledServers = $Parameters.ArcEnabledServers
$ResourceGroupName = $Parameters.ResourceGroupName
$SubscriptionID = $Parameters.SubscriptionID
$DCRName = $Parameters.DCRName
$Location = $Parameters.Location

# create a data collection rule Named in Variable $DCRName in the portal and associate with VM1

# Get Extension List for the VMs and verify the extension is installed
$VMs | ForEach-Object {Get-AzVMExtension -VMName $_ -ResourceGroupName $ResourceGroupName | Select-Object -Property VMName,Name,ProvisioningState}

# Check extensions in portal and add ArcEnabledServer1 to to assoication in the portal

# Get Extension List for Arc Servers
$ArcEnabledServers | ForEach-Object {$MachineName = $_ ;Get-AzConnectedMachineExtension -MachineName $_ -ResourceGroupName $ResourceGroupName -PipelineVariable $ExtensionInfo | Select-Object -Property @{Name='MachineName';Expression={$MachineName}},Name,ProvisioningState}

# Time for a take 100 in Workspace in the portal

# Install The Extension Using Powershell for VMs
Set-AzVMExtension -Name AMAWindows -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $ResourceGroupName -VMName $VMs[1] -Location $Location  -TypeHandlerVersion 1.0

# Install The Extension Using Powershell for Azure Arc Enabled Servers
New-AzConnectedMachineExtension -Name AMAWindows -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $ResourceGroupName -MachineName $ArcEnabledServers[1] -Location $Location -TypeHandlerVersion 1.0

# Reuse the above Powershell cmdlets to list extensions for the servers added.

# Create DCR Association using Powershell
$dcr = Get-AzDataCollectionRule -ResourceGroupName $ResourceGroupName -RuleName $dcrName
$vmId = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachines/$($VMs[1])"
$ArcEnabledServerID = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.HybridCompute/Machines/$($ArcEnabledServers[1])"
$dcr | New-AzDataCollectionRuleAssociation -TargetResourceId $ArcEnabledServerID  -AssociationName "PowerShellBasedAssocArc"
$dcr | New-AzDataCollectionRuleAssociation -TargetResourceId $VMID -AssociationName "PowerShellBasedAssocVM"
