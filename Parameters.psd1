@{
    VMs = @('emreg-web01','emreg-web02')
    ArcEnabledServers = @('web03','web04')
    ResourceGroupName = 'ContosoAll'
    Location = 'EastUs'
    SubscriptionID = 'c02646f3-6401-40c7-8543-69333821da9a'
    DCRName = 'DCR_EventLogs'
    WorkspaceName = 'Spark21ws1'
}