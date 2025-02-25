#import "@preview/htl3r-da:1.0.0" as htl3r

#htl3r.author("David Koch")
= Backbone <backbone>

== Namenskonvention

Alle Geräte im Backbone sind nach der folgenden Namenskonvention benannt:

[SW/R]-AS[Nr]-[BB/Peer/Internet]-[Nr]

Beispiele mit Erklärung:
- R-AS100-Peer-2: Der zweite eBGP-Peering Router im AS 100

- SW-AS666-BB-1: Der erste Switch im Backbone von AS 666

== Addressbereiche

Zwischen den AS's werden als public IPs die für die Antarktis vorgesehenen IP-Ranges genutzt, somit sollte es auch bei einem Anschluss ans echte Internet keinen Overlap geben. Den einzigen Overlap, den es bei der Umsetzung gegeben hat, war mit einem Starlink-Adressbereich.

Public-Peering-Adressbereiche:
- Zwischen AS100 (R-AS100-Peer-1) und AS666 (R-AS666-Peer-2): 154.30.31.0/30
- Zwischen AS666 (R-AS666-Peer-1) und AS20 (R-AS22-Peer): 45.84.107.0/30
- Zwischen AS20 (R-AS21-Peer) und AS100 (R-AS100-Peer-2): 103.152.127.0/30

Bei den Firewall-#htl3r.shortpl[pop]:
- R-AS100-Peer-1 zu Kebapci-FW: 31.25.11.0/24
- R-AS666-Peer-3 zu Dorf-FW: 87.120.166.0/24
- R-AS21-Peer zu Fav-FW-1: 103.152.126.0/24
- R-AS100-Peer-2 zu Fav-FW-2: 103.152.125.0/24
- R-AS666-Peer-1 zu Burger-FW: 31.6.14.0/24
- R-AS666-Peer-3 zu R-Flex-Edge-1: 78.12.166.0/24
- R-AS100-Peer-2 zu R-Flex-Edge-2: 13.52.124.0/24
- R-AS666-Peer-2 zu R-Armut-Edge-1: 31.25.42.0/24
- R-AS666-Peer-4 zu R-Armut-Edge-2: 31.6.28.0/24

Öffentliches Loopback für eine problemlose Kombination von HA-Clustering und VPN-Endpoint:
- Fav-FW: 125.152.103.1/32

== Autonome Systeme

Das Backbone besteht aus drei AS's.

=== AS20

Besteht aus den Sub-AS's 21 & 22, insgesamt 5 Router (2 in 21 und 3 in 22):
- R-AS21-Peer
- R-AS21-BB
- R-AS21-Internet
- R-AS22-Peer
- R-AS22-BB

Nutzt ein #htl3r.short[mpls] Overlay, #htl3r.short[ospf] Underlay

#htl3r.short[bgp] Features:
- R-AS21-BB dient als Route-Reflector
- R-AS21-Internet teilt seine Default Route ins Internet den anderen Peers mit

#align(center, table(
  columns: 5,
  align: left,
  table.cell(rowspan: 2, [*Netzadresse*]), table.cell(rowspan: 2, [*Subnetzprefix*]), table.cell(colspan: 3, [*Verbundene Geräte*]), [_*Hostname*_], [_*Adresse*_], [_*Interface*_],
  table.cell(rowspan: 2, "172.16.20.0"), table.cell(rowspan: 2, "30"), [R-AS21-BB], [.1], [Gig0/0], [R-AS22-BB], [.2], [Gig0/0],
  table.cell(rowspan: 2, "172.16.21.0"), table.cell(rowspan: 2, "30"), [R-AS21-Peer], [.1], [Gig0/1], [R-AS21-BB], [.2], [Gig0/1],
  table.cell(rowspan: 2, "172.16.21.4"), table.cell(rowspan: 2, "30"), [R-AS21-Internet], [.5], [Gig0/2], [R-AS21-BB], [.6], [Gig0/2],
  table.cell(rowspan: 2, "172.16.22.0"), table.cell(rowspan: 2, "30"), [R-AS22-Peer], [.1], [Gig0/1], [R-AS22-BB], [.2], [Gig0/1],
))

