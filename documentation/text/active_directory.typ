#import "@preview/htl3r-da:1.0.0" as htl3r

#htl3r.author("Julian Burger")
= Active Directory

== Überblick

Root-Domain: corp.gartenbedarf.com

Sonstige Domains: extern.corp.gartenbedarf.com

Streckt sich über die Standorte Wien Favoriten, Langenzersdorf und Kebapci, wobei beide Root-DCs in Favoriten stehen

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

- RODC ist Read-Only (duh)
- SSH-Server ist an und PowerShell-Remoting ist erlaubt
- Schicken mittels Windows-Prometheus-Exporter Daten an den Grafana Server in Langenzersdorf
- Root-DCs dienen als NTP-Server

=== Jump Server

#align(center, table(
  columns: (auto, 1fr, 2fr),
  align: left,
  [*Name*], [*IP-Adresse*], [*FQDN*],
  [Jump-Server], [192.168.210.1], [jump.corp.gartenbedarf.com],
))

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

== Users & Computers

#align(center, table(
  columns: (auto, auto, auto, 1fr),
  align: left,
  [*Name*], [*Logon*], [*Password*], [*Groups*],
  [Alex Taub], [ataub], [Ganzgeheim123!], [],
  [Jonas Wagner], [jwagner], [Ganzgeheim123!], [],
  [Sabine Rauch], [srauch], [Ganzgeheim123!], [],
  [Thomas Koch], [tkoch], [Ganzgeheim123!], [],
))

OUs

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

== NPS

== IPAM

== GPOs

- Desktophintergrund setzen und Veränderung verbieten
- Loginscreen setzen (?)
- Last logged in User nicht anzeigen
- Mount Drive
- PWD Security-Richtlinie
- Removable Media verbieten
- Registry-Zugriff einschränken
- PKI-Zertifikate automatisch enrollen
