$ParametersFile = './Parameters.psd1'
$Parameters=Import-PowerShellDataFile -Path $ParametersFile

$ResourceGroupName = $Parameters.ResourceGroupName
$Location = $Parameters.Location
$WorkSpaceName = $Parameters.WorkspaceName

# Create the resource group if needed
try {
    Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
} catch {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

# Create the workspace
New-AzOperationalInsightsWorkspace -Location $Location -Name $WorkspaceName -Sku Standard -ResourceGroupName $ResourceGroupName