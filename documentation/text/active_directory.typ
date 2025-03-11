#import "@preview/htl3r-da:1.0.0" as htl3r

#htl3r.author("Julian Burger")
= Active Directory

== Überblick

Root-Domain: `corp.gartenbedarf.com`

Sonstige Domains: `extern.corp.gartenbedarf.com`

Streckt sich über die Standorte Wien Favoriten, Langenzersdorf und Kebapci, wobei beide Root-DCs in Favoriten stehen.

== Geräte

=== Domain Controller

#align(center, table(
  columns: (2fr, auto, 5fr, 3fr, auto),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*], [*FSMO-Rollen*], [*RO*],
  [DC1], [192.168.200.1], [dc1.corp.gartenbedarf.com], [DNM, PDC], [ ],
  [DC2], [192.168.200.2], [dc2.corp.gartenbedarf.com], [SM, RIDPM, IM], [ ],
  [DC3], [10.10.200.3], [dc3.corp.gartenbedarf.com], [-], [ ],
  [DC-Extern], [10.10.200.1], [dc.extern.corp.gartenbedarf.com], [-], [ ],
  [RODC], [172.16.0.10], [rodc.extern.crop.gartenbedarf.com], [-], [ X ],
))

- RODC ist Read-Only
- SSH-Server ist an und PowerShell-Remoting ist erlaubt
- Schicken mittels Windows-Prometheus-Exporter Daten an den Grafana Server in Langenzersdorf
- Root-DCs dienen als NTP-Server

=== Jump Server
#align(center, block(breakable: false, table(
  columns: (auto, 1fr, 2fr),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*],
  [Jump-Server], [192.168.210.1], [jump.corp.gartenbedarf.com],
)))

- Kann per RDP und SSH auf die DCs zugreifen (wird von FW mittels Policies geregelt!)

=== CA + PKI

#align(center, table(
  columns: (auto, 1fr, 2fr),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*],
  [Certificate Authority], [192.168.200.10], [ca.corp.gartenbedarf.com],
  [IIS-Server], [192.168.200.100], [web.corp.gartenbedarf.com],
))

Die PKI besteht aus einem AD-CS Server und einem IIS-Server. Der IIS-Server stellt die CRLs und zur Verfügung und dient ebenso zum Testen der ausgestellten Zertifikate.

=== NPS

#align(center, table(
  columns: (auto, 1fr, 2fr),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*],
  [NPS-Server], [192.168.200.5], [nps.corp.gartenbedarf.com],
))

=== Workstations

#align(center, table(
  columns: (auto, 1fr, 2fr, auto),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*], [*PAW*],
  [Fav-W-Workstation-1], [DHCP, Static Lease 192.168.20.10], [favwork1.corp.gartenbedarf.com], [ X ],
  [Fav-W-Workstation-2], [DHCP], [favwork2.corp.gartenbedarf.com], [  ],
  [Dorf-W-Workstation-1], [DHCP], [dorfwork1.corp.gartenbedarf.com], [  ],
  [Dorf-W-Workstation-2], [DHCP], [dorfwork2.corp.gartenbedarf.com], [  ],
))

- Die Fav-W-Workstation-1 ist eine Priviliged Access Workstation (PAW), und kann u.a. deswegen folgende besondere Sachen:
  - Auf den Jump-Server per RDP und SSH zugreifen

== PowerShell Konfiguration
Alle Domain-Controller wurden grundlegend mittels PowerShell-Scripts konfiguriert. Lediglich GUI-Exclusive Teile wie z.B.: NPS und IIS wurde im GUI erledigt. GPOs wurde aus Bequemlichkeitsgründen ebenfalls im GUI konfiguriert. Natürlich kann man sich im Nachhinein die GPOs exportieren und per PowerShell einspielen.

Die Grundkonfiguration sieht hierbei wiefolgt aus:
#htl3r.code-file(
  caption: "DC1 Grundkonfiguration",
  filename: [scripts/windows/Favoriten-DC1-part1.ps1],
  lang: "powershell",
  text: read("../../scripts/windows/Favoriten-DC1-part1.ps1")
)
Diese Konfiguration ist sieht auf allen DCs fast gleich aus.

Als nächstes wird ein Forest auf DC1 erstellt und die Replication-Sites angelegt:
#htl3r.code-file(
  caption: "DC1 erweiterte Konfiguration",
  filename: [scripts/windows/Favoriten-DC1-part2.ps1],
  range: (0, 33),
  lang: "powershell",
  text: read("../../scripts/windows/Favoriten-DC1-part2.ps1")
)

