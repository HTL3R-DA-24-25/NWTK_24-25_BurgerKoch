#import "@preview/htl3r-da:1.0.0" as htl3r

= Firewalls

#htl3r.author("David Koch")
== FortiGate

Die Firma Fortinet ist einer der Weltmarktführer im Bereich Firewalls mit ihrer Reihe an FortiGate-Firewalls. Sie bieten nicht nur physische Modelle, sondern auch virtuelle Instanzen. In der Topologie werden insgesamt drei solcher virtuellen FortiGates eingesetzt, um eine industrienahe Firewall-Implementierung mit SOTA-Features erreichen.

In der Topologie sind insgesamt drei FortiGate-Firewalls zu finden:
- Fav-FW-1 und Fav-FW-2 am Standort Wien Favoriten
- Dorf-FW am Standort Langenzersdorf

Für die Addressbereiche der Peering- oder der Standort-Netzwerke siehe @backbone und @standorte.

Bei der Umsetzung der hier aufgelisteten Features wurde immer nur die CLI verwendet. Das Web-Dashboard dient nur der Überprüfung und der Veranschaulichung der Konfiguration.

=== Grundkonfiguration

#htl3r.code-file(
  caption: "Grundkonfiguration der Fav-FW-1",
  filename: [scripts/fortinet/Fav-FW-1.conf],
  ranges: ((6, 10),),
  lang: "python",
  text: read("../../scripts/fortinet/Fav-FW-1.conf")
)

=== Interfaces

Bevor die Implementierung von den Firewall-Features auf der FortiGate stattfinden kann, müssen -- wie auf allen anderen Netzwerkgeräten auch -- zuerst die Netzwerkinterfaces konfiguriert werden.

#htl3r.code-file(
  caption: "Interface-Konfigurationsbeispiele auf Fav-FW-1",
  filename: [scripts/fortinet/Fav-FW-1.conf],
  ranges: ((20, 33), (61, 70), (151, 151)),
  skips: ((34, 0), (71, 0)),
  lang: "python",
  text: read("../../scripts/fortinet/Fav-FW-1.conf")
)

=== Lizensierung



=== Policies

=== HA Cluster

Ein #htl3r.long["ha"] Cluster besteht aus zwei oder mehr FortiGates und dient der Ausfallsicherheit durch die automatisierte Konfigurationsduplikation zwischen den Geräten. Bei einem erfolgreichen Clustering verhalten sich die Geräte im Cluster so, als wären sie ein Einziges.

Vorraussetzungen:
- Zwei oder mehr FortiGate-Firewalls mit #htl3r.short["ha"]-Unterstützung
- Mindestens eine Point-to-Point Verbindung zwischen den Firewalls

Folgende Konfigurationsoptionen müssen gesetzt werden, um ein #htl3r.short["ha"]-Clustering zu erzielen:
- Clustering-Mode (Active-Passive oder Active-Active)
- Group-ID
- Group-Name
- Passwort
- Heartbeat-Interfaces (Die Point-to-Point Interfaces, die für die HA-Kommunikation genutzt werden sollen)

#htl3r.code-file(
  caption: "Konfiguration des HA Clusters auf Fav-FW-1",
  filename: [scripts/fortinet/Fav-FW-1.conf],
  ranges: ((12, 18),),
  lang: "python",
  text: read("../../scripts/fortinet/Fav-FW-1.conf")
)

Nachdem auf beiden Geräten die richtige Konfiguration vorgenommen worden ist, beginnen sie die gegenseitige Synchronisation ihrer gesamten Konfigurationen:

* BILD *

Zur Überprüfung können folgende Befehle verwendet werden:
- `fdfdfd`
- `fdfdfdf`

=== NAT

Damit die alle Client-PCs als auch manche Server der Standorte Wien Favoriten und Langenzersdorf die öffentlichen Adressen im LBT-Netzwerk sowie das Internet erreichen können, braucht es eine Art von NAT bzw. PAT.

#htl3r.code(caption: "Die non-VPN-Traffic PAT-to-Outside Firewall-Policy", description: none)[
```fortios
config firewall policy
    edit 1
        set name "non-VPN-PAT-to-Outside"
        set srcintf "port2" "VLAN_10" "VLAN_20" "VLAN_21" "VLAN_30" "VLAN_31" "VLAN_100" "VLAN_150" "VLAN_200" "VLAN_210"
        set dstintf "port1"
        set srcaddr "all"
        set dstaddr "Langenzersdorf_REMOTE" "Kebapci_REMOTE"
        set dstaddr-negate enable
        set action accept
        set schedule "always"
        set service "ALL"
        set utm-status enable
        set inspection-mode proxy
        set logtraffic all
        set webfilter-profile "webprofile"
        set profile-protocol-options default
        set ssl-ssh-profile custom-deep-inspection
        set nat enable
        set ippool enable
        set poolname "NAT_Public_IP_Pool"
        set logtraffic all
    next
end
```
]

