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

Zur Überprüfung kann der Befehl `get system ha status` verwendet werden:
#htl3r.fspace(
  figure(
    image("../images/screenshots/Screenshot 2025-03-12 130910_1.png"),
    caption: [Ausgabe des `get system ha status` Befehls (oberer Teil)]
  )
)

#htl3r.fspace(
  figure(
    image("../images/screenshots/Screenshot 2025-03-12 130910_2.png"),
    caption: [Ausgabe des `get system ha status` Befehls (unterer Teil)]
  )
)

=== NAT

Damit die alle Client-PCs als auch manche Server der Standorte Wien Favoriten und Langenzersdorf die öffentlichen Adressen im LBT-Netzwerk sowie das Internet erreichen können, braucht es eine Art von NAT bzw. PAT.

#htl3r.code(caption: "Der NAT-Pool für den Standort Wien Favoriten", description: none)[
```fortios
config firewall ippool
    edit "NAT_Public_IP_Pool"
        set startip 103.152.126.69
        set endip 103.152.126.69
        set type one-to-one
    next
end
```
]

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

Alle VPNs auf den FortiGates sind PSK-basiert. Es wurden folgende VPNs implementiert:
- site-to-site VPN zwischen Wien Favoriten und Langenzersdorf (FortiGate zu FortiGate)
- site-to-site VPN zwischen Langenzersdorf und Kebapci (FortiGate zu PfSense)
- RAS-VPN für Wien Favoriten
- Wireguard-VPN (RAS) für Wien Favoriten, siehe @wireguard.

Da es zwei VPN-Endpunkte für Favoriten gibt (Fav-FW-1 und Fav-FW-2), muss ein "künstlicher" Endpunkt erstellt werden, welcher beide Geräte repräsentiert: Eine gemeinsame Loopback-Adresse. Für Details zu der Verteilung dieser Loopback-Adresse an das öffentlich Netz siehe @fgt-bgp.

==== Site-to-Site IPsec VPN <s2s-vpn>

Um die Standorte Favoriten, Langenzersdorf und "Kebapci" miteinander zu verknüpfen, das heißt, dass sich die Geräte gegenseitig über ihre privaten Adressen erreichen können, werden zwei site-to-site IPsec VPNs eingesetzt. Beide VPN-Tunnel münden am Standort Langenzersdorf, denn dieser dient als "Verteiler", damit Geräte aus Favoriten (ohne eine direkte Tunnel-Anbindung zu haben) auch nach "Kebapci" kommen können.

Die folgenden Snippets sind aus der Sicht der Favoriten-Firewalls, d.h. es wird nur ein site-to-site Phase-1-Tunnel-Interface nach Langenzersdorf konfiguriert (ACHTUNG: Es braucht jedoch trotzdem ZWEI Phase-2-Interfaces!):

#htl3r.code(caption: "Konfiguration des site-to-site VPNs von Favoriten nach Langenzersdorf", description: none)[
```fortios
config vpn ipsec phase1-interface
    edit "VPN_to_Lang"
        set interface "Dorf_VPN_GW_LB"
        set ike-version 2
        set peertype any
        set net-device disable
        set proposal aes128-sha256 aes256-sha256 aes128gcm-prfsha256 aes256gcm-prfsha384 chacha20poly1305-prfsha256
        set remote-gw 87.120.166.1
        set psksecret TesterinoKoch123!
    next
end

...

config vpn ipsec phase2-interface
    edit "VPN_to_Lang"
        set phase1name "VPN_to_Lang"
        set proposal aes128-sha1 aes256-sha1 aes128-sha256 aes256-sha256 aes128gcm aes256gcm chacha20poly1305
        set auto-negotiate enable
        set src-addr-type name
        set dst-addr-type name
        set src-name Favoriten_LOCAL
        set dst-name Langenzersdorf_REMOTE
    next
    edit "VPN_to_Kebapci"
        set phase1name "VPN_to_Lang"
        set proposal aes128-sha1 aes256-sha1 aes128-sha256 aes256-sha256 aes128gcm aes256gcm chacha20poly1305
        set auto-negotiate enable
        set src-addr-type name
        set dst-addr-type name
        set src-name Favoriten_LOCAL
        set dst-name Kebapci_REMOTE
    next
end

...

config firewall policy
    edit 3
        set name "site-to-site VPN inbound DORF"
        set srcintf "VPN_to_Lang"
        set dstintf "port2" "VLAN_10" "VLAN_20" "VLAN_21" "VLAN_30" "VLAN_31" "VLAN_100" "VLAN_150" "VLAN_200" "VLAN_210"
        set srcaddr "Langenzersdorf_REMOTE" "Kebapci_REMOTE"
        set dstaddr "Favoriten_LOCAL"
        set action accept
        set schedule "always"
        set service "ALL"
    next
    edit 4
        set name "site-to-site VPN outbound DORF"
        set srcintf "port2" "VLAN_10" "VLAN_20" "VLAN_21" "VLAN_30" "VLAN_31" "VLAN_100" "VLAN_150" "VLAN_200" "VLAN_210"
        set dstintf "VPN_to_Lang"
        set srcaddr "Favoriten_LOCAL"
        set dstaddr "Langenzersdorf_REMOTE" "Kebapci_REMOTE"
        set action accept
        set schedule "always"
        set service "ALL"
    next
    ...
end
```
]

