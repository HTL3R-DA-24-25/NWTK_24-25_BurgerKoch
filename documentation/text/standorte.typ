#import "@preview/htl3r-da:1.0.0" as htl3r

= Standorte <standorte>

== Wien Favoriten

Wien Favoriten ist der Hauptstandort der Gartenbedarfs GmbH und somit auch der größte in der gesamten Topologie.

#htl3r.fspace(
  total-width: 60%,
  figure(
    image("../images/topology/standorte/favoriten.png"),
    caption: [Der Standort Wien Favoriten]
  )
)

Der private Adressbereich an diesem Standort entspricht dem Subnetz 192.168.xx.0/24.

xx = VLAN-ID, falls das Gerät keinem spezifischen VLAN zugewiesen ist, dann ist xx = 0

=== VLANs

#align(center, table(
  columns: 2,
  align: left,
  [*ID*], [*Bezeichnung*],
  [20], [Windows Clients], 
  [30], [Switch Management], 
  [31], [Switch R-SPAN Mirroring], 
  [42], [VoIP-Geräte], 
  [100], [Ubuntu Server (ohne Bastion)], 
  [150], [Bastion], 
  [200], [Windows Server], 
  [210], [Jump Server], 
  [666], [Blackhole], 
))

=== Geräte

- 2x FortiGate
  - Fav-FW-1 (192.168.xx.254)
  - Fav-FW-2 (192.168.xx.253)
- 4x L3-Switch
  - Fav-Core-1 (192.168.30.1)
  - Fav-Core-2 (192.168.30.2)
  - Fav-Access-1 (192.168.30.3)
  - Fav-Access-2 (192.168.30.4)
- 1x IP-Phone
  - IP-Phone-Favoriten (192.168.42.1)
- 3x Ubuntu-Server
  - Bastion (192.168.150.100)
  - Fav-File-Server (192.168.100.10)
  - VPN-Server (192.168.100.20)
- 6x Windows-Server
  - DC1 (192.168.200.1) (Core)
  - DC2 (192.168.200.2) (Core)
  - NPS (192.168.200.5) (Core)
  - CA (192.168.200.10) (Core)
  - Web-Server (192.168.200.100) (GUI)
  - Jump-Server (192.168.210.1) (GUI)
- 2x Windows-Client
  - Fav-W-Workstation-1 (DHCP --> Static Lease für 192.168.20.10) (PAW)
  - Fav-W-Workstation-2 (DHCP)

=== Features

Folgende Features wurden im Rahmen dieses Standorts implementiert:

==== FortiGates
Siehe @fortigate.

==== Switches
  - PVST+
  - Management-Interface auf VLAN 30, IPs siehe oben
  - VTP für die automatische Verteilung von VLAN-Informationen
  - Bei redundanten Verbindungen untereinander EtherChannel mittels LACP aggregieren (inklusive Load-Balancing)
  - Switchport Security (Hardening)
    - Gehärteter PVST+ Prozess
    - Root-, Loop, BPDU-Guard
    - DHCP Snooping, Dynamic ARP inspection (DAI)
    - Blackhole VLAN auf ungenutzten Interfaces
  
==== Bastion
TODO

==== Fav-File-Server
  - SMB-Share
  - Synchronisiert seine Dateien mit Dorf-File-Server mittels lsyncd
  - Erhält R-SPAN Daten der Fav-Switches und verarbeitet diese mittels T-Shark und speichert das auf einem Log-Share ab

==== VPN-Server
Ein WireGuard VPN-Server dient am Standort Wien Favoriten als alternativer RAS-VPN-Endpunkt zum RAS-VPN auf den FortiGate-Firewalls.

==== Active Directory
Am Standort Wien Favoriten stehen als AD-integrierte Endgeräte eine CA, zwei DCs, ein Jump-Server, ein Web-Server, ein NPS und mehrere Windows Workstations (darunter eine PAW).

Für nähere Informationen siehe @ad.

#pagebreak()
== Langenzersdorf

Langenzersdorf ist der Nebenstandort der Gartenbedarfs GmbH und ist der zweitgrößte Standort in der Topologie.

#htl3r.fspace(
  total-width: 60%,
  figure(
    image("../images/topology/standorte/langenzersdorf.png"),
    caption: [Der Standort Langenzersdorf]
  )
)

Der private Adressbereich an diesem Standort entspricht dem Subnetz 10.10.xx.0/24.

xx = VLAN-ID, falls das Gerät keinem spezifischen VLAN zugewiesen ist, dann ist xx = 0

=== VLANs

