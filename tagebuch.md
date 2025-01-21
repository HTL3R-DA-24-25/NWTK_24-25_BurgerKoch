# 13.11.2024
START

## Burger
- GitHub Repository aufsetzen
- Ansible Zeug

## Koch
- Beginn der Topologieplanung

# 14.11.2024

## Koch
- Abschluss der ersten groben Topologieplanung in GNS3 (Topo v1)
- 3 FortiGate-Lizenzen beantragt und erhalten

# 15.11.2024

## Burger
- Topo v1 in DrawIO zeichnen
- Topo-Korrekturen bzgl VLANs (Bastion Solo VLAN)

## Koch
- Fehlende Details zur Topologie als Braindump zu Text gebracht (WIP)
- Braindump von Word in Markdown umgeschrieben
- Topo-Korrekturen bzgl Adressbereiche (falsche Subnetzmasken & Adressen)

# 20.11.2024

## Burger
- Proxmox VE aufgesetzt
- DrawIO Netzplan überarbeitet

## Koch
- GNS3 Netzplan ergänzt/überarbeitet (v2):
    * Standort Praunstraße hinzugefügt
    * AD-Child-Domäne extern.corp.gartenbedarf.com inkl RODC bei Kebapci
    * CA zu Offline-Root-CA gemacht
    * Adressbereiche erneut korrigiert
    * Jump-Server, VPN-Server &  PAW zu Favoriten hinzugefügt
    * Kebapci bekommt einen Web-Server
- Am Protokoll/Dokumentationsbuch/Braindump weitergeschrieben

## Demnächst
- PKI planen
- Restliche Linux-Services unterbringen
- In DrawIO Netzplan Adressbereiche und den neuen Standort Praunstraße einzeichnen
- Users & Computers des AD's (AGDLP, OU-Struktur, ...) planen

# 04.12.2024

## Koch
- GNS3 Netzplan ergänzt/überarbeitet (v3):
    * AS666 zum offiziellen MPLS-Backbone gemacht und mit extra Routern/Switches befüllt
    * Öffentlicher Adressbereich für Praunstraße ergänzt
- Grundkonfigurations-Vorlage erstellt
- Alle Backbone-Skripts geschrieben
- Am Protokoll/Dokumentationsbuch/Braindump weitergeschrieben