=== DHCP

=== VPNs

=== Captive Portal

Bevor die Windows Clients (in VLAN 20) externe Hosts und Dienste erreichen können, müssen sie sich über ein sogenanntes "Captive Portal" bei der Firewall authentifizieren. Für die Authentifizierung wird der AD-integrierte NPS-Server genutzt, als Protokoll wird hierbei RADIUS verwendet.

Um eine "Captive Portal"-Authentifizierung auf einer FortiGate-Firewall zu konfigurieren, AAAAAA:




#htl3r.fspace(
  figure(
    image("../../images/screenshots/Screenshot 2025-02-19 130103.png"),
    caption: [Die erfolgreiche Authentifizierung mit AD-Benutzer über RADIUS]
  )
)

=== SSL Inspection

HTTPS-Traffic verläuft zwischen den Endgeräten TLS-verschlüsselt, wodurch die Firewalls nicht den Datenverkehr auf Schadsoftware oder andere unerwünschte Inhalten überprüfen können. Die Lösung zu diesem Problem ist die sogenannte "SSL Inspection", der Datenverkehr wird von der Firewall entschlüsselt (Original-Zertifikat wird entfernt), geprüft und anschließend wieder verschlüsselt (neues Zertifikat wird eingefügt).

AAAAAAAAAAAa

=== Traffic Shaping

Verschiedene Arten von Datenverkehr sollten im Netzwerk unterschiedlich priorisiert werden, da beispielsweise ein VoIP-Telefonat oder ein Livestream eine stabilere Verbindung braucht als das Laden einer statischen Website. Um diese Priorisierung zu ermöglichen, wird das Feature "Traffic Shaping" eingesetzt: Der Datenverkehr wird geshaped (umgeformt), sodass bei einem VoIP-Telefonat immer eine bestimmte (Rest-)Bandbreite garantiert ist.

Für die Standorte Wien Favoriten und Langenzersdorf ist folgendes Shaping vorgesehen:
- VoIP-Telefonate bekommen die höchste Prioritätsstufe und haben einen garantiere Bandbreite von 300kbps.
- Youtube-Streaming bekommt die mittlere Prioritätsstufe und hat einen garantierte Bandbreite von 1500kbps (Hat aber Nachrang bei wenig Bandbreite und aktivem VoIP-Traffic!).
- Der restliche Datenverkehr bekommt die niedrigste Prioritätsstufe und hat somit die restliche Bandbreite, es wird hierbei keine Bandbreite garantiert.

Traffic Shaping muss eigenen Firewall-Policies zugewiesen werden, damit es aktiv ist. Bevor es jedoch zugewiesen wird, sollten die Shaping-Stufen konfiguriert werden. Standardmäßig sind die Stufen `high-priority`, `medium-priority` und `low-priorty` vorkonfiguriert, ihre Parameter können jedoch angepasst werden.

#htl3r.code(caption: "Die Konfiguration der Traffic-Shaping-Stufen", description: none)[
```fortios
# voip high prio (medium band)
# youtube medium prio (viel band)
# rest low prio (der rest? band)
config firewall shaper traffic-shaper
    edit high-priority
        set per-policy enable
        set priority high
        set bandwidth-unit kbps
        set guaranteed-bandwidth 300
        set maximum-bandwidth 1000000
    next
    edit medium-priority
        set per-policy enable
        set priority medium
        set bandwidth-unit kbps
        set guaranteed-bandwidth 1500
        set maximum-bandwidth 1000000
    next
    edit low-priority
        set per-policy enable
        set priority low
        set bandwidth-unit kbps
        set maximum-bandwidth 1000000
    next
end
```
]

#htl3r.code(caption: "Die Shaping-Policies, die auf den Shaping-Stufen aufbauen", description: none)[
```fortios
config firewall shaping-policy
    edit 1
        set name VOIP
        set status enable
        set ip-version 4
        set service FINGER H323
        set srcaddr "IP-Phone-Langenzersdorf"
        set dstaddr "IP-Phone-Favoriten"
        set dstintf VLAN_42
        set traffic-shaper high-priority
    next
    edit 2
        set name YT
        set status enable
        set ip-version 4
        set srcaddr "Dorf-L-Workstations" "Dorf-W-Workstations"
        set srcintf VLAN_10 VLAN_20
        set dstintf port1
        set internet-service enable
        set internet-service-name Google-Web
        # YTs app ID
        set application 16040
        set traffic-shaper medium-priority
    next
end
```
]

