Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment

$SecureStringPassword = (ConvertTo-SecureString "Ganzgeheim123!" -AsPlainText -Force)
$DomainAdministratorCredentials = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList ("Administrator@corp.gartenbedarf.com", $SecureStringPassword)

Install-ADDSDomain -NewDomainName "extern" `
    -ParentDomainName "corp.gartenbedarf.com" `
    -Credential $DomainAdministratorCredentials `
    -SafeModeAdministratorPassword $SecureStringPassword `
    -SiteName "Langenzersdorf" `
    -InstallDns

Move-ADDirectoryServer -Identity "ExternDC" -Site "Langenzersdorf"
