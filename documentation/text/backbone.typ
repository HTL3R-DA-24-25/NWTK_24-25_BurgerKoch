#import "@preview/htl3r-da:0.1.0" as htl3r

#htl3r.author("David Koch")
= Backbone

== Addressbereiche

Zwischen den AS's werden als public IPs die für die Antarktis vorgesehenen IP-Ranges genutzt, somit sollte es auch bei einem Anschluss ans echte Internet keinen Overlap geben (hoffentlich)

Public-Peering-Adressbereiche:
- Zwischen AS100 (R-AS100-Peer-1) und AS666 (R-AS666-Peer-2): 154.30.31.0/30
- Zwischen AS666 (R-AS666-Peer-1) und AS20 (R-AS22-Peer): 45.84.107.0/30
- Zwischen AS20 (R-AS21-Peer) und AS100 (R-AS100-Peer-2): 103.152.127.0/30

Bei den Firewall-PoPs:
- R-AS100-Peer-1 zu Kebapci-FW: 31.25.11.0/24
- R-AS666-Peer-3 zu Dorf-FW: 87.120.166.0/24
- R-AS21-Peer und R-AS100-Peer-2 zu Fav-FWs (WIP): 103.152.126.0/24

== Autonome Systeme

Das Backbone besteht aus drei AS's.

=== AS20

Besteht aus den Sub-AS's 21 & 22, insgesamt 5 Router (2 in 21 und 3 in 22):
- R-AS21-Peer
- R-AS21-BB
- R-AS21-Internet
- R-AS22-Peer
- R-AS22-BB

Nutzt ein MPLS Overlay, OSPF Underlay

BGP Features:
- R-AS21-BB dient als Route-Reflector
- R-AS21-Internet teilt seine Default Route ins Internet den anderen Peers mit

Adressbereiche:
- 172.16.20.0/30
- 172.16.21.0/30
- 172.16.21.4/30
- 172.16.22.0/30

=== AS100

Besteht aus insgesamt nur 2 Routern:
- R-AS100-Peer-1
- R-AS100-Peer-2

Braucht kein Overlay/Underlay, nur BGP weil 2 Router

BGP Features:
- Distribution Lists (Traffic von Burger-FW wird auf allen Border-Routern blockiert)

Addressbereiche:
- 192.168.100.0/30

=== AS666

Besteht aus 12 Routern und 2 L2-Switches:
- R-AS666-Peer-1
- R-AS666-Peer-2
- R-AS666-Peer-3
- R-AS666-BB-1
- R-AS666-BB-2
- R-AS666-BB-3
- R-AS666-BB-4
- R-AS666-BB-5
- R-AS666-BB-6
- R-AS666-BB-7
- R-AS666-BB-8
- R-AS666-BB-9
- SW-AS666-BB-1
- SW-AS666-BB-2

Nutzt ein GRE & RIP Overlay, OSPF Underlay

BGP Features:
- Pfadmanipulation mittels Local Preference von 100 auf 300 -> Traffic für den Standort Favoriten innerhalb AS666 immer über R-AS666-Peer-2 an AS100 ausschicken statt AS20
- Prefix-List die alle Bogon-Adressen enthält auf die eBGP-Neighbors inbound angewendet werden, um Bogons zu blockieren

Adressbereiche:
- 10.6.66.0/30
- 10.6.66.4/30
- 10.6.66.8/30
- 10.6.66.12/29
- 10.6.66.20/30
- 10.6.66.24/30
- 10.6.66.28/30
- 10.6.66.32/30
- 10.6.66.36/30
- 10.6.66.40/30
- 10.6.66.44/30
- 10.6.66.48/30
- 10.6.66.52/29

== Dynamisches Routing

OSPF, RIP, BGP

=== Authentifizierung

Jegliche Instanzen von OSPF, RIP und BGP im Backbone nutzen Authentifizierung für ihre Updates.

*OSPF:*
- Key-String: ciscocisco
- Algorithmus: hmac-sha-512

*RIP:*
- Key-String: ganzgeheim123!
- Algorithmus: dsa-2048

*BGP:*
- Key-String: BeeGeePee!?
- Algorithmus: ecdsa-384

== Statisches Routing

blabla zu kunden Favoriten

Alternative: Firewall der Kunden haben eine BGP-Peering mit Border-Routern im Backbone