=== Webfilter

Ein Webfilter ist eine Art der DPI, bei welcher HTTP(S)-Packets auf die abgefragte URL untersucht und je nach Webfilter-Policy blockiert bzw. akzeptiert werden. Somit lassen sich z.B. unerlaubte Inhalte blockieren, damit die Client-PCs im Firmennetzwerk keinen Zugriff auf ablenkende Inhalte während der Arbeitszeit haben.

Je nach Standort werden unterschiedliche Websiten blockiert. Während in Wien X (ehem. Twitter) und die Website der HTL Spengergasse blockiert sind, sind in Langenzersdorf ebenfalls X aber dazu die Website der HTL Rennweg blockiert.


#htl3r.code(caption: "URL-Filter für X.com und www.spengergasse.at", description: none)[
```fortios
config webfilter urlfilter
    edit 1
        set name "webfilter"
        config entries
            edit 1
                set url "*x.com"
                set type wildcard
                set action block
            next
            edit 2
                set url "www.spengergasse.at"
                set type simple
                set action block
            next
        end
    next
end```
]

#htl3r.code(caption: "Das Webfilter-Profile für die Aktivierung der URL-Filter", description: none)[
```fortios
config webfilter profile
    edit "webprofile"
        config web
            set urlfilter-table 1
        end
        config ftgd-wf
        end
    next
end```
]

#htl3r.author("Julian Burger")
== PfSense

Eine PfSense-Firewall ist eine kostenlose und software-basierte Alternative zu herkömmlichen Hardware-Firewalls von Herstellern wie Cisco oder Fortinet.

#htl3r.author("David Koch")
== Cisco Router

Um die Anforderungen einer FlexVPN-Verbindung zu erfüllen, wurden kleinere Standorte erstellt, welche als Firewall lediglich einen Cisco Router haben, da Features wie FlexVPN Cisco-proprietär sind.

=== FlexVPN

FlexVPN ist Ciscos Lösung um die Aufsetzung von VPNs zu vereinfachen und deckt fast alle VPN-Arten ab, unter anderem z.B. site-to-site, hub-and-spoke (inklusive spoke-to-spoke) und remote access VPNs. Ein weiteres Feature von FlexVPN ist, dass es IKEv2 für alle VPN-Arten nutzt und somit eine gewisse Sicherheit voraussetzt.

In unserer Topologie wird ein PSK-basierter site-to-site FlexVPN mit "Smart Defaults" genutzt, welcher über einen GRE-Tunnel läuft. Er verbindet die privaten Addressbereiche der "Flex"-Standorte.

"Smart Defaults" bieten vordefinierte Werte für die IKEv2-Konfiguration, die auf den Best Practices basieren. Sie beinhalten alles bis auf die folgenden IKEv2-Konfigurationen:
- IKEv2 profile
- IKEv2 keyring

Das heißt, dass folgende Konfigurationen übersprungen werden können:
- IKEv2 proposal
- IKEv2 policy
- IPSec transform-set
- IPSec profile

#htl3r.code-file(
  caption: "FlexVPN-Konfiguration auf R-Flex-Edge-1",
  filename: [scripts/cisco/R-Flex-Edge-1],
  ranges: ((42, 65),),
  lang: "cisco",
  text: read("../../scripts/cisco/R-Flex-Edge-1.txt")
)

=== MPLS Overlay VPN

Falls der Kunde bzw. Standortinhaber die privaten Addressbereiche seiner Standorte per VPN verknüpft haben möchte aber auf seinen Edge-Routern oder Firewalls keinen eigenen VPN-Tunnel konfigurieren möchte, kann vom Betreiber des Backbones ein MPLS Overlay VPN eingesetzt werden.

In unserer Topologie ist diese Art von VPN im AS666 -- zwischen den Routern XXX und YYY --- realisiert. Folgende Konfigurationsschritte sind für einen MPLS Overlay VPN nötig:
- Im Backbone wird MPLS zur Datenübertragung verwendet
- Die Border-Router haben VRFs für die Verbindung der Standorte
- Die Edge-Router der Standorte peeren mit den Border-Routern über BGP
- In der BGP-Konfiguration der Border-Router werden die Edge-Router in der Addressfamilie "VPNv4" als Nachbarn angegeben