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

==== Switches <switches-fav>
  - PVST+

#htl3r.code(caption: "PVST+ Konfiguration auf den Favoriten-Switches", description: none)[
```cisco
sp mode rapid-pvst
sp vlan 10,20,21,30,31,42,100,150,200,210,666 priority 4096

vlan 10
name Linux_Clients
ex
vlan 20
name Windows_Clients
ex
...
```
]

  - Management-Interface auf VLAN 30, IPs siehe oben
  - VTP für die automatische Verteilung von VLAN-Informationen

#htl3r.code(caption: "VPN-Konfiguration auf Fav-Core-1", description: none)[
```cisco
vtp domain 5CN
vtp password 5CN
vtp version 3
vtp mode server
vtp pruning
do vtp primary
```
]

  - Bei redundanten Verbindungen untereinander EtherChannel mittels LACP aggregieren (inklusive Load-Balancing)

#htl3r.code(caption: "Etherchannel-Konfiguration auf Fav-Core-1", description: none)[
```cisco
port-channel load-balance src-mac
...
int range g0/0-1
desc to_Fav_Access_1
switchport trunk encap dot1q
switchport mode trunk
channel-group 1 mode active
no shut
ex
...
int port-channel1
desc PO_to_Fav_Access_1
switchport trunk encap dot1q
switchport mode trunk
switchport trunk allowed vlan 1,10,20,21,30,31,42,100,150,200,210
ip arp inspection trust
no shut
ex
```
]

  - Switchport Security (Hardening)
    - Gehärteter PVST+ Prozess
    - Root-, Loop, BPDU-Guard
    - DHCP Snooping, Dynamic ARP inspection (DAI)
    - Blackhole VLAN auf ungenutzten Interfaces

#htl3r.code(caption: "Befehle zur Härtung des Fav-Core-1", description: none)[
```cisco
ip arp inspection vlan 10,20,21,30,31,42,100,150,200,210,666
ip dhcp snooping vlan 10,20,21,30,31,42,100,150,200,210,666

int range g0/0-3, g1/0-3, g2/0-3, g3/0-3
desc UNUSED
switchport nonegotiate
switchport port-security mac-address sticky
switchport port-security aging time 20
switchport mode access
switchport access vlan 666
shut
ex

int g3/0
...
ip arp inspection trust
ip dhcp snooping trust
no shut
ex
```
]
  
==== Bastion
TODO

==== Fav-File-Server
  - SMB-Share
  - Synchronisiert seine Dateien mit Dorf-File-Server mittels lsyncd
  - Erhält R-SPAN Daten der Fav-Switches und verarbeitet diese mittels T-Shark und speichert das auf einem Log-Share ab

==== VPN-Server <wireguard>
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

Für die Konfigurations-Snippets der oben aufgelisteten Switch-Features siehe @switches-fav (Switches in Wien Favoriten).

==== Dorf-File-Server
  - Hostet einen SMB-Share.
  - Synchronisiert seine Dateien mit Fav-File-Server mittels lsyncd.
  - Erhält SPAN-Daten des Dorf-Switches, verarbeitet diese mittels T-Shark/TCPDump und speichert das auf einem Log-Share ab.

Der Dorf-File-Server ist doppelt mit dem Dorf-SW verbunden. Über eine Verbindung läuft der "herkömmliche" Traffic, z.B. ICMP-Request und Syslogs, auf der zweiten Verbindung wird ausschließlich Mirror-Traffic vom Switch aus übertragen. Diese Verbindungen müssen getrennt behandelt werden, da der Mirror-Traffic über einen promiscuous Port am Dorf-File-Server empfangen werden muss -> es wird nicht darauf geschaut, ob der Empfänger usw. stimmt, die Pakete werden trotzdem verarbeitet bzw. gespeichert.

Mit folgendem TCPDump-Befehl lässt sich der Mirror-Traffic auslesen und in einer PCAP-Datei speichern:
#htl3r.code()[
```bash
tcpdump -i MIRROR -nn -s0 -w /var/log/mirrored_traffic.pcap
```
]

#htl3r.fspace(
  figure(
    image("../images/screenshots/Screenshot 2025-02-19 172553.png"),
    caption: [Die Ausgabe von TCPDump beim Mirror-Traffic-Capturing]
  )
)

Um die empfangenen Syslogs zu begutachten wurde keine spezielle Softwarelösung verwendet, da die GUI fehlt. Als "Proof of Concept" reicht das Auslesen des Syslog-Pfades unter Ubuntu, welcher nun mit Logs vom Dorf-SW gefüllt ist:
#htl3r.code()[
```bash
cat /var/log/syslog | tail -n 10
```
]

#htl3r.fspace(
  figure(
    image("../images/screenshots/Screenshot 2025-02-19 175710.png"),
    caption: [Syslogs des Dorf-SW auf Dorf-File-Server]
  )
)

==== Docker-Host
Hostet folgende Services innerhalb von Docker-Containern mit eigenen IPs (siehe oben): NGINX, Bind9, Grafana und Prometheus.

#htl3r.fspace(
  figure(
    image("../images/screenshots/Screenshot 2025-03-12 122556.png"),
    caption: [Screenshot der NGINX-Website am Docker-Host]
  )
)

(Die Website hat ein valides Zertifikat von der CA ausgestellt bekommen, wenn die Dorf-L-Workstation Auto-Enrollment hätte -- so wie die Windows Workstations -- wäre die HTTPS-Verbindung sicher)

==== Active Directory
Am Standort Langenzersdorf stehen als AD-integrierte Endgeräte zwei DCs und zwei Windows Workstations.

Für nähere Informationen siehe @ad.

#pagebreak()
== Kebapci

Der private Adressbereich an diesem Standort entspricht dem Subnetz 172.16.0.0/24.

#htl3r.fspace(
  total-width: 55%,
  figure(
    image("../images/topology/standorte/kebapci.png"),
    caption: [Der Standort "Kebapci"]
  )
)

Der Standort "Kebapci" ist der dritte und letzte der AD-integrierten Standorte. Da er als "unsicher" gilt, wird hier ein RODC eingesetzt (für weitere Informationen siehe @ad). Unter anderem ist hier ein eigener Webserver und eine AD-integrierte Windows Workstation zu finden.

#pagebreak()
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

#pagebreak()
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

#pagebreak()
== Armut-Standorte

Beide Armut-Standorte sind miteinander über einen MPLS Overlay VPN über das Backbone-Netz von AS666 verbunden. Für weitere Informationen siehe @mpls-vpn.

#htl3r.fspace(
  total-width: 55%,
  figure(
    image("../images/topology/standorte/armut_standort_1.png"),
    caption: [Der erste Armut-Standort]
  )
)

#pagebreak()
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
iptables -t nat -A POSTROUTING -o outside -j MASQUERADE
iptables -A FORWARD -i Viktor-LAN -o outside -p icmp -j ACCEPT
iptables -A FORWARD -i outside -o Viktor-LAN -p icmp -m state --state RELATED,ESTABLISHED -j ACCEPT
```
]