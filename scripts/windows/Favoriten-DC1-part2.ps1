Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment

$SecureStringPassword = (ConvertTo-SecureString "Ganzgeheim123!" -AsPlainText -Force)

Install-ADDSForest -DomainName "corp.gartenbedarf.com" `
    -DomainMode "WinThreshold" `
    -ForestMode "WinThreshold" `
    -SafeModeAdministratorPassword $SecureStringPassword `
    -InstallDNS `
    -Force

# Sites
New-ADReplicationSite -Name "Favoriten"
New-ADReplicationSite -Name "Langenzersdorf"
New-ADReplicationSite -Name "Kebapci"

New-ADReplicationSubnet -Name "192.168.200.0/24" -Site "Favoriten"
New-ADReplicationSubnet -Name "192.168.210.0/24" -Site "Favoriten"
New-ADReplicationSubnet -Name "192.168.20.0/24" -Site "Favoriten"
New-ADReplicationSubnet -Name "10.10.200.0/24" -Site "Langenzersdorf"
New-ADReplicationSubnet -Name "10.10.20.0/24" -Site "Langenzersdorf"
New-ADReplicationSubnet -Name "172.16.0.0/24" -Site "Kebapci"

New-ADReplicationSiteLink -Name "Favoriten-To-Langenzersdorf" `
    -SitesIncluded ("Favoriten", "Langenzersdorf") `
    -ReplicationFrequencyinMinutes 20

New-ADReplicationSiteLink -Name "Langenzersdorf-To-Kebapci" `
    -SitesIncluded ("Langenzersdorf", "Kebapci") `
    -ReplicationFrequencyinMinutes 20

Move-ADDirectoryServer -Identity "DC1" -Site "Favoriten"