==== RAS-VPN

Der RAS-VPN nach Wien Favoriten hat folgende Parameter:
- IKE-Version: v1
- Mode: Aggressive
- Erlaubte Proposals: AES256-SHA256, AES256-SHA1
- Erlaubte DH-Gruppen: 2, 5, 14
- VPN-Typ auf der FortiGate: "Dialup-Cisco"
- Peer-ID: 69420
- Split-Tunneling: aktiviert
- PSK: \_IUseArchBTW\_

#htl3r.code(caption: "Konfiguration der RAS-VPN Phase 1 und 2 Interfaces", description: none)[
```fortios
config vpn ipsec phase1-interface
    edit "RAS_for_Praun"
        set type dynamic
        set interface "Dorf_VPN_GW_LB"
        set mode aggressive
        set peertype one
        set net-device disable
        set mode-cfg enable
        set proposal aes256-sha256 aes256-sha1
        set comments "VPN: RAS_for_Praun (Created by VPN wizard)"
        set dhgrp 14 5 2
        set wizard-type dialup-cisco
        set xauthtype auto
        set authusrgrp "RAS_Group"
        set peerid "69420"
        set ipv4-start-ip 192.168.69.10
        set ipv4-end-ip 192.168.69.150
        set dns-mode auto
        set ipv4-split-include "RAS_for_Praun_split"
        set psksecret _IUseArchBTW_
    next
end

...

config vpn ipsec phase2-interface
    edit "RAS_for_Praun"
        set phase1name "RAS_for_Praun"
        set proposal aes256-sha256 aes256-md5 aes256-sha1
        set pfs disable
        set keepalive enable
        set comments "VPN: RAS_for_Praun (Created by VPN wizard)"
    next
end
```
]

Bei der Konfiguration des RAS-VPN muss noch zusätzlich eine eigene Firewall-Policy erstellt werden, um den Tunnel-Traffic durchzulassen. Die Konfiguration ähnelt stark der von den site-to-site VPN Policies in @s2s-vpn.

Der RAS-VPN wurde über die Burger-Workstation am Standort Praunstraße getestet. Es wurde zum Aufbau der Verbindung das Package `network-manager-vpnc` genutzt. Folgende Konfiguration des VPN-Interfaces wurde auf der Workstation vorgenommen:

#htl3r.fspace(
  total-width: 70%,
  figure(
    image("../images/screenshots/Screenshot 2025-02-25 120030.png"),
    caption: [NetworkManager-Konfiguration zur Nutzung des RAS-VPN]
  )
)

#htl3r.fspace(
  total-width: 70%,
  figure(
    image("../images/screenshots/Screenshot 2025-02-25 120049.png"),
    caption: [NetworkManager-Konfiguration zur Nutzung des RAS-VPN (erweitert)]
  )
)

=== Captive Portal

Bevor die Windows Clients (in VLAN 20) externe Hosts und Dienste erreichen können, müssen sie sich über ein sogenanntes "Captive Portal" bei der Firewall authentifizieren. Für die Authentifizierung wird der AD-integrierte NPS-Server genutzt, als Protokoll wird hierbei RADIUS verwendet.

Um eine "Captive Portal"-Authentifizierung auf einer FortiGate-Firewall zu konfigurieren, muss zuerst der NPS-Server in Form eines Benutzers konfiguriert werden:

#htl3r.code(caption: "Erstellung des 'AD-NPS' Benutzers für das Captive Portal", description: none)[
```fortios
config user radius
    edit "AD-NPS"
        set server "192.168.200.5"
        set secret cisco
    next
end
...
config user group
    edit "Captive_Portal"
        set member "AD-NPS"
    next
...
end
```
]

Nach der Erstellung des Benutzers und der Zuweisung zu einer eigenen (Security-)Gruppe kann auf dem gewünschten (Sub-)Interface die Captive-Portal-Authentifizierung aktiviert werden:

#htl3r.code(caption: "Zuweisung Captive Portal Gruppe zum Interface", description: none)[
```fortios
config sys interface
    edit VLAN_20
        set security-mode captive-portal
        set security-groups "Captive_Portal"
        set device-identification enable
    next
end
```
]

#htl3r.fspace(
  total-width: 90%,
  figure(
    image("../images/screenshots/Screenshot 2025-02-19 130103.png"),
    caption: [Die erfolgreiche Authentifizierung mit AD-Benutzer über RADIUS]
  )
)

=== SSL Inspection

HTTPS-Traffic verläuft zwischen den Endgeräten TLS-verschlüsselt, wodurch die Firewalls nicht den Datenverkehr auf Schadsoftware oder andere unerwünschte Inhalten überprüfen können. Die Lösung zu diesem Problem ist die sogenannte "SSL Inspection", der Datenverkehr wird von der Firewall entschlüsselt (Original-Zertifikat wird entfernt), geprüft und anschließend wieder verschlüsselt (neues Zertifikat wird eingefügt).

#htl3r.code(caption: "DHCP-Server-Konfiguration für VLAN 20 (inkl. Static Lease)", description: none)[
```fortios
config firewall ssl-ssh-profile
    edit custom-deep-inspection
        config ssl
            set inspect-all deep-inspection
            set client-certificate inspect
            set unsupported-ssl-version block
            set unsupported-ssl-cipher block
            set unsupported-ssl-negotiation block
            set expired-server-cert block
            set untrusted-server-cert block
            set cert-validation-timeout ignore
            set cert-validation-failure block
            set sni-server-cert-check strict
            set min-allowed-ssl-version tls-1.3
        end
        config https
            set client-certificate inspect
            set unsupported-ssl-version block
            set unsupported-ssl-cipher block
            set unsupported-ssl-negotiation block
        end
        set server-cert-mode re-sign
    next
end
```
]

Das Zertifikat kann klarerweise nicht direkt über die CLI eingespielt werden, also musste es nachträglich im Web-Dashboard der FortiGate hochgeladen werden:
#htl3r.fspace(
  figure(
    image("../images/screenshots/Screenshot 2025-02-19 180028.png"),
    caption: [Das hochgeladene Zertifikat der CA im FortiGate-Dashboard]
  )
)

Das im obigen Snippet sichtbare Inspection Profil "custom-deep-inspection" muss anschließend einem Interface (z.B. dem nach außen) zugewiesen werden.

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

Damit die gemeinsame Loopback-Adresse von Fav-FW-1 und Fav-FW-2 im öffentlichen Netz erreichbar bzw. bekannt ist, wird ein eBGP-Peering von den Firewalls zu den AS20 Border-Routern (103.152.125.254 und 103.152.126.254) verwendet. Die Firewalls etablieren somit den Standort Wien Favoriten als AS123.

#htl3r.code(caption: "BGP-Konfiguration auf den Firewalls von Wien Favoriten", description: none)[
```fortios
config router bgp
    set as 123
    config neighbor
        edit "103.152.126.254"
            set remote-as 20
            set update-source "port1"
        next
    end
    config neighbor
        edit "103.152.125.254"
            set remote-as 100
            set update-source "port5"
        next
    end
    config network
        edit 1
            set prefix 125.152.103.1 255.255.255.255
        next
    end
end```
]

=== Sonstiges

==== Adressobjekte und Adressgruppen

Für die Konfiguration von Policies und anderen Features auf der FortiGate können oft nicht direkt IP-Adressen bzw. Subnetze angegeben werden. Es müssen zuerst eigene Adressobjekte erstellt werden, die diese Subnetze enthalten, und diese können anschließend in der Policy eingetragen werden.

Zur Gruppierung von mehreren Adressobjekten können Adressgruppen verwendet werden.

