#Requires -Version 7.0
#Requires -Modules @{ModuleName='Az';ModuleVersion='5.4.0'},@{ModuleName='Az.ConnectedMachine';ModuleVersion='0.2.0'}

$VMs = 'emreg-web01','emreg-web02'
$ArcEnabledServers = @('web03','web04')
$ResourceGroupName = 'ContosoAll'
$SubscriptionID = 'c02646f3-6401-40c7-8543-69333821da9a'

# Add  Vms[0]

# Get Extension List for the VMs
$VMs | ForEach-Object {Get-AzVMExtension -VMName $_ -ResourceGroupName $ResourceGroupName | Select-Object -Property VMName,Name,ProvisioningState,Statuses}

# Get Extension List for Arc Servers
$ArcEnabledServers | ForEach-Object {$MachineName = $_ ;Get-AzConnectedMachineExtension -MachineName $_ -ResourceGroupName $ResourceGroupName -PipelineVariable $ExtensionInfo | Select-Object -Property @{Name='MachineName';Expression={$MachineName}},Name,ProvisioningState}

# Install The Extension Using Powershell for VMs
Set-AzVMExtension -Name AMAWindows -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName <resource-group-name> -VMName <virtual-machine-name> -Location 'Eastus'

# Install The Extension Using Powershell for Azure Arc Enabled Servers
New-AzConnectedMachineExtension -Name AMAWindows -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $ResourceGroupName -MachineName $ArcEnabledServers[0] -Location 'Eastus'

# Create DCR Assoication using Powershell
$dcr = Get-AzDataCollectionRule -ResourceGroupName $rg -RuleName $dcrName
$vmId = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachines/$($VMs[1])"
$ArcEnabledServerID = "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.hybridcompute/virtualMachines/$($ArcEnabledServers[0])"
$dcr | New-AzDataCollectionRuleAssociation -TargetResourceId $ArcEnabledServerID  -AssociationName "dcrAssocInput"