Natürlich ist auf allen DCs Win-RM aktiviert um diese mittels Jump-Server administrieren zu können:
#htl3r.code-file(
  caption: "Win-RM Konfiguration",
  filename: [scripts/windows/Favoriten-DC1-part2.ps1],
  range: (35, 40),
  lang: "powershell",
  text: read("../../scripts/windows/Favoriten-DC1-part2.ps1")
)

== Users & Computers
Innerhalb des ADs existieren folgende Benutzer:
#align(center, table(
  columns: (auto, auto, auto, 1fr),
  align: left,
  [*Name*], [*Logon*], [*Password*], [*Groups*],
  [Alex Taub], [ataub], [Ganzgeheim123!], [Sales],
  [Jonas Wagner], [jwagner], [Ganzgeheim123!], [Sales],
  [Sabine Rauch], [srauch], [Ganzgeheim123!], [Management],
  [Thomas Koch], [tkoch], [Ganzgeheim123!], [Sales],
))

Die Gruppen sind dann Weiter nach AGDLP wiefolgt unterteilt:
#htl3r.fspace(
  figure(
    image("../../images/ad/lbt_agdlp_v1.png"),
    caption: [AGDLP]
  )
)

Die Domain-Locals finden auf einem DFS share anwendung, welcher zwei Verzeichnise beinhaltet:
- Management
- Sales
Welche Gruppen wie Zugriff haben ist selbsterklärend.

== PKI

1-tier PKI

#align(center, table(
  columns: (auto, 1fr, 2fr),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*],
  [CA], [192.168.200.10], [ca.corp.gartenbedarf.com],
))

Autoenrollment der Zertifikate per GPO für:
- Clients
- VPN
Natürlich dazu auch passende Templates, sowie templates für Sub-CA (notwendig fürs Captive-Portal) und IIS.

=== CA Konfiguration
Die CA wurde ausschließlich mit der PowerShell aufgesetzt:
#htl3r.code-file(
  caption: "CA Konfiguration und Setup",
  filename: [scripts/windows/Favoriten-CA-part2.ps1],
  lang: "powershell",
  text: read("../../scripts/windows/Favoriten-CA-part2.ps1")
)

=== IIS Konfiguration
Der IIS-Server wurde mittels GUI erstellt und beinhaltet folgende Features:
- Directory Browsing (Nur für CertEnroll-Directory)
- HTTPS (mittels Cert-Template)
- URL-Double-Escaping, notwendig für CA

== NPS
NPS wurde als Radius-Server für das Captive-Portal verwendet und kann auf alle Domain-User zugreifen. Dadurch kann ein jeder AD-User, um das Internet zu browsen, seinen eigenen Benutzer verwenden. Die Abfragen wurden mittels NPS-Policy auf die FortiGate begrenzt und gelten ebenfalls auch nur für das VLAN der Workstations.

== DFS
Es wurde ein DFS angelegt, welches zwei Shares kombiniert:
- Management -> DC1
- Sales -> DC2
Der Kombinierte DFS Share trägt den Namen "Staff" und wird mittels GPO on Logon gemounted. Auf den Verzeichnisen im DFS liegen Permissions nach AGDLP-Konzept.

== GPOs

- Desktophintergrund setzen und Veränderung verbieten
- Last logged in User nicht anzeigen
- Mount Drive
- PWD Security-Richtlinie
- Removable Media verbieten
- Registry-Zugriff einschränken
- PKI-Zertifikate automatisch enrollen

=== Security Baseline
Natürlich wurde auch die Windows Security Baseline eingespielt. Die dazugehörigen GPOs kann man sich einfach vom Internet ziehen: https://www.microsoft.com/en-us/download/details.aspx?id=55319

TODO: Heruntergeladene Objekte auflisten

=== LAPS
LAPS wurde ebenfalls angewand, hiermit werden die Passwörter der Lokalen Administratoren ebenfalls vom AD verwaltet, heruntergeladen werden kann sich der Installer vom Internet: https://www.microsoft.com/en-us/download/details.aspx?id=46899&gt

Auf den DCs wurden die GPOs draufgespielt und auf Computer in einer bestimmte OU namens "LAPS" angewandt. Diese OU wurde speziell für diesen Zweck erstellt.
