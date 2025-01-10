# Firma Backstory
Gartenbedarfs GmbH

CEO: Huber „Huber“ Huber

Verkauft u.a. die Rasensprengerköpfe „Sprühkönig“ und „Sprengmeister“ als auch den Stoff „Huberit“.

Die Mitarbeiter der Gartenbedarfs GmbH gehen gerne in ihren Mittagspausen u.a. zu Kebapci futtern, ABER die Gartenbedarfs GmbH ist heimlich mit Kebapci geschäftlich und infrastrukturtechnisch verwickelt, da Kepabci als Front für die Schwarzarbeit und Geldwäsche der Gartenbedarfs GmbH genutzt wird.

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
- Key-String: BeeGeePee!?
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
* Pfadmanipulation für redundante Versorgung des Wien Favoriten Standortes (gemeinsam mit AS100)
* Distribution Lists

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
* Pfadmanipulation für redundante Versorgung des Wien Favoriten Standortes (gemeinsam mit AS20)
* Distribution Lists

Addressbereiche:
* 192.168.100.0/30

### AS666

Besteht aus 12 Routern und 2 L2-Switches:
* R-AS666-Peer-1
* R-AS666-Peer-2
* R-AS666-Peer-3
* R-AS666-BB-1
* R-AS666-BB-2
* R-AS666-BB-3
* R-AS666-BB-4
* R-AS666-BB-5
* R-AS666-BB-6
* R-AS666-BB-7
* R-AS666-BB-8
* R-AS666-BB-9
* SW-AS666-BB-1
* SW-AS666-BB-2

Nutzt ein GRE & RIP Overlay, OSPF Underlay

BGP Features:
* Distribution Lists

Adressbereiche:
* 10.6.66.0/30
* 10.6.66.4/30
* 10.6.66.8/30
* 10.6.66.12/29
* 10.6.66.20/30
* 10.6.66.24/30
* 10.6.66.28/30
* 10.6.66.32/30
* 10.6.66.36/30
* 10.6.66.40/30
* 10.6.66.44/30
* 10.6.66.48/30
* 10.6.66.52/29

## Wien Favoriten

192.168.xx.0/24

xx = VLAN-ID, falls das Gerät keinem spezifischen VLAN zugewiesen ist, dann ist xx = 0

### VLANs

* 20: Windows Clients (+ Private VLANs)
* 30: Switch Management
* 31: Switch R-SPAN Mirroring
* 42: VoIP-Geräte
* 100: Ubuntu Server (ohne Bastion)
* 150: Bastion
* 200: Windows Server
* 201: Offline Root CA
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
  * VPN-Server (192.168.100.20)
- 5x Windows-Server
  * DC1 (192.168.200.1) (GUI)
  * DC2 (192.168.200.2) (GUI)
  * DC-Extern (192.168.200.3) (Core)
  * Jump-Server (192.168.200.10) (GUI)
  * Offline-Root-CA (192.168.201.1) (GUI)
- 2x Windows-Client
  * Fav-W-Workstation-1 (DHCP --> Static Lease für 192.168.20.10) (PAW)
  * Fav-W-Workstation-2 (DHCP)

### Features

- FortiGates
  * HA-Cluster mit Fav-FW-1 & Fav-FW-2
  * Traffic Shapping bzw QoS für VoIP/Video (Youtube)
  * SSL-Inspection
  * IPsec (IKEv2) VPN-Tunnel zu Dorf-FW mit PSK
  * DMVPN (IKEv2) VPN-Tunnel zu Kebapci-FW
  * Remote Access - "RAS" SSL-VPN
  * Authentifizierter Internetzugang via captive portal (Network Policy Server)
  * Telemetry Client(?)
  * Malicious IPs outside in blocken
  * Bogons blocken
  * Webfilter
  * DLP(?)
  * Static NAT nach außen für irgendein Gerät
  * PAT nach außen für non-VPN-Traffic
  * Gateway-Redundanz mit IP-SLA
  * Port-Forwarding von WireGuard-Traffic auf den internen VPN-Server
- Switches
  * PVST+
  * Management-Interface auf VLAN 30, IPs siehe oben
  * VTP
  * Bei redundanten Verbindungen untereinander EtherChannel mittels LACP aggregieren + Load-Balancing
  * Switchport Security (Hardening)
    * Gehärteter PVST+
    * Root-, Loop, BPDU-Guard
    * DHCP Snooping, Dynamic ARP inspection (DAI)
    * Blackhole VLAN auf unused Interfaces
  * QoS für VoIP
  * R-SPAN zum Fav-File-Server
