# Firma Backstory
Gartenbedarfs GmbH

CEO: Huber „Huber“ Huber

Verkauft u.a. die Rasensprengerköpfe „Sprühkönig“ und „Sprengmeister“ als auch den Stoff „Huberit“

Die Mitarbeiter der Gartenbedarfs GmbH gehen gerne in ihren Mittagspausen zu Kebapci futtern

# Standorte

## Backbone

Zwischen den AS’s werden als public IPs die für die Antarktis vorgesehenen IP-Ranges genutzt, somit sollte es auch bei einem Anschluss ans echte Internet keinen Overlap geben (hoffentlich)

Public-Peering-Adressbereiche:
- Zwischen AS100 (R-AS100-Peer-1) und AS666 (R-AS666-Peer-2): 154.30.31.0/30
- Zwischen AS666 (R-AS666-Peer-1) und AS20 (R-AS22-Peer): 45.84.107.0/30
- Zwischen AS20 (R-AS21-Peer) und AS100 (R-AS100-Peer-2): 103.152.127.0/30

Bei den Firewall-PoPs:
- R-AS100-Peer-1 zu Kebapci-FW: 31.25.11.0/24
- R-AS666-Peer-3 zu Dorf-FW: 87.120.166.0/24
- R-AS21-Peer und R-AS100-Peer-2 zu Fav-FWs (WIP): 103.152.126.0/24

Jegliche Instanzen von OSPF, RIP und BGP im Backbone nutzen Authentifizierung für ihre Updates

OSPF:
- Key-String: ciscocisco
- Algorithmus: hmac-sha-512

RIP:
- Key-String: ganzgeheim123!
- Algorithmus: dsa-2048

BGP:
- Key-String: BeeGeePee?
- Algorithmus: ecdsa-384

Das Backbone besteht aus drei AS’s:

### AS20

Besteht aus den Sub-AS’s 21 & 22, insgesamt 5 Router (2 in 21 und 3 in 22):
* R-AS21-Peer
* R-AS21-BB
* R-AS21-Internet
* R-AS22-Peer
* R-AS22-BB

Nutzt ein MPLS Overlay, OSPF Underlay

BGP Features:
* R-AS21-Internet dient als Route-Reflector
* R-AS21-Internet teilt seine Default Route ins Internet den anderen Peers mit
* WIP

Adressbereiche:
* 172.16.20.0/30
* 172.16.21.0/30
* 172.16.21.4/30
* 172.16.22.0/30

### AS100

Besteht aus insgesamt nur 2 Routern:
* R-AS100-Peer-1
* R-AS100-Peer-2

Braucht kein Overlay/Underlay, nur BGP weil 2 Router

BGP Features:
* WIP

Addressbereiche:
* 192.168.100.0/30

### AS666

Besteht aus 4 Routern und 1 L2-Switch:
* R-AS666-Peer-1
* R-AS666-Peer-2
* R-AS666-Peer-3
* R-AS666-BB
* SW-AS666-BB

Nutzt ein GRE & RIP Overlay, OSPF Underlay

BGP Features:
* WIP

Adressbereiche:
* 10.6.66.0/29
* 10.6.66.8/30

## Wien Favoriten

192.168.xx.0/24

xx = VLAN-ID, falls das Gerät keinem spezifischen VLAN zugewiesen ist, dann ist xx = 0

### VLANs

* 20: Windows Clients
* 30: Switch Management
* 42: VoIP-Geräte
* 100: Ubuntu Server (ohne Bastion)
* 150: Bastion
* 200: Windows Server
* 666: Blackhole

### Geräte

- 2x FortiGate
  * Fav-FW-1 (192.168.0.254)
  * Fav-FW-2 (192.168.0.253)
- 4x L3-Switch
  * Fav-Core-1 (192.168.30.1)
  * Fav-Core-2 (192.168.30.2)
  * Fav-Access-1 (192.168.30.3)
  * Fav-Access-2 (192.168.30.4)
- 1x IP-Phone
  * IP-Phone-Favoriten (192.168.42.1)
- 3x Ubuntu-Server
  * Bastion (192.168.150.100)
  * Fav-File-Server (192.168.100.10)
  * CA (192.168.100.20)
- 2x Windows-Server
  * DC1 (192.168.200.1)
  * DC2 (192.168.200.2)
- 2x Windows-Client
  * Fav-W-Workstation-1 (DHCP --> Static Lease für 192.168.20.10)
  * Fav-W-Workstation-2 (DHCP)

