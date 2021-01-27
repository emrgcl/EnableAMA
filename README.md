# Enable Hybrid Cloud monitoring with the new Azure Monitoring Agent (AMA)

# Scenario

Contoso has an application which has 4 web servers. 2 of them are azure VMS and 2 of them are On-Premises web Servers with Azure arc enabled.

There is a set of perforamance data to be collected for all servers and for only Azure Arc Enabled servers those are on premises Application and System event logs.

Two Data collection rules needed one per all servers without Secuity eventd and one with the Secuity events assoicated with the VMs.

# Overview

Data Collection Rules can be assoicated with Azure VMs or Arc Enabled Servers. Creating data collection rule and assoicating the resources are two seperate proceses but the portal experience combines these two operations.

Installing the agent is as easy as deploying an extension to an AzureVM or Azure Arc Enabled Server but this is not necesssary because the associated resoruces will pull and install the extension automatically once assoication is added on the data collection rule.

Data collection rules can be created via Json template or again through portal expereince. 


# Requirements
- Two hyperv guests with Azure arc for servers enabled and connected
- Two Azure Virtual Machines with system-assigned managed identity
- Az.Powershlell 5.4.0 (Requirement for DCR Cmdlets)
- Az.ConnectedMachine 0.2.0
- Powershell 7.0.4 (Version 7 for best practice)
- VSCode Insiders


# Demo 1 - Create Data Collection On the Portal and use various assoication options.

PowerShell Cmdlets for each step below can be found in ***.\Demo-1.ps1***

1. Create a Data Collection Rule Named 'Default Collection' with Perf Counters and Application and System Events except Security events and assoicate with *VM1*
1. Check if the extension is installed automatically using PowerShell
1. Now add Azure *ArcEnabledServer1* to the assoication
1. Check if the extension is installed automatically using PowerShell
1. Do a Perf | Take 100 query in the workspace and note the data is collected.
    > **Note:** At this point we have 2 servers assoicated with 'Default Collection'.
1. Install the extension using Powershell manually on *VM2*
1. Install the extension using Powershell manually on *ArcEnabledServer2*
1. Check if the extensions are installed manually on the second portion of the servers using powershell
    > **Note:** Please note we installed the extensions but not yet assoicated with the data collection rule.
1. Add VM2 association using the portal
1. Add ArcEnabledServer2 assocations using Powershell
    > **Note:** Now we have all 4 servers associated with the 'Default Collection Rule'

# Demo 2 - Create SecurityEvent Collection rule using Json template and asscoicate Azure VMs only

# References
- [Install the Azure Monitor agent (preview)](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/azure-monitor-agent-install?context=%2Fazure%2Fvirtual-machines%2Fcontext%2Fcontext&tabs=ARMAgentPowerShell%2CPowerShellWindows%2CPowerShellWindowsArc%2CCLIWindows%2CCLIWindowsArc)