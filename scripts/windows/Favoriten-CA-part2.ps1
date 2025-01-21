$SecureStringPassword = (ConvertTo-SecureString "Ganzgeheim123!" -AsPlainText -Force)
$DomainAdministratorCredentials = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList ("Administrator@corp.gartenbedarf.com", $SecureStringPassword)

Add-Computer -DomainName "corp.gartenbedarf.com" `
    -Credential $DomainAdministratorCredentials `
    -Restart

$CAPolicyContent = @"
[Version]
Signature="$Windows NT$"
[PolicyStatementExtension]
Policies=InternalPolicy
[InternalPolicy]
OID= 1.2.3.4.1455.67.89.5
Notice="Legal Policy Statement"
URL=http://pki.corp.5cn.at/cps.txt
[Certsrv_Server]
RenewalKeyLength=2048
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=10
LoadDefaultTemplates=0
AlternateSignatureAlgorithm=1
"@
$CAPolicyContent > C:\Windows\CAPolicy.inf

Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority -CAType EnterpriseRootCa `
    -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
    -KeyLength 2048 `
    -HashAlgorithmName SHA256 `
    -CACommonName "Gartenbedarf Root CA" `
    -CADistinguishedNameSuffix "DC=corp,DC=gartenbedarf,DC=com" `
    -ValidityPeriod Years `
    -ValidityPeriodUnits 10
Certutil -setreg CA\CRLPeriodUnits 1
Certutil -setreg CA\CRLPeriod "Weeks"
Certutil -setreg CA\CRLDeltaPeriodUnits 1
Certutil -setreg CA\CRLDeltaPeriod "Days"
Certutil -setreg CA\CRLOverlapPeriodUnits 12
Certutil -setreg CA\CRLOverlapPeriod "Hours"
Certutil -setreg CA\ValidityPeriodUnits 5
Certutil -setreg CA\ValidityPeriod "Years"
Certutil -setreg CA\AuditFilter 127

Certutil -setreg CA\CACertPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11\n2:http://pki.corp.gartenbedarf.com/CertEnroll/%1_%3%4.crt"
Certutil -setreg CA\CRLPublicationURLs "65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl\n79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10\n6:http://pki.corp.gartenbedarf.com/CertEnroll/%3%8%9.crl\n65:file://\\WEB.corp.gartenbedarf.com\CertEnroll\%3%8%9.crl"

Copy-Item -Path 'C:\Windows\System32\CertSrv\CertEnroll\CA.corp.gartenbedarf.com_Gartenbedarf Root CA.crt' `
    -Destination '\\WEB.corp.gartenbedarf.com\C$\CertEnroll'

New-NetFirewallRule -DisplayName "WinRM HTTPS" `
    -Direction Inbound `
    -LocalPort 5985 `
    -Protocol TCP `
    -Action Allow `
    -RemoteAddress "192.168.210.1"

Restart-Computer
