Rename-Computer DC2

New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 192.168.200.2 -PrefixLength 24 -DefaultGateway 192.168.200.254
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("192.168.200.1")

Enable-PSRemoting
Set-Timezone -Id "W. Europe Standard Time"

Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
Start-Service sshd
Set-Service -Name sshd -StartupType "Automatic"

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Add-Computer -DomainName "corp.gartenbedarf.com" -Restart

$User = "CORP\Administrator" 
$Password = ConvertTo-SecureString -String "ganzgeheim123!" -AsPlainText -Force 
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Password 

Install-ADDSDomainController -DomainName "corp.gartenbedarf.com" -InstallDNS -Credential $Credential -Force

Install-WindowsFeature DHCP -IncludeManagementTools

Add-DnsServerPrimaryZone -NetworkId "172.16.0.0/24" -ReplicationScope "Forest" -DynamicUpdate "Secure"
Add-DnsServerResourceRecordPTR -ZoneName "0.0.16.in-addr.arpa" -Name "172" -PTRDomainName "dc2.corp.gartenbedarf.com"

Add-DhcpServerInDC -DnsName "corp.gartenbedarf.com" -IPAddress 172.16.0.1

Set-DhcpServerv4DnsSetting -ComputerName "dc2.corp.gartenbedarf.com" -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True

Add-DhcpServerv4Scope -name "Lan" -StartRange 192.168.0.10 -EndRange 192.168.0.200 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -OptionID 3 -Value 192.168.0.254 -ScopeID 192.168.0.0
Set-DhcpServerv4OptionValue -DnsDomain "corp.gartenbedarf.com" -DnsServer 172.16.0.1

Add-Dhcpserverv4lease -IPAddress 192.168.0.5 -ScopeId 192.168.0.0 -ClientId "F0-DE-F1-7A-00-5E"

Move-ADDirectoryServer -Identity "DC2" -Site "Wien Favoriten"
Move-ADDirectoryServerOperationMasterRole -Identity "DC2" -OperationMasterRole ?,?,? -Force
