Rename-Computer DC1

Rename-NetAdapter -Name "Ethernet0" `
    -NewName "LAN"

New-NetIPAddress -InterfaceAlias "LAN" `
    -IPAddress "192.168.200.1" `
    -PrefixLength 24 `
    -DefaultGateway "192.168.200.254"
Set-DnsClientServerAddress -InterfaceAlias "LAN" `
    -ServerAddresses ("1.1.1.1", "1.0.0.1")

Set-TimeZone -Id "W. Europe Standard Time"
Enable-PSRemoting

Add-WindowsCapability -Online -Name "OpenSSH.Client~~~~0.0.1.0"
Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
Start-Service sshd
Set-Service -Name sshd -StartupType "Automatic"
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
    -Name DefaultShell `
    -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -PropertyType String `
    -Force
Restart-Service sshd

Restart-Computer