### Features

- FortiGates
  * HA-Cluster mit Fav-FW-1 & Fav-FW-2
  * QoS für VoIP
  * SSL-Inspection
  * IPsec VPN-Tunnel zu Dorf-FW
  * DMVPN VPN-Tunnel zu Kebapci-FW
  * WIP
- Switches
  * Management-Interface auf VLAN 30, IPs siehe oben
  * VTP
  * Bei redundanten Verbindungen untereinander EtherChannel mittels LACP aggregieren + Load-Balancing
  * Switchport Security (Hardening)
  * QoS für VoIP
- IP-Phone
  * Kann das IP-Phone-Langenzersdorf anrufen und telefonieren ohne Qualitätsverluste
- Bastion
  * Ansibleeeeeeeeeeee
- Fav-File-Server
  * SMB-Share
  * Synchronisiert seine Dateien mit Dorf-File-Server mittels lsyncd
- CA
  * WIP
- DCs
  * Hosten die AD-Domäne corp.gartenbedarf.com
  * FSMO-Rollen: DC1 ist DNM und PDC, DC2 ist SM, RID Pool Manager und IM
  * DC1 ist DHCP Server, DC2 dient als Failover --> Fav-W-Workstation-1 bekommt Static Lease
  * SSH-Server ist an und PowerShell-Remoting ist erlaubt
  * Schickt mittels Windows-Prometheus-Exporter Daten an den Grafana Server in Langenzersdorf
  * *für weitere AD-Details siehe unten "Active Directory"*
- Windows Workstations
  * Teil des AD

## Langenzersdorf

10.10.xx.0/24

xx = VLAN-ID, falls das Gerät keinem spezifischen VLAN zugewiesen ist, dann ist xx = 0

### VLANs

* 10: Windows Clients
* 20: Windows Clients
* 30: Switch Management
* 42: VoIP-Geräte
* 100: Ubuntu Server
* 666: Blackhole

### Geräte

- 1x FortiGate
  * Dorf-FW (10.10.0.254)
- 1x L3-Switch
  * Dorf-SW (10.10.30.1)
- 1x IP-Phone
  * IP-Phone-Langenzersdorf (10.10.42.1)
- 2x Ubuntu-Server
  * Dorf-File-Server (10.10.100.10)
  * Fav-File-Server (10.10.100.1 & Docker-Container: 10.10.100.11, 10.10.100.12, 10.10.100.13) 
- 1x Linux-Client
  * Dorf-L-Workstation (DHCP)
- 1x Windows-Client
  * Dorf-W-Workstation (DHCP)

### Features

- FortiGate
  * QoS für VoIP
  * SSL-Inspection
  * IPsec VPN-Tunnel zu Fav-FW-1 & 2
  * WIP
- Switch
  * Management-Interface auf VLAN 30, IP siehe oben
  * Switchport Security (Hardening)
  * QoS für VoIP
- IP-Phone
  * Kann das IP-Phone-Favoriten anrufen und telefonieren ohne Qualitätsverluste
- Dorf-File-Server
  * SMB-Share
  * Synchronisiert seine Dateien mit Fav-File-Server mittels lsyncd
- Linux Workstations
  * WIP
- Windows Workstations
  * Teil des AD

## Kebapci

172.16.0.0/24

### Geräte

- 1x Ubuntu-Server (pfSense)
  * Kebapci-FW (172.16.0.254)
- 1x L2-Switch
  * Kebapci-SW
- 1x IP-Phone
  * IP-Phone-Langenzersdorf (10.10.42.1)
- 2x Windows-Client
  * PC-1 (DHCP)
  * PC-2 (DHCP)

### Features

- pfSense
  * DMVPN VPN-Tunnel zu Fav-FW-1 & 2
  * WIP
- Switch
  * Switchport Security (Hardening)
- Windows Clients
  * WIP

# Active Directory

corp.gartenbedarf.com

Streckt sich über die beiden Standorte Wien Favoriten und Langenzersdorf, wobei beide DCs in Favoriten stehen

WIP

## GPOs

* Desktophintergrund setzen und Veränderung verbieten
* Loginscreen setzen (?)
* Last logged in User nicht anzeigen
* Mount Drive
* PWD Security-Richtlinie
* Locale Firewall am Client (per PS erstellen)
* Removable Media verbieten
* Registry-Zugriff einschränken

WIP