## Burger
- [VMware Workstation Pro Automatisierung](https://github.com/cauvmou/vmrest-rs)
    * vmrest-API implementierung
    * VM Registrierung
    * VM Clonen
    * VM Netzwerk Adapter verwalten
    * Host VMNics verwalten

# 11.12.2024

## Koch
- Recherche Konfiguration von HA-Cluster, Private VLANs, Webfilter auf FortiGate
    * Active-Active Cluster für uns sinnvoller als Active-Passive
- FortiGate-Featureset im Braindump erweitert
- FortiGate-Grundkonfigurationsvorlage erstellt

## Burger
- PfSense Recherche

# 18.12.2024

# 08.01.2025

## Burger
- Ergänzung Prometheus-Container zum Docker-Host in Langenzersdorf
- Vollständige Aufsetzung des Docker-Hosts
    * Nginx Webserver (inkl eigene Website :D)
    * Bind9 DNS
    * Prometheus
    * Grafana
- Begonnen mit der Überarbeitung des Netzplans/Topologie

## Koch
- Ausarbeitung von der HA-Cluster-Konfiguration in Wien
- Folgende Dorf-FW Features implementiert:
    * Traffic Shapping bzw QoS für VoIP/Video (Youtube)
    * SSL-Inspection
    * Bogons blocken
    * Webfilter (x.com und htlrennweg.at blockiert)
    * Static NAT nach außen für irgendein Gerät (L & W Workstations auf 87.120.166.69)
    * PAT nach außen für non-VPN-Traffic
- Dorf-SW bis auf QoS konfiguriert
- Kopierfehler im Braindump ausmerzen und Details ergänzen

Demnächst:
- VPNs zwischen Standorten konfigurieren
- AD ausarbeiten
- Erste zusammengefügte Topo ausprobieren
- Dokumentation anhand DA-Typst-Vorlage aufsetzen

# 09.01.2025

## Koch
- DC-Extern hinzufügen damit der RODC überhaupt funktioniert
- Braindump ergänzt & Fehler ausgebessert
- WIP Skripts für DCs erstellt

# 10.01.2025

## Burger
- Switch configuration am Standort Praunstraße

# 11.01.2025

## Koch
- Switch-Konfiguration am Standort Wien Favoriten
- Anpassungen an der Konfiguration vom Dorf-SW

# 15.01.2025

## Koch
- Aufsetzung Dokumentationsbuch (Typst DA-Vorlage wiederverwenden)
- Adressierungsfehler in den Backbone-Skripts ausbessern
- Dorf-FW Adressobjekte verwenden
- Fav-FW-1 fertige Konfiguration bis auf VPN
- Erster Versuch IPsec IKEv2 VPN Tunnel von Langenzersdorf nach Favoriten
- BGP Confederation Troubleshooting

# 18.01.2025

## Burger
Begonnen mit AD, aufgesetzt in einem "simulations" Netzwerk. Damit dies unabhängig von den
ISPs getestet werden kann.
- Erstellung der Simulations-Topology
- Basic Config im AD sowie Simulations-Router

# 19.01.2025

## Burger
Weiter gemacht im AD:
- Child-Domain
- RODC
- IIS + SSL
- CA
- PKI
- Autoenrollment

## Koch
- FERTIGER IPsec IKEv2 Tunnel Langenzersdorf <---> Favoriten NACH 3 STUNDEN DEBUGGING WEGEN DEN ROUTER IMAGES(!!!!)
- Private VLAN verschoben von Favoriten nach Langenzersdorf
- IKEv2 RAS VPN auf Fav-FW-1/2 mit PSK für Praunstraße
- DHCP-Server auf FortiGate statt DC für Favoriten und Langenzersdorf
- Ausbesserung BGP-Konfiguration auf R-AS100-Peer-2 und im Confederation AS 20

# 20.01.2025

## Koch
- SPAN Mirroring in Langenzersdorf implementiert (T-Shark auf Dorf-File-Server nicht vergessen!)
- BGP Features:
    * Local Preference erhöht auf 300 für AS100 von AS666
    * In AS666 Prefix-Lists für Bogon Blocking
    * In AS100 Distribution-Lists für Blocking von Traffic, der aus Praunstraße kommt
- FlexVPN Geräte in Topologie eingebunden und FlexVPN mit PSK konfiguriert

## Burger
- Weiterer DC in Langenzersdorf für DFS
- Jump Server
- "Outbound" WinRM für Jump Server

# 21.01.2025

## Koch
- Aktualisierte Topologie (v5) mit:
    * richtigem HA Cluster Konzept
    * eingezeichneten FlexVPN-Geräten
    * Jump-Server, DC-Extern, CA am richtigen Platz (inkl VLAN 201 wird zu 210 und ist für den Jump-Server, nicht CA)
    * Hinzugefügter DC3 und Web-Server in Favoriten
- Ausbesserung Subnetzmasken bei ACLs (Wildcard...)
- Fehler bei eBGP-Link zwischen AS666 und AS20/22 ausgebessert
- Fertiges HA-Cluster in Favoriten + Loopback für VPN
- Funktionierender site2site VPN von Langenzersdorf nach Favoriten nun auch mit HA
- SPAN VLAN Konfiguration verbessert
- Fehler mit "vci-match" in DHCP-Konfiguration ausgebessert
- Erste Probekonfig Kebapci site2site VPN
- Einbindung der AD-Gerätschaft von Kollege Burger über einen Remote-Server und Cloud-Links mit VMnets
- Weitere Policies für Inter-VLAN-Routing in Favoriten:
    * Windows Server <--> Windows Clients
    * Windows Server <--> Jump-Server
