#import "@preview/htl3r-da:0.1.0" as htl3r

#htl3r.author("Julian Burger")
= Active Directory

== Überblick

Root-Domain: corp.gartenbedarf.com 

Sonstige Domains: extern.corp.gartenbedarf.com

Streckt sich über die Standorte Wien Favoriten, Langenzersdorf und Kebapci, wobei beide Root-DCs in Favoriten stehen

== Geräte

=== Domain Controller

#align(center, table(
  columns: 5,
  align: left,
  [*Bezeichnung*], [*IP-Adresse*], [*FQDN*], [*FSMO-Rollen*], [*Read-Only*],
  [DC1], [192.168.200.1], [dc1.corp.gartenbedarf.com], [DNM, PDC], [Nein],
  [DC2], [192.168.200.2], [dc2.corp.gartenbedarf.com], [SM, RIDPM, IM], [Nein],
  [DC3], [10.10.200.3], [dc3.corp.gartenbedarf.com], [-], [Nein],
  [DC-Extern], [10.10.200.1], [dc.extern.corp.gartenbedarf.com], [-], [Nein],
  [RODC], [172.16.0.10], [rodc.extern.crop.gartenbedarf.com], [-], [Ja],
))

- RODC ist Read-Only (duh)
- SSH-Server ist an und PowerShell-Remoting ist erlaubt
- Schicken mittels Windows-Prometheus-Exporter Daten an den Grafana Server in Langenzersdorf
- Root-DCs dienen als NTP-Server

=== Jump Server

#align(center, table(
  columns: 3,
  align: left,
  [*Bezeichnung*], [*IP-Adresse*], [*FQDN*],
  [Jump-Server], [192.168.210.1], [jump.corp.gartenbedarf.com],
))

- Kann per RDP und SSH auf die DCs zugreifen (wird von FW mittels Policies geregelt!)

=== CA, NPS, Web-Server, ...

=== Workstations

#align(center, table(
  columns: 4,
  align: left,
  [*Bezeichnung*], [*IP-Adresse*], [*FQDN*], [*PAW*],
  [Fav-W-Workstation-1], [DHCP, Static Lease 192.168.20.10], [favwork1.corp.gartenbedarf.com], [Ja],
  [Fav-W-Workstation-2], [DHCP], [favwork2.corp.gartenbedarf.com], [Nein],
  [Dorf-W-Workstation-1], [DHCP], [dorfwork1.corp.gartenbedarf.com], [Nein],
  [Dorf-W-Workstation-2], [DHCP], [dorfwork2.corp.gartenbedarf.com], [Nein],
))

- Die Fav-W-Workstation-1 ist eine Priviliged Access Workstation (PAW), und kann u.a. deswegen folgende besondere Sachen:
  - Auf den Jump-Server per RDP und SSH zugreifen

== Users & Computers

AGDLP

OUs

== PKI

1-tier PKI

#align(center, table(
  columns: 3,
  align: left,
  [*Bezeichnung*], [*IP-Adresse*], [*FQDN*],
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