#align(center, table(
  columns: 2,
  align: left,
  [*ID*], [*Bezeichnung*],
  [10], [Linux Clients], 
  [20], [Windows Clients], 
  [30], [Switch Management], 
  [31], [Switch Mirroring], 
  [42], [VoIP-Geräte], 
  [100], [Ubuntu Server], 
  [200], [Windows Server], 
  [666], [Blackhole], 
))

=== Geräte 

- 1x FortiGate
  - Dorf-FW (10.10.xx.254)
- 1x L3-Switch
  - Dorf-SW (10.10.30.1)
- 1x IP-Phone
  - IP-Phone-Langenzersdorf (10.10.42.1)
- 2x Ubuntu-Server
  - Dorf-File-Server (quasi Syslog) (10.10.100.1)
  - Docker-Host (10.10.100.10 & Docker-Container)
    - NGINX Webserver (10.10.100.11)
    - Bind9 DNS-Server (10.10.100.12)
    - Grafana (10.10.100.13)
    - Prometheus (10.10.100.14)
- 2x Windows-Server
  - DC-Extern (10.10.200.1) (Core)
  - DC3 (10.10.200.3) (Core)
- 1x Linux-Client
  - Dorf-L-Workstation (DHCP)
- 2x Windows-Client
  - Dorf-W-Workstation-1 (DHCP)
  - Dorf-W-Workstation-2 (DHCP)

=== Features

==== FortiGate
Siehe @fortigate.

==== Switch
  - Management-Interface auf VLAN 30, IP siehe oben.
  - Folgende Switchport Security (Hardening) Features sind konfiguriert:
    - Root-, Loop, BPDU-Guard
    - DHCP Snooping, Dynamic ARP inspection (DAI)
    - Blackhole VLAN auf unused Interfaces
    - Spanning-Tree deaktiviert
  - Spiegelt Traffic mittels SPAN an den Dorf-File-Server.

==== Dorf-File-Server
  - Hostet einen SMB-Share.
  - Synchronisiert seine Dateien mit Fav-File-Server mittels lsyncd.
  - Erhält SPAN-Daten des Dorf-Switches und verarbeitet diese mittels T-Shark und speichert das auf einem Log-Share ab.

==== Docker-Host
Hostet folgende Services innerhalb von Docker-Containern mit eigenen IPs (siehe oben): NGINX, Bind9, Grafana und Prometheus.

==== Active Directory
Am Standort Langenzersdorf stehen als AD-integrierte Endgeräte eine CA, zwei DCs, ein Jump-Server, ein Web-Server, ein NPS und mehrere Windows Workstations (darunter eine PAW).

Für nähere Informationen siehe @ad. TODO
  - DC3 und DC-Extern nutzen beide Windows Server Core
  - Hosten die AD-Domäne corp.gartenbedarf.com bzw. extern.corp.gartenbedarf.com
- Linux Workstations
  - WIP
- Windows Workstations
  - Sind Teil der corp.gardenbedarf.com Domäne
  - Sind in einem private VLAN (20 bzw. 21) und können sich nicht gegenseitig erreichen

== Kebapci

fdfdfdfdfdfd

#htl3r.fspace(
  total-width: 55%,
  figure(
    image("../images/topology/standorte/kebapci.png"),
    caption: [Der Standort "Kebapci"]
  )
)

== Praunstraße

fdfdfdfdf

#htl3r.fspace(
  total-width: 35%,
  figure(
    image("../images/topology/standorte/praunstrasse.png"),
    caption: [Der Standort Praunstraße]
  )
)

#htl3r.author("David Koch")
== Flex-Standorte

Die Flex-Standorte dienen lediglich der Implementierung eines FlexVPN-Tunnels. Deswegen bestehen sie jeweils nur aus zwei Geräten: Einem Cisco Router als "Firewall" und einem #htl3r.short[vpcs] für Ping-Tests.

#htl3r.fspace(
  total-width: 40%,
  figure(
    image("../images/topology/standorte/flex_standort_2.png"),
    caption: [Der zweite Flex-Standort]
  )
)

#htl3r.code(caption: "EIGRP-Konfiguration auf R-Flex-Edge-2", description: none)[
```cisco
router eigrp 100
no auto-summary
network 10.20.0.0 0.0.0.255
network 10.20.69.0 0.0.0.255
ex```
]

== Armut-Standorte

#htl3r.fspace(
  total-width: 55%,
  figure(
    image("../images/topology/standorte/armut_standort_1.png"),
    caption: [Der erste Armut-Standort]
  )
)

== Viktor-Standort
TODO
