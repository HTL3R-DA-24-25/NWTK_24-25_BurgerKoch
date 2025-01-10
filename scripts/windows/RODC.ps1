Rename-Computer RODC

New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 172.16.0.10 -PrefixLength 24 -DefaultGateway 172.16.0.254
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("192.168.200.1", "192.168.200.2")

Enable-PSRemoting
Set-Timezone -Id "W. Europe Standard Time"

Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
Start-Service sshd
Set-Service -Name sshd -StartupType "Automatic"

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

$User = "CORP\Administrator" 
$Password = ConvertTo-SecureString -String "ganzgeheim123!" -AsPlainText -Force 
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Password 

Install-ADDSDomainController -Credential $Credential -ReadOnlyReplica -DomainName "extern.corp.gartenbedarf.com" -SiteName "Kebapci" -ReplicationSourceDC "DC-Extern.extern.corp.gartenbedarf.com" -Force 
