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

#pagebreak()
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

Der Standort Praunstraße symbolisiert ein kleines Heimnetzwerk, welches von einem Mitarbeiter der Gartenbedarfs GmbH für das Home-OFfice verwendet wird. Hier ist lediglich ein Internetzugriff gegeben, über welchen beispielsweise gesurft und eine RAS-VPN-Verbindung zum Firmenstandort Wien Favoriten aufgebaut werden kann.

#htl3r.fspace(
  total-width: 35%,
  figure(
    image("../images/topology/standorte/praunstrasse.png"),
    caption: [Der Standort Praunstraße]
  )
)

=== Private VLANs

Da der hier ansässige Mitarbeiter ein großes Bewusstsein für die Cybersicherheit hat, hat er auf seinem Switch private VLANs konfiguriert, damit sich die Endgeräte innerhalb seines Netzwerks nicht untereinander erreichen können.

#htl3r.code(caption: "Private VLANs auf Burger-SW", description: none)[
```cisco
vtp mode transparent

vlan 100
name BURGER-LAN-ISOLATED
private-vlan isolated
ex

vlan 10
name BURGER-LAN
private-vlan primary
private-vlan association add 100
ex

...

int range gig 0/1 - 2
switchport mode private-vlan host
switchport private-vlan host-association 10 100
exit

int gig 0/0
switchport mode private-vlan promiscuous
switchport private-vlan mapping 10 100
exit
```
]

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

=== EIGRP

Damit sich die Endgeräte der Flex-Standorte erreichen können, müssen die Edge-Router vom gegenüberliegenden Netzwerk wissen. Für diesen Routenaustausch wird das Routingprotokoll EIGRP verwendet, da es simpel zu konfigurieren ist und im Vergleich zu anderen Distance-Vektor-Protokollen moderner gestaltet ist (im Vergleich zu RIP z.B.).

#htl3r.code(caption: "EIGRP-Konfiguration auf R-Flex-Edge-2", description: none)[
```cisco
router eigrp 100
no auto-summary
network 10.20.0.0 0.0.0.255
network 10.20.69.0 0.0.0.255
ex```
]

== Armut-Standorte

Beide Armut-Standorte sind miteinander über einen MPLS Overlay VPN über das Backbone-Netz von AS666 verbunden. Für weitere Informationen siehe @mpls-vpn.

#htl3r.fspace(
  total-width: 55%,
  figure(
    image("../images/topology/standorte/armut_standort_1.png"),
    caption: [Der erste Armut-Standort]
  )
)

== Viktor-Standort

Der "Viktor-Standort" ist der zweite Home-Office-Standort der Topologie (nach Praunstraße) und wird statt einem Edge-Router oder einer Firewall durch eine Ubuntu-basierte Linux-Firewall vom öffentlichen Netz abgegrenzt.

#htl3r.fspace(
  total-width: 55%,
  figure(
    image("../images/topology/standorte/viktor_standort.png"),
    caption: [Der Viktor-Standort]
  )
)

=== Linux-Firewall

Wie zuvor erwähnt ist die Linux-Firewall am Viktor Standort eine Ubuntu 22.04 VM. Sie regelt den Datenverkehr zwischen dem Viktor-Client und dem öffentlichen Netz, wobei sie lediglich ICMP-Anfragen (und deren Rückantworten) erlaubt.

Für die Konfiguration der Netzwerkadapter wird folgende Netplan-Config verwendet:

#htl3r.code(caption: "Netplan-Konfiguration für die Netzwerkadapter der Linux-Firewall", description: none)[
```yml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: false
      match:
        macaddress: 00:0c:29:32:ea:ca
      set-name: outside
      addresses:
        - 31.28.9.1/24
      gateway4: 31.28.9.254
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
    ens37:
      dhcp4: false
      match:
        macaddress: 00:0c:29:32:ea:d4
      set-name: Viktor-LAN
      addresses:
        - 10.69.69.254/24
```
]

Alle anderen Ubuntu-basierten Computer in der Topologie werden ebenfalls mittels Netplan (und somit mit ähnlichen Konfigurationsdateien zu der in der Abbildungen oben) konfiguriert.

Damit ein Ubuntu-Gerät zu einer Linux-Firewall wird, muss IP-Routing/Forwarding eingeschaltet und darauf die nötigen iptables-Regeln erstellt werden. Zur Aktivierung von IP-Routing (ACHTUNG: nicht persistent!) können folgende Befehle verwendet werden:
#htl3r.code(caption: "Aktivierung nicht-persistentes IP-Routing unter Ubuntu", description: none)[
```bash
sysctl -w net.ipv4.ip_forward=1
sysctl -p
```
]

Anschließend können z.B. folgende iptables-Regeln gesetzt werden, um einen statischen NAT (PAT) nach außen zu starten und nur ICMP-Datenverkehr durchzulassen:
#htl3r.code(caption: "iptables-Regeln der Linux-FW", description: none)[
```bash
sysctl -w net.ipv4.ip_forward=1
sysctl -p
```
]
