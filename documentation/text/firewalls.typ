#import "@preview/htl3r-da:1.0.0" as htl3r

= Firewalls

#htl3r.author("David Koch")
== FortiGate <fortigate>

Die Firma Fortinet ist einer der Weltmarktführer im Bereich Firewalls mit ihrer Reihe an FortiGate-Firewalls. Sie bieten nicht nur physische Modelle, sondern auch virtuelle Instanzen. In der Topologie werden insgesamt drei solcher virtuellen FortiGates eingesetzt, um eine industrienahe Firewall-Implementierung mit SOTA-Features erreichen.

In der Topologie sind insgesamt drei FortiGate-Firewalls zu finden:
- Fav-FW-1 und Fav-FW-2 am Standort Wien Favoriten
- Dorf-FW am Standort Langenzersdorf

Für die Addressbereiche der Peering- oder der Standort-Netzwerke siehe @backbone und @standorte.

Bei der Umsetzung der hier aufgelisteten Features wurde immer nur die CLI verwendet. Das Web-Dashboard dient nur der Überprüfung und der Veranschaulichung der Konfiguration.

=== Grundkonfiguration

#htl3r.code(caption: "Grundkonfiguration der Fav-FW-1", description: none)[
```fortios
config system global
    set hostname Fav-FW-1
    set admintimeout 30
    set timezone 26
end
```
]

=== Interfaces

Bevor die Implementierung von den Firewall-Features auf der FortiGate stattfinden kann, müssen -- wie auf allen anderen Netzwerkgeräten auch -- zuerst die Netzwerkinterfaces konfiguriert werden.

#htl3r.code(caption: "Interface-Konfigurationsbeispiele auf Fav-FW-1", description: none)[
```fortios
config system interface
    edit port3
        set desc "Used to enroll VM license OOB"
        set mode static
        set ip 192.168.0.100 255.255.255.0
        set allowaccess ping http https
    next
    edit port1
        set desc "to_R_AS21_Peer"
        set mode static
        set ip 103.152.126.1 255.255.255.0
        set role wan
        set allowaccess ping
    next
...
edit "Dorf_VPN_GW_LB"
        set vdom root
        set ip 125.152.103.1 255.255.255.255
        set allowaccess ping
        set type loopback
    next
    edit VLAN_10
        set desc "Linux Clients"
        set vdom root
        set interface port2
        set type vlan
        set vlanid 10
        set mode static
        set ip 192.168.10.254 255.255.255.0
        set allowaccess ping
    next
...
end
```
]

=== Lizensierung



=== Policies

Eines der wichtigsten Werkzeuge, die eine FortiGate -- wie viele andere Firewalls auch -- bietet, sind Policies. Standardmäßig lässt eine FortiGate-Firewall keinerlei Datenverkehr durch, ein "implicit deny" wird verwendet. Es müssen durch den/die zuständige Netzwerkadministrator/in beim Einsatz einer FortiGate die nötigen Firewall-Policies "geschnitzt" werden, um den Datenverkehr auf das nötige Minimum einzuschränken, ohne dabei die Funktionalität des (bestehenden) Netzwerks zu beeinträchtigen.

#htl3r.code(caption: "Interface-Konfigurationsbeispiele auf Fav-FW-1", description: none)[
```fortios
config firewall policy
    edit 20
        set name "Windows_Clients_to_Servers"
        set srcintf VLAN_20
        set dstintf VLAN_200
        set srcaddr all
        set dstaddr all
        set action accept
        set schedule "always"
        set service "ALL"
    next
end
```
]

#htl3r.code(caption: "Interface-Konfigurationsbeispiele auf Fav-FW-1", description: none)[
```fortios
config firewall policy
    edit 24
        set name "Windows_PAW_to_Jump"
        set srcintf VLAN_20
        set dstintf VLAN_210
        set srcaddr "PAW"
        set dstaddr all
        set action accept
        set schedule "always"
        set service "RDP"
    next
end
```
]

#htl3r.code(caption: "Interface-Konfigurationsbeispiele auf Fav-FW-1", description: none)[
```fortios
config firewall policy
    edit 150
        set name "Bastion_to_Windows_Devices"
        set srcintf VLAN_150
        set dstintf VLAN_20 VLAN_200
        set srcaddr "Bastion"
        set dstaddr all
        set action accept
        set schedule "always"
        set service "SSH"
    next
end
```
]

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

