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

#htl3r.code(caption: "Das UDP-Packet für den DoS-Angriff auf die S7-1200", description: none)[
```python
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
end```
]

=== DHCP

=== VPNs

=== Captive Portal

=== SSL Inspection

=== Traffic Shaping

=== Webfilter

Ein Webfilter ist eine Art der DPI, bei welcher HTTP(S)-Packets auf die abgefragte URL untersucht und je nach Webfilter-Policy blockiert bzw. akzeptiert werden. Somit lassen sich z.B. unerlaubte Inhalte blockieren, damit die Client-PCs im Firmennetzwerk keinen Zugriff auf ablenkende Inhalte während der Arbeitszeit haben.

Je nach Standort werden unterschiedliche Websiten blockiert. Während in Wien X (ehem. Twitter) und die Website der HTL Spengergasse blockiert sind, sind in Langenzersdorf ebenfalls X aber dazu die Website der HTL Rennweg blockiert.


#htl3r.code(caption: "Das UDP-Packet für den DoS-Angriff auf die S7-1200", description: none)[
```python
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

#htl3r.code(caption: "Das UDP-Packet für den DoS-Angriff auf die S7-1200", description: none)[
```python
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

Um die Anforderungen einer FlexVPN-Verbindung zu erfüllen, wurden kleinere Standorte erstellt, welche als Firewall lediglich einen Cisco Router haben, da FlexVPN Cisco-proprietär ist.

=== FlexVPN

#htl3r.code-file(
  caption: "FlexVPN-Konfiguration auf R-Flex-Edge-1",
  filename: [scripts/cisco/R-Flex-Edge-1],
  ranges: ((42, 65),),
  lang: "python",
  text: read("../../scripts/cisco/R-Flex-Edge-1.txt")
)
