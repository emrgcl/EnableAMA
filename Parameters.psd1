@{
    VMs = @('vm1','vm2')
    ArcEnabledServers = @('arcenabled1','arcenabled1')
    ResourceGroupName = 'ContosoAll'
    Location = 'EastUs'
    SubscriptionID = 'xxxxx-xxxx-xxx-xxx-xxxxx'
    DCRName = 'DCR_EventLogs_Filtered'
    WorkspaceName = 'EventLogWorkspace'
}

# Xpath Filtering
# System!*[System[EventID=7036 and Provider[@Name='Service Control Manager']] and EventData[Data[@Name='param1']='Print Spooler']]