* TODO: Loopback *

=== AS100

Besteht aus insgesamt nur 2 Routern:
- R-AS100-Peer-1
- R-AS100-Peer-2

Braucht kein Overlay/Underlay, nur i#htl3r.short[bgp] weil das AS aus lediglich zwei Routern besteht.

#htl3r.short[bgp] Features:
- Distribution Lists (Traffic von Burger-FW wird auf allen Border-Routern blockiert)

#align(center, table(
  columns: 5,
  align: left,
  table.cell(rowspan: 2, [*Netzadresse*]), table.cell(rowspan: 2, [*Subnetzprefix*]), table.cell(colspan: 3, [*Verbundene Geräte*]), [_*Hostname*_], [_*Adresse*_], [_*Interface*_],
  table.cell(rowspan: 2, "192.168.100.0"), table.cell(rowspan: 2, "30"), [R-AS100-Peer-1], [.1], [Gig0/1], [R-AS100-Peer-2], [.2], [Gig0/1],
))

* TODO: Loopback *

=== AS666

Besteht aus 13 Routern und 2 L2-Switches:
- R-AS666-Peer-1
- R-AS666-Peer-2
- R-AS666-Peer-3
- R-AS666-Peer-4
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

Nutzt ein #htl3r.short[ospf] Underlay mit #htl3r.short[mpls] als Overlay.

#htl3r.short[bgp] Features:
- Pfadmanipulation mittels Local Preference von 100 auf 300 -> Traffic für den Standort Favoriten innerhalb AS666 immer über R-AS666-Peer-2 an AS100 ausschicken statt AS20
- Prefix-List die alle Bogon-Adressen enthält auf die e#htl3r.short[bgp]-Neighbors inbound angewendet werden, um Bogons zu blockieren

#align(center, table(
  columns: 5,
  align: left,
  table.cell(rowspan: 2, [*Netzadresse*]), table.cell(rowspan: 2, [*Subnetzprefix*]), table.cell(colspan: 3, [*Verbundene Geräte*]), [_*Hostname*_], [_*Adresse*_], [_*Interface*_],
  table.cell(rowspan: 2, "10.6.66.0"), table.cell(rowspan: 2, "30"), [R-AS666-Peer-2], [.1], [Gig0/1], [R-AS666-BB-1], [.2], [Gig0/1],
  table.cell(rowspan: 2, "10.6.66.4"), table.cell(rowspan: 2, "30"), [R-AS666-BB-1], [.5], [Gig0/0], [R-AS666-BB-2], [.6], [Gig0/0],
  table.cell(rowspan: 2, "10.6.66.8"), table.cell(rowspan: 2, "30"), [R-AS666-BB-2], [.9], [Gig0/1], [R-AS666-BB-3], [.10], [Gig0/1],
  table.cell(rowspan: 2, "10.6.66.20"), table.cell(rowspan: 2, "30"), [R-AS666-Peer-3], [.21], [Gig0/0], [R-AS666-BB-4], [.22], [Gig0/0],
  table.cell(rowspan: 2, "10.6.66.24"), table.cell(rowspan: 2, "30"), [R-AS666-Peer-3], [.25], [Gig0/2], [R-AS666-BB-5], [.26], [Gig0/2],
  table.cell(rowspan: 2, "10.6.66.28"), table.cell(rowspan: 2, "30"), [R-AS666-BB-5], [.29], [Gig0/3], [R-AS666-BB-6], [.30], [Gig0/3],
  table.cell(rowspan: 2, "10.6.66.32"), table.cell(rowspan: 2, "30"), [R-AS666-BB-6], [.33], [Gig0/2], [R-AS666-BB-7], [.34], [Gig0/2],
  table.cell(rowspan: 2, "10.6.66.36"), table.cell(rowspan: 2, "30"), [R-AS666-BB-6], [.37], [Gig0/0], [R-AS666-BB-8], [.38], [Gig0/0],
  table.cell(rowspan: 2, "10.6.66.40"), table.cell(rowspan: 2, "30"), [R-AS666-BB-7], [.41], [Gig0/1], [R-AS666-BB-9], [.42], [Gig0/1],
  table.cell(rowspan: 2, "10.6.66.44"), table.cell(rowspan: 2, "30"), [R-AS666-BB-8], [.45], [Gig0/3], [R-AS666-BB-9], [.46], [Gig0/3],
  table.cell(rowspan: 2, "10.6.66.48"), table.cell(rowspan: 2, "30"), [R-AS666-BB-9], [.49], [Gig0/2], [R-AS666-Peer-1], [.50], [Gig0/2],
  table.cell(rowspan: 3, "10.6.66.104"), table.cell(rowspan: 3, "29"), [R-AS666-BB-3], [.105], [Gig0/0], [R-AS666-BB-4], [.106], [Gig0/1], [R-AS666-BB-8], [.107], [Gig0/2],
  table.cell(rowspan: 3, "10.6.66.112"), table.cell(rowspan: 3, "29"), [R-AS666-Peer-1], [.113], [Gig0/3], [R-AS666-BB-2], [.114], [Gig0/2], [R-AS666-BB-9], [.115], [Gig0/0],
  table.cell(rowspan: 2, "10.6.66.200"), table.cell(rowspan: 2, "30"), [R-AS666-Peer-4], [.201], [Gig0/0], [R-AS666-BB-7], [.202], [Gig0/0],
))