#htl3r.code(caption: "Konfiguration des HA Clusters auf Fav-FW-1", description: none)[
```fortios
config system ha
    set mode a-a
    set group-id 1
    set group-name Koch_Burger_LBT_Cluster
    set password ganzgeheim123!
    set hbdev port9 10 port10 20
    set override enable
    set priority 200
end
```
]

Nachdem auf beiden Geräten die richtige Konfiguration vorgenommen worden ist, beginnen sie die gegenseitige Synchronisation ihrer gesamten Konfigurationen.

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

Für die automatische Zuweisung von IP-Adressen an die Client-Computer wurde auf der FortiGate DHCP konfiguriert. Da manche Clients trotz automatischer IP-Zuweisung dauerhaft die gleiche IP brauchen, z.B. für bestimmte Firewall-Policies, wird zum DHCP-Pool dazu ein Static-Lease für die PAW erstellt.

#htl3r.code(caption: "DHCP-Server-Konfiguration für VLAN 20 (inkl. Static Lease)", description: none)[
```fortios
config sys dhcp server
    edit 1
        set status enable
        set lease-time 86400
        set vci-match disable
        set interface VLAN_20
        set dns-server1 192.168.200.1
        set dns-server2 192.168.200.2
        set domain "corp.gartenbedarf.com"
        set default-gateway 192.168.20.254
        set netmask 255.255.255.0
        config ip-range
            edit 1
                set start-ip 192.168.20.10
                set end-ip 192.168.20.15
            next
        end
        config reserved-address
            edit 1
                set type mac
                set ip 192.168.20.10
                set mac 01:23:45:67:89:AB
                set action assign
                set description "Static Lease .10 for PAW (Workstation-1)"
            next
        end
    next
end
```
]

=== VPNs

Alle VPNs auf den FortiGates sind PSK-basiert.

==== Site-to-Site IPsec VPN

für loopback bgp verteilung: @fgt-bgp.

==== RAS-VPN

=== Captive Portal

Bevor die Windows Clients (in VLAN 20) externe Hosts und Dienste erreichen können, müssen sie sich über ein sogenanntes "Captive Portal" bei der Firewall authentifizieren. Für die Authentifizierung wird der AD-integrierte NPS-Server genutzt, als Protokoll wird hierbei RADIUS verwendet.

Um eine "Captive Portal"-Authentifizierung auf einer FortiGate-Firewall zu konfigurieren, AAAAAA:




#htl3r.fspace(
  figure(
    image("../images/screenshots/Screenshot 2025-02-19 130103.png"),
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

Shaping-Policies gehören konfigurationstechnisch nicht zu den "normalen" Policies, sie müssen mit dem Befehl `config firewall shaping-policy` erstellt werden:

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

=== BGP <fgt-bgp>



=== Sonstiges

==== Adressobjekte und Adressgruppen

==== Lokale Benutzer

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

#htl3r.code(caption: "FlexVPN-Konfiguration auf R-Flex-Edge-1", description: none)[
```cisco
crypto ikev2 keyring mykeys
peer R-Flex-Edge-2
address 13.52.124.1
pre-shared-key IchMussFlexen!
ex

crypto ikev2 profile default
match identity remote address 13.52.124.1 255.255.255.255 
authentication local pre-share
authentication remote pre-share
keyring local mykeys
dpd 60 2 on-demand
ex

crypto ipsec profile default
set ikev2-profile default
ex

int tun0
ip address 10.20.69.1 255.255.255.0
tunnel source g0/3
tunnel destination 13.52.124.1
tunnel protection ipsec profile default
ex```
]

=== MPLS Overlay VPN <mpls-vpn>

Falls der Kunde bzw. Standortinhaber die privaten Addressbereiche seiner Standorte per VPN verknüpft haben möchte aber auf seinen Edge-Routern oder Firewalls keinen eigenen VPN-Tunnel konfigurieren möchte, kann vom Betreiber des Backbones ein MPLS Overlay VPN eingesetzt werden.

In unserer Topologie ist diese Art von VPN im AS666 -- zwischen den Border-Routern R-AS666-Peer-2 und R-AS666-Peer-4 -- realisiert. Folgende Konfigurationsschritte sind für einen MPLS Overlay VPN nötig:
- Im Backbone wird MPLS zur Datenübertragung verwendet.
- Die Border-Router haben VRFs für die Abkapselung der Routen bei Verbindung der Standorte.
- Die Edge-Router der Standorte peeren mit den Border-Routern über eBGP.
- In der BGP-Konfiguration der Border-Router werden die Edge-Router in der Addressfamilie "VPNv4" als Nachbarn angegeben.