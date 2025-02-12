#import "@preview/htl3r-da:0.1.0" as htl3r

= Standorte <standorte>

== Wien Favoriten

Wien Favoriten ist der Hauptstandort der Gartenbedarfs GmbH und somit auch der größte.

== Langenzersdorf

Langenzersdorf ist der Nebenstandort der Gartenbedarfs GmbH und ist der zweitgrößte Standort in der Topologie.

== Kebapci

== Praunstraße

#htl3r.fspace(
  total-width: 35%,
  figure(
    image("../../images/topology/standorte/praunstrasse.png"),
    caption: [Der Standort Praunstraße]
  )
)

#htl3r.author("David Koch")
== Flex-Standorte

Die Flex-Standorte dienen lediglich der Implementierung eines FlexVPN-Tunnels. Deswegen bestehen sie jeweils nur aus zwei Geräten: Einem Cisco Router als "Firewall" und einem #htl3r.short[vpcs] für Ping-Tests.
 
#htl3r.fspace(
  total-width: 40%,
  figure(
    image("../../images/topology/standorte/flex_standort_2.png"),
    caption: [Der zweite Flex-Standort]
  )
)

== Armut-Standorte

#htl3r.fspace(
  total-width: 55%,
  figure(
    image("../../images/topology/standorte/armut_standort_1.png"),
    caption: [Der erste Armut-Standort]
  )
)