* TODO: Loopback *

== Dynamisches Routing

Für den automatischen Routenaustausch innerhalb von den Backbone-Netzwerken werden die dynamischen Routingprotokolle #htl3r.short[ospf] und #htl3r.short[rip] verwendet. Für den externen Routenaustausch zwischen #htl3r.shortpl[as] wird #htl3r.short[bgp] verwendet.

=== Authentifizierung

Jegliche Instanzen von #htl3r.short[ospf] und #htl3r.short[rip] im #htl3r.short[as]666 nutzen Authentifizierung für ihre Updates.

*OSPF:*
- Key-String: ciscocisco
- Algorithmus: hmac-sha-512

#htl3r.code(caption: "Authenticated OSPF-Updates mittels Key-Chain", description: none)[
```ciscoios
key chain 1
key 1
key-string ciscocisco
cryptographic-algorithm hmac-sha-512
ex

int g0/1
ip ospf authentication key-chain 1
ex
```
]

*RIP:*
- Key-String: ganzgeheim123!
- Algorithmus: dsa-2048

#htl3r.code(caption: "Authenticated RIP-Updates mittels Key-Chain", description: none)[
```ciscoios
key chain 2
key 1
key-string ganzgeheim123!
cryptographic-algorithm hmac-sha-384
ex

int tunnel1
ip rip authentication key-chain 2
ex
```
]

*BGP:*
- Key-String: BeeGeePee!?
- Algorithmus: ecdsa-384

== Statisches Routing

Damit Traffic zu den Firewalls vom Standort Wien Favoriten findet, wird nicht nur die Loopback-Adresse von den Fav-FWs von R-AS21-Peer und R-AS100-Peer-2 advertised, sondern es wird auf den zwei Geräten ebenfalls eine statische Route konfiguriert, weil sie sonst die Loopback-Adresse nicht finden/erreichen können.

*Alternative:* Firewalls der Kunden haben ein  #htl3r.short[bgp]-Peering mit Border-Routern im Backbone, um ihr Loopback per e#htl3r.short[bgp] bekanntzugeben.

Es wird ebenfalls eine statische Route auf R-AS21-Internet verwendet, um allen anderen Geräten in der Topologie einen Zugang zum Internet per #htl3r.short[nat]-Cloud zu ermöglichen.
