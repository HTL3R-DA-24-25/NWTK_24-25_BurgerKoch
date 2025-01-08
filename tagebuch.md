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

# 08.01.2025

## Burger
- Vollständige Aufsetzung des Docker-Hosts
    * Nginx Webserver
    * Bind9 DNS
    * Prometheus
    * Grafana
- Begonnen mit der Überarbeitung des Netzplans/Topologie
