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


# Get Data Collection Rule Objects
$DCR = Get-AzDataCollectionRule -RuleName $DCRName -ResourceGroupName 'ContosoEu'

# Remove Associations, Unfortunately pipeline isnt working properly with Inputobject
$DCRAssociations = $DCR | Get-AzDataCollectionRuleAssociation
$DCRAssociations.Id | ForEach-Object {Remove-AzDataCollectionRuleAssociation -AssociationId $_}

# Remove DCR
$DCR | Remove-AzDataCollectionRule

# Uninstall Extensions for Arc Servers
$ArcEnabledServerExtensions = $ArcEnabledServers | ForEach-Object {Get-AzConnectedMachineExtension -MachineName $_ -ResourceGroupName  $ResourceGroupName -Name AzureMonitorWindowsAgent } 
$ArcEnabledServerExtensions  | Remove-AzConnectedMachineExtension

# Uninstall Extensions for VMs
$VMExtensions = $VMs | ForEach-Object {Get-AzVMExtension -VMName $_ -ResourceGroupName $ResourceGroupName}
$VMExtensions | remove-azvmExtension