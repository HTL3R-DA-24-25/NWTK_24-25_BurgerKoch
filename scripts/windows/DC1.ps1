Rename-Computer DC1

New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 192.168.200.1 -PrefixLength 24 -DefaultGateway 192.168.200.254
#Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("10.10.100.12")

Enable-PSRemoting
Set-Timezone -Id "W. Europe Standard Time"

Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
Start-Service sshd
Set-Service -Name sshd -StartupType "Automatic"

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment

Install-ADDSForest -DomainName "corp.gartenbedarf.com" -DomainMode "WinThreshold" -ForestMode "WinThreshold" -InstallDNS -Force

# Passwörter eingeben
# FIX THIS

Install-WindowsFeature DHCP -IncludeManagementTools

Add-DnsServerPrimaryZone -NetworkId "172.16.0.0/24" -ReplicationScope "Forest" -DynamicUpdate "Secure"
Add-DnsServerResourceRecordPTR -ZoneName "0.0.16.in-addr.arpa" -Name "172" -PTRDomainName "dc1.corp.gartenbedarf.com"

Add-DhcpServerInDC -DnsName "dc1.corp.gartenbedarf.com" -IPAddress "???"

Set-DhcpServerv4DnsSetting -ComputerName "dc1.corp.gartenbedarf.com" -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True

Add-DhcpServerv4Scope -name "Lan" -StartRange 192.168.0.10 -EndRange 192.168.0.200 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -OptionID 3 -Value 192.168.0.254 -ScopeID 192.168.0.0
Set-DhcpServerv4OptionValue -DnsDomain "corp.gartenbedarf.com" -DnsServer 172.16.0.1

Add-Dhcpserverv4lease -IPAddress 192.168.0.5 -ScopeId 192.168.0.0 -ClientId "F0-DE-F1-7A-00-5E"

netsh dhcp add securitygroups
Restart-Service dhcpserver

$outer = "Tech", "Sales", "Marketing", "Management"
$inner = "Accounts", "Ressources"

foreach ($currentOuter in $outer){
	New-ADOrganizationalUnit -Name $currentOuter -Path "DC=fenrir-it, DC=at"
	foreach ($currentInner in $inner){
		New-ADOrganizationalUnit -Name $currentInner -Path "OU=$($currentOuter),DC=fenrir-it, DC=at"
	}
}


Import-Module ActiveDirectory

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/HTL3R-DA-24-25/NWTK_24-25_BurgerKoch/refs/heads/main/scripts/windows/groups.csv" -Outfile "C:\Windows\Temp\groups.csv"
$groups = Import-Csv -Path "C:\Windows\Temp\groups.csv"

foreach ($group in $groups) {
    New-ADGroup -Name $group.name -Path $group.path -GroupScope $group.scope -GroupCategory $group.category
}

<#
Add-ADGroupMember -Identity DL_Sales_R -Members G_Management
Add-ADGroupMember -Identity DL_Sales_M -Members G_Sales
Add-ADGroupMember -Identity DL_Marketing_R -Members G_Management
Add-ADGroupMember -Identity DL_Marketing_M -Members G_Marketing
Add-ADGroupMember -Identity DL_Tech_R -Members G_Management
Add-ADGroupMember -Identity DL_Tech_M -Members G_Tech
Add-ADGroupMember -Identity DL_Management_R -Members G_Sales
Add-ADGroupMember -Identity DL_Management_M -Members G_Management
Add-ADGroupMember -Identity DL_Templates_R -Members G_Sales, G_Marketing, G_Tech
Add-ADGroupMember -Identity DL_Templates_M -Members G_Management
#>

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/HTL3R-DA-24-25/NWTK_24-25_BurgerKoch/refs/heads/main/scripts/windows/users.csv" -Outfile "C:\Windows\Temp\users.csv"
$users = Import-Csv -Path "C:\Windows\Temp\users.csv"