Ein Beispiel für die Nutzung von Adressgruppen in unserer Topologie sind die Policies für die site-to-site VPNs, wo mittels Gruppen zwischen den Remote-VLAN-Subnetzen und den lokalen VLAN-Subnetzen unterschieden wird.

#htl3r.code(caption: "Einige der Adressobjekte für VLAN-Subnetze in Favoriten (+ Zuweisung zu Adressgruppe)", description: none)[
```fortios
config firewall address
    edit "Favoriten_VLAN_10"
        set allow-routing enable
        set subnet 192.168.10.0 255.255.255.0
    next
    edit "Favoriten_VLAN_20"
        set allow-routing enable
        set subnet 192.168.20.0 255.255.255.0
    next
    edit "Favoriten_VLAN_21"
        set allow-routing enable
        set subnet 192.168.21.0 255.255.255.0
    next
...
end

config firewall addrgrp
    edit "Favoriten_LOCAL"
        set allow-routing enable
        set member "Favoriten_VLAN_10" "Favoriten_VLAN_20" "Favoriten_VLAN_21" "Favoriten_VLAN_30" "Favoriten_VLAN_31" "Favoriten_VLAN_42" "Favoriten_VLAN_100" "Favoriten_VLAN_150" "Favoriten_VLAN_200" "Favoriten_VLAN_210"
        set comment "For site-to-site IPsec-VPN"
    next
    edit "Langenzersdorf_REMOTE"
        set allow-routing enable
        set member "Langenzersdorf_VLAN_10" "Langenzersdorf_VLAN_20" "Langenzersdorf_VLAN_30" "Langenzersdorf_VLAN_31" "Langenzersdorf_VLAN_100" "Langenzersdorf_VLAN_200"
        set comment "For site-to-site IPsec-VPN"
    next
    edit "Kebapci_REMOTE"
        set allow-routing enable
        set member "Kebapci_Subnet"
        set comment "For site-to-site IPsec-VPN"
    next
end
```
]

Bei der Blockierung von Bogons (outside-in) wird ebenfalls eine Adressgruppe eingesetzt.

==== Lokale Benutzer

Für die Authentifizierung bei der Nutzung des RAS-VPNs braucht es Benutzer, die lokal auf der FortiGate konfiguriert werden. Sie können ebenfalls als Alternative zu den Benutzern aus einer bestehenden AD-Struktur über den AD-NPS-Server für z.B. ein Captive Portal eingesetzt werden.

#htl3r.code(caption: "Erstellung des Benutzers 'JulianBurger' für den RAS-VPN", description: none)[
```fortios
config user local
    edit "JulianBurger"
        set type password
        set passwd JulianBurger
    next
end

config user group
...
    edit "RAS_Group"
        set member "JulianBurger"
    next
end
```
]

#htl3r.author("Julian Burger")
== PfSense

Eine PfSense-Firewall ist eine kostenlose und software-basierte Alternative zu herkömmlichen Hardware-Firewalls von Herstellern wie Cisco oder Fortinet.

Die Konfiguration einer PfSense erfolgt ausschließlich im GUI, hierbei musste nur der IPSec-VPN konfiguriert werden und das Subnet sowie DHCP für das LAN:
#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/screenshots/pfsense_dhcp.png"),
    caption: [PFSense DHCP]
  ),
  figure(
    image("../images/screenshots/pfsense_lan.png"),
    caption: [PFSense LAN Interface]
  )
)
#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/screenshots/pfsense_ipsec.png"),
    caption: [PFSense IPSec VPN]
  )
)

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

#htl3r.code(caption: "Konfiguration des MPLS-Overlay-VPNs auf R-AS666-Peer-2 (per VPNv4 Adressfamilie)", description: none)[
```cisco
ip vrf Armut-Customer-1
rd 42069:1
route-target both 42069:1
ex

int g0/3
desc to_Armut_Edge_1
ip vrf forwarding Armut-Customer-1
ip address 31.25.42.254 255.255.255.0
no shut 
ex

router bgp 666
network 31.25.42.0 mask 255.255.255.0
address-family vpnv4
neighbor 6.6.6.4 activate
neighbor 6.6.6.4 send-community extended
ex
address-family ipv4 vrf Armut-Customer-1
neighbor 31.25.42.1 remote-as 61
neighbor 31.25.42.1 update-source g0/3
neighbor 31.25.42.1 activate
neighbor 31.25.42.1 next-hop-self
ex
```
]