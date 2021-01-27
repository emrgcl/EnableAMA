#Requires -Version 7.0
#Requires -Modules @{ModuleName='Az';ModuleVersion='5.4.0'},@{ModuleName='Az.ConnectedMachine';ModuleVersion='0.2.0'}

$VMs = 'emreg-web01','emreg-web02'
$ArcEnabledServers = @('web03')
$ResourceGroupName = 'ContosoAll'
$SubscriptionID = 'c02646f3-6401-40c7-8543-69333821da9a'
$DCRName = 'CollectTest'


# Get Data Collection Rule Objects
$DCR = Get-AzDataCollectionRule -RuleName $DCRName -ResourceGroupName 'ContosoEu'

# Remove Associations, Unfortunately pipeline isnt working properly with Inputobject
$DCRAssociations = $DCR | Get-AzDataCollectionRuleAssociation
$DCRAssociations.Id | ForEach-Object {Remove-AzDataCollectionRuleAssociation -AssociationId $_}

# Remove DCR
$DCR | Remove-AzDataCollectionRule

# Uninstall Extensions for Arc Servers
$ArcEnabledServerObjects = $ArcEnabledServers | ForEach-Object {Get-AzConnectedMachine -ResourceGroupName $ResourceGroupName -Name $_} 
$ArcEnabledServerObjects | Remove-AzConnectedMachineExtension

# Uninstall Extensions for VMs