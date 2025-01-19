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

# 10.01.2024

## Burger
- Switch configuration am Standort Praunstraße

# 11.01.2024

## Koch
- Switch-Konfiguration am Standort Wien Favoriten
- Anpassungen an der Konfiguration vom Dorf-SW

# 18.01.2024

## Burger
Begonnen mit AD, aufgesetzt in einem "simulations" Netzwerk. Damit dies unabhängig von den
ISPs getestet werden kann.
- Erstellung der Simulations-Topology
- Basic Config im AD sowie Simulations-Router

# 19.01.2024

## Burger
Weiter gemacht im AD:
- Child-Domain
- RODC
- IIS + SSL
- CA
- PKI
- Autoenrollment
