# Issues Found

## Cmdlet Issues

Remove-AzDataCollectionRule Association throws an excepation when DCR object is piped.

```PowerShell

# Get Data Collection Rule Objects
$DCR = Get-AzDataCollectionRule -RuleName $DCRName -ResourceGroupName 'ContosoEu'

# Remove Associations
$DCR | Remove-AzDataCollectionRuleAssociation

```
Error Thrown;
```
PS C:\Repos\EnableAMA> $DCR | Remove-AzDataCollectionRuleAssociation
Remove-AzDataCollectionRuleAssociation: The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input.

PS C:\Repos\EnableAMA> $DCR | gm

TypeName: Microsoft.Azure.Commands.Insights.OutputClasses.PSDataCollectionRuleResource
```