- IP-Phone
  * Kann das IP-Phone-Langenzersdorf anrufen und telefonieren ohne Qualitätsverluste
- Bastion
  * Ansibleeeeeeeeeeee
- Fav-File-Server
  * SMB-Share
  * Synchronisiert seine Dateien mit Dorf-File-Server mittels lsyncd
  * Erhält R-SPAN Daten der Fav-Switches und verarbeitet diese mittels T-Shark und speichert das auf einem Log-Share ab
- VPN-Server
  * WireGuard VPN-Server
- Offline-Root-CA
  * NICHT Teil der AD-Domäne
  * Ist abgekapselt von den restlichen Netzwerken, wird nur zur Erneuerung der Zertifikate wieder kurz dazugeschalten
- DCs
  * DC1 und DC2 nutzen Windows Server GUI, DC-Extern nutzt Core
  * Hosten die AD-Domäne corp.gartenbedarf.com
  * FSMO-Rollen: DC1 ist DNM und PDC, DC2 ist SM, RID Pool Manager und IM
  * DC1 ist DHCP Server, DC2 dient als Failover --> Fav-W-Workstation-1 bekommt Static Lease
  * SSH-Server ist an und PowerShell-Remoting ist erlaubt
  * Schickt mittels Windows-Prometheus-Exporter Daten an den Grafana Server in Langenzersdorf
  * Dienen als NTP-Server
  * *für weitere AD-Details siehe unten "Active Directory"*
- Jump-Server
  * Nutzt Windows Server GUI
  * Von der PAW aus per RDP und PS/SSH erreichbar
  * Kann auf die DCs per PS/SSH
- Windows Workstations
  * Sind Teil der extern.corp.gardenbedarf.com Domäne
  * W-Workstation-1 ist PAW (VIP-Zugriff auf FortiGate & Jump Server)

## Langenzersdorf

10.10.xx.0/24

xx = VLAN-ID, falls das Gerät keinem spezifischen VLAN zugewiesen ist, dann ist xx = 0

### VLANs

* 10: Linux Clients
* 20: Windows Clients
* 30: Switch Management
* 31: Switch (R-SPAN) Mirroring
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
  * Dorf-File-Server (quasi Syslog?) (10.10.100.1)
  * Docker-Host (10.10.100.10 & Docker-Container: 10.10.100.11, 10.10.100.12, 10.10.100.13, 10.10.100.14) 
- 1x Linux-Client
  * Dorf-L-Workstation (DHCP)
- 1x Windows-Client
  * Dorf-W-Workstation (DHCP)

### Features

- FortiGate
  * Traffic Shapping bzw QoS für VoIP/Video (Youtube)
  * SSL-Inspection
  * IPsec (IKEv2) VPN-Tunnel zu Fav-FW-1 & 2 mit PSK
  * Remote Access - "RAS" SSL-VPN
  * Authentifizierter Internetzugang via captive portal (Network Policy Server)
  * Telemetry Client(?)
  * Malicious IPs outside in blocken
  * Bogons blocken
  * Webfilter (x.com und htlrennweg.at blockiert)
  * DLP(?)
  * Static NAT nach außen für irgendein Gerät
  * PAT nach außen für non-VPN-Traffic
  * DHCP-Server für die Workstations
- Switch
  * Management-Interface auf VLAN 30, IP siehe oben
  * Switchport Security (Hardening)
    * Root-, Loop, BPDU-Guard
    * DHCP Snooping, Dynamic ARP inspection (DAI)
    * Blackhole VLAN auf unused Interfaces
  * QoS für VoIP
  * Spiegelt Traffic mittels SPAN an den Dorf-File-Server
- IP-Phone
  * Kann das IP-Phone-Favoriten anrufen und telefonieren ohne Qualitätsverluste
- Dorf-File-Server
  * SMB-Share
  * Synchronisiert seine Dateien mit Fav-File-Server mittels lsyncd
  * Erhält SPAN-Daten des Dorf-Switches und verarbeitet diese mittels T-Shark und speichert das auf einem Log-Share ab
- Docker-Host
  * Hostet folgende Services innerhalb von Docker-Containern mit eigenen IPs:
    * Webserver (nginx) (.11)
    * DNS Caching Forwarder (bind9) (.12)
    * Grafana (.13)
    * Prometheus (.14)
- Linux Workstations
  * WIP
- Windows Workstations
  * Sind Teil der corp.gardenbedarf.com Domäne

## Kebapci

172.16.0.0/24

### Geräte

- 1x Ubuntu-Server (pfSense)
  * Kebapci-FW (172.16.0.254)
- 1x Ubuntu-Server
  * Web-Server (172.16.0.20)
- 1x L2-Switch
  * Kebapci-SW
- 1x Windows-Client
  * Client (DHCP --> Static Lease für 172.16.0.1)
- 1x Windows-Server
  * RODC (172.16.0.10) (Core)

### Features

- pfSense
  * DMVPN VPN-Tunnel zu Fav-FW-1 & 2
  * PAT nach außen für non-VPN-Traffic
  * Web-Server durch Port-Forwarding von außen erreichbar
- Switch
  * Switchport Security (Hardening)
    * Root-, Loop, BPDU-Guard
    * DHCP Snooping, Dynamic ARP inspection (DAI)
    * Blackhole VLAN auf unused Interfaces
- Web-Server
  * Hostet mittels nginx eine Website
- Windows Clients
  * Sind Teil der extern.corp.gardenbedarf.com Domäne
- DC
  * Repliziert den DC-Extern am Standort Wien Favoriten
  * Ist ein RODC

## Praunstraße

172.16.69.0/24

### Geräte

- 1x Ubuntu-Server (pfSense)
  * Burger-FW (172.16.69.254)
- 1x L2-Switch
  * Burger-SW
- 1x Linux-Client
  * Burger-Workstation (DHCP)

### Features

- pfSense
  * PAT nach außen für non-VPN-Traffic
- Switch
  * Switchport Security (Hardening)
    * Root-, Loop, BPDU-Guard
    * DHCP Snooping, Dynamic ARP inspection (DAI)
    * Blackhole VLAN auf unused Interfaces
- Linux Client
  * RAS WireGuard VPN-Tunnel zu Wien-Favoriten

# Active Directory

Root-Domain: corp.gartenbedarf.com
Sonstige Domains: extern.corp.gartenbedarf.com

Streckt sich über die Standorte Wien Favoriten, Langenzersdorf und Kebapci, wobei beide Root-DCs in Favoriten stehen 

## Geräte

### Domain Controller

Root-DCs stehen beide in Wien Favoriten, RODC bei Kebapci

|Bezeichnung|IP-Adresse|FQDN|FSMO-Rollen|Read-Only|
|---|---|---|---|---|
|DC1|192.168.200.1|dc1.corp.gartenbedarf.com|DNM, PDC|Nein|
|DC2|192.168.200.2|dc2.corp.gartenbedarf.com|SM, RIDPM, IM|Nein|
|RODC|172.16.0.10|dc.extern.corp.gartenbedarf.com|-|Ja|

* DC1 ist DHCP Server, DC2 dient als Failover --> Fav-W-Workstation-1 bekommt Static Lease
* RODC ist Read-Only (duh)
* SSH-Server ist an und PowerShell-Remoting ist erlaubt
* Schicken mittels Windows-Prometheus-Exporter Daten an den Grafana Server in Langenzersdorf
* Root-DCs dienen als NTP-Server

### Jump-Server

|Bezeichnung|IP-Adresse|FQDN|
|---|---|---|
|DC1|192.168.200.10|jump.corp.gartenbedarf.com|

* Kann per RDP und SSH auf die DCs zugreifen

### Workstations

|Bezeichnung|IP-Adresse|FQDN|PAW|
|---|---|---|---|
|Fav-W-Workstation-1|DHCP, Static Lease 192.168.20.10|work1.corp.gartenbedarf.com|Ja|
|Fav-W-Workstation-2|DHCP|work2.corp.gartenbedarf.com|Nein|

* Die Fav-W-Workstation-1 ist eine Priviliged Access Workstation (PAW), und kann u.a. deswegen folgende besondere Sachen:
  * Auf den Jump-Server per RDP und SSH zugreifen

## Users & Computers

### AGDLP

### OU-Struktur

## PKI

1-Tier PKI

Autoenrollment der Zertifikate per GPO für:
* Clients
* VPN

### NPS

Radius Server läuft als Service auf DC1
Integration mit (also man kann sich dort mit AD-User authentifizieren):
* Switches innerhalb der Firmenstandorte
* FortiGate Captive Portal

### IPAM

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
* PKI-Zertifikate automatisch enrollen
