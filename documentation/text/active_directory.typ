#import "@preview/htl3r-da:1.0.0" as htl3r

#pagebreak(weak: true)
#htl3r.author("Julian Burger")
= Active Directory <ad>
Das AD wurde, bevor es in die GNS-Topology eingefügt wurde mittels "Simulation-Router" aufgezogen. Dies hat es uns ermöglicht schnell und Unabhängig voneinander zu arbeiten. Der "Simulation-Router" mimikt die Netze wie in der echten Topology und Routet zwischen diesen.

== Überblick

Root-Domain: `corp.gartenbedarf.com`

Sonstige Domains: `extern.corp.gartenbedarf.com`

Streckt sich über die Standorte:
- Wien Favoriten
- Langenzersdorf
- Kebapci
wobei beide Root-DCs in Favoriten stehen.

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

Die #htl3r.short[pki] besteht aus einem AD-CS Server und einem IIS-Server. Der IIS-Server stellt die CRLs und zur Verfügung und dient ebenso zum Testen der ausgestellten Zertifikate.

=== NPS

#align(center, table(
  columns: (auto, 1fr, 2fr),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*],
  [#htl3r.short[nps]-Server], [192.168.200.5], [nps.corp.gartenbedarf.com],
))

#pagebreak(weak: true)
=== Workstations

#align(center, table(
  columns: (auto, 1fr, 2fr, auto),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*], [*#htl3r.short[paw]*],
  [Fav-W-Workstation-1], [DHCP, Static Lease 192.168.20.10], [favwork1.corp.gartenbedarf.com], [ X ],
  [Fav-W-Workstation-2], [DHCP], [favwork2.corp.gartenbedarf.com], [  ],
  [Dorf-W-Workstation-1], [DHCP], [dorfwork1.corp.gartenbedarf.com], [  ],
  [Dorf-W-Workstation-2], [DHCP], [dorfwork2.corp.gartenbedarf.com], [  ],
))

Die Fav-W-Workstation-1 ist eine Priviliged Access Workstation (#htl3r.short[paw]), und kann u.a. deswegen folgende besondere Sachen:
- Auf den Jump-Server per RDP und SSH zugreifen

== PowerShell Konfiguration
Alle Domain-Controller wurden grundlegend mittels PowerShell-Scripts konfiguriert. Lediglich GUI-Exclusive Teile wie z.B.: #htl3r.short[nps] und IIS wurde im GUI erledigt. GPOs wurde aus Bequemlichkeitsgründen ebenfalls im GUI konfiguriert. Natürlich kann man sich im Nachhinein die GPOs exportieren und per PowerShell einspielen.

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
    image("../images/ad/lbt_agdlp_v1.png"),
    caption: [AGDLP]
  )
)

Die Domain-Locals finden auf einem DFS share anwendung, welcher zwei Verzeichnise beinhaltet:
- Management
- Sales
Welche Gruppen wie Zugriff haben ist selbsterklärend.

#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/ad/get_ad_user.png"),
    caption: [Alle AD-Benutzer]
  ),
  figure(
    image("../images/ad/get_ad_group.png"),
    caption: [Alle AD-Gruppen]
  )
)

#pagebreak(weak: true)
== PKI
Es wurde eine 1-tier #htl3r.short[pki] aufgesetzt.

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

=== CA Verwendung
Um ein Anwendungsbeispiel für die CA zu haben, wird die Fortigate mit einer Sub-CA versorgt, damit die Clients dem Captive-Portal vertrauen und ebenso SSL-Inspection aktiviert werden kann:

#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/ad/ca_issued.png"),
    caption: [CA ausgestellte Zertifikate]
  ),
  figure(
    image("../images/ad/ca_templates.png"),
    caption: [CA Zertifikatsvorlagen]
  )
)

#pagebreak(weak: true)
=== IIS Konfiguration
Der IIS-Server wurde mittels GUI erstellt und beinhaltet folgende Features:
- Directory Browsing (Nur für CertEnroll-Directory)
- HTTPS (mittels Cert-Template)
- URL-Double-Escaping, notwendig für CA

