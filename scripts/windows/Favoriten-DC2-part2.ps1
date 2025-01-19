Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment

$SecureStringPassword = (ConvertTo-SecureString "Ganzgeheim123!" -AsPlainText -Force)
$DomainAdministratorCredentials = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList ("Administrator@corp.gartenbedarf.com", $SecureStringPassword)

Install-ADDSDomainController -DomainName "corp.gartenbedarf.com" `
    -SafeModeAdministratorPassword $SecureStringPassword `
    -Credential $DomainAdministratorCredentials `
    -SiteName "Favoriten" `
    -InstallDNS