# Iterate over each user and create them in the specified OU
foreach ($user in $users) {
    $username = $user.Username
    $fullName = $user.FullName
    $ou = $user.OU
    $department = $user.Department
    if ($department -eq "Administrators") {
        $groupName = $department
    }else{
        $groupName = "G_$department"
    }
    # Create the user
    New-ADUser `
        -SamAccountName $username `
        -UserPrincipalName "$username@corp.gartenbedarf.com" `
        -Name $fullName `
        -GivenName ($fullName.Split(" ")[0]) `
        -Surname ($fullName.Split(" ")[1]) `
        -DisplayName $fullName `
        -Path $ou `
        -AccountPassword (ConvertTo-SecureString "ganzgeheim123!" -AsPlainText -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $false


    if ($department) {
        Add-ADGroupMember -Identity $groupName -Members $username
        Write-Host "Added user $username to group $groupName"
    }else {
        Write-Host "No department specified for user: $username"
        continue
    }
}


New-ADReplicationSite -Name "Wien Favoriten"
New-ADReplicationSite -Name "Langenzersdorf"
New-ADReplicationSite -Name "Kebapci"
New-ADReplicationSubnet -Name "192.168.200.0/24" -Site "Wien Favoriten"
New-ADReplicationSubnet -Name "10.10.20.0/24" -Site "Langenzersdorf"
New-ADReplicationSubnet -Name "172.16.0.0/24" -Site "Kebapci"

New-ADReplicationSiteLink -Name "Wien-Langenzersdorf-Link" -SitesIncluded "Wien Favoriten","Langenzersdorf" -ReplicationFrequencyinMinutes 20
New-ADReplicationSiteLink -Name "Wien-Kebapci-Link" -SitesIncluded "Wien Favoriten","Kebapci" -ReplicationFrequencyinMinutes 20

Move-ADDirectoryServer -Identity "DC1" -Site "Wien Favoriten"


New-GPO -Name "PasswordGuideline" -Comment "Kennwortrichtlinien für alle Systeme"
Set-GPRegistryValue -Name "PasswordGuideline" -Key "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -ValueName "MinimumPasswordLength" -Value 8 -Type DWord
New-GPLink -Name "PasswordGuideline" -Target "DC=intern,DC=htl3r-testlab,DC=at" -LinkEnabled Yes -Enforced Yes



Import-Module GroupPolicy

$gpoNameHomeDirectory = "Set Home Directory"
$gpoNameMountFileShare = "Mount File Share"
$gpoNameBackground = "Set Desktop Background"

$fileSharePath = "\\dc2\Shares"
$homeDirectoryPath = "\\dc2\homedirs\%username%"
$backgroundImagePath = "\\dc2\wallpapers\background.jpg"
$fileShareDriveLetter = "F:"
$fileShareLabel = "Share"
$fileSharePersistent = 1

# 1. Set the home directory for any user to a file share

$gpoHomeDirectory = Get-GPO -Name $gpoNameHomeDirectory -ErrorAction SilentlyContinue
if (-not $gpoHomeDirectory) {
    $gpoHomeDirectory = New-GPO -Name $gpoNameHomeDirectory
}

Set-GPRegistryValue -Name $gpoNameHomeDirectory -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ValueName "HomeDirectory" -Type String -Value $homeDirectoryPath

# 2. Automatically mount a file share

$gpo = Get-GPO -Name $gpoNameMountFileShare -ErrorAction SilentlyContinue
if (-not $gpo) {
    $gpo = New-GPO -Name $gpoNameMountFileShare
}

$keyPath = "HKCU\Network\$fileShareDriveLetter"

Set-GPRegistryValue -Name $gpoNameMountFileShare -Key $keyPath -ValueName "RemotePath" -Type String -Value $fileSharePath

Set-GPRegistryValue -Name $gpoNameMountFileShare -Key $keyPath -ValueName "DeferFlags" -Type DWord -Value $fileSharePersistent

Set-GPRegistryValue -Name $gpoNameMountFileShare -Key $keyPath -ValueName "UserName" -Type String -Value ""
Set-GPRegistryValue -Name $gpoNameMountFileShare -Key $keyPath -ValueName "ProviderName" -Type String -Value $fileShareLabel


# 3. Change the background for every user

$gpoBackground = Get-GPO -Name $gpoNameBackground -ErrorAction SilentlyContinue
if (-not $gpoBackground) {
    $gpoBackground = New-GPO -Name $gpoNameBackground
}

Set-GPRegistryValue -Name $gpoNameBackground -Key "HKCU\Control Panel\Desktop" -ValueName "Wallpaper" -Type String -Value $backgroundImagePath
Set-GPRegistryValue -Name $gpoNameBackground -Key "HKCU\Control Panel\Desktop" -ValueName "WallpaperStyle" -Type String -Value "2"  # Set to 2 for stretched wallpaper

$ouPath = "OU=Users,DC=corp,DC=gartenbedarf,DC=com"

# Link GPOs to the domain or specific OU
New-GPLink -Name $gpoNameHomeDirectory -Target $ouPath
New-GPLink -Name $gpoNameMountFileShare -Target $ouPath
New-GPLink -Name $gpoNameBackground -Target $ouPath
