# PKI/IIS
Add-DnsServerResourceRecordCName -Name "pki" `
    -HostnameAlias "web.corp.gartenbedarf.com" `
    -ZoneName "corp.gartenbedarf.com"

New-ADGroup -Name "Web Servers" `
    -SamAccountName "WebServers" `
    -GroupCategory Security `
    -GroupScope Global `
    -DisplayName "Gartenbedarf Web Servers" `
    -Path "CN=Computers,DC=corp,DC=gartenbedarf,DC=com" `
    -Description "All Web-Servers in the domain, used for CA-Templates."
Add-ADGroupMember -Identity "WebServers" -Members $(Get-ADComputer -Identity "WEB")

# Certificate Autoenrollment via MMC (Hölle Nein)

# TODO: Nutzer/Gruppen/GPOs und so