#htl3r.fspace(
  total-width: 50%,
  figure(
    image("../images/ad/iis_bindings.png"),
    caption: [IIS Bindings]
  )
)
#htl3r.fspace(
  figure(
    image("../images/ad/iis_cert.png"),
    caption: [IIS Zertifikat]
  )
)

#pagebreak(weak: true)
== NPS
#htl3r.short[nps] wurde als Radius-Server für das Captive-Portal verwendet und kann auf alle Domain-User zugreifen. Dadurch kann ein jeder AD-User, um das Internet zu browsen, seinen eigenen Benutzer verwenden. Die Abfragen wurden mittels #htl3r.short[nps]-Policy auf die FortiGate begrenzt und gelten ebenfalls auch nur für das VLAN der Workstations.

#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/ad/nps_clients.png"),
    caption: [NPS Clients]
  ),
  figure(
    image("../images/ad/nps_conditions.png"),
    caption: [NPS Conditions]
  )
)
#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/ad/nps_policies.png"),
    caption: [NPS Policies]
  ),
  figure(
    image("../images/ad/captive_portal.png"),
    caption: [Fortigate Captive-Portal]
  )
)

#pagebreak(weak: true)
== DFS
Es wurde ein DFS angelegt, welches zwei Shares kombiniert:
- Management -> DC1
- Sales -> DC2
Der Kombinierte DFS Share trägt den Namen "Staff" und wird mittels GPO on Logon gemounted. Auf den Verzeichnisen im DFS liegen Permissions nach AGDLP-Konzept.

#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/ad/dfs_mount.png"),
    caption: [DFS Automount]
  ),
  figure(
    image("../images/ad/dfs_directories.png"),
    caption: [DFS Shares]
  )
)

#pagebreak(weak: true)
== GPOs
Im Überblick wurde folgende GPOs angelegt:
#htl3r.fspace(
  total-width: 50%,
  figure(
    image("../images/ad/gpos.png"),
    caption: [GPOs]
  )
)
Man kann erkennen, dass nicht alle GPOs auch Links haben, diese wurden nicht angelegt, da manche der Security-Baseline GPOs inkompatibel mit den VMware-VMs sind und extra Features wie TPMs brauchen. Es wurde probiert VBS zu aktivieren, dies hat jedoch die VMs zerschossen.

Die, mit Abstand, wichtigste GPO ist selbstverständlich der Desktop-Background:
#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/ad/background.png"),
    caption: [Desktop Background GPO]
  )
)
Da es schwierig sein kann diesen in schlechten Lichtverhältnissen zu begutachten, sollte das Bild mit hoher Bildschirmhelligkeit genossen werden.

=== Security Baseline
Natürlich wurde auch die Windows Security Baseline eingespielt. Die dazugehörigen GPOs kann man sich einfach vom Internet ziehen: https://www.microsoft.com/en-us/download/details.aspx?id=55319

Es wurden folgende Baseline GPOs genutzt:
- LGPO
- PolicyAnalyzer
- Windows Server 2022 Security Baseline

#pagebreak(weak: true)
=== LAPS
#htl3r.short[laps] wurde ebenfalls angewand, hiermit werden die Passwörter der Lokalen Administratoren ebenfalls vom AD verwaltet, heruntergeladen werden kann sich der Installer vom Internet: https://www.microsoft.com/en-us/download/details.aspx?id=46899&gt

Auf den DCs wurden die GPOs draufgespielt und auf Computer in einer bestimmte OU namens "#htl3r.short[laps]" angewandt. Diese OU wurde speziell für diesen Zweck erstellt.

Da nur die #htl3r.short[paw] in der #htl3r.short[laps] OU ist, hat auch nur diese ein Admin-PWD welches von #htl3r.short[laps] gemanaged wird:
#htl3r.fspace(
  figure(
    image("../images/ad/laps_pwd.png"),
    caption: [LAPS Passwörter]
  )
)
