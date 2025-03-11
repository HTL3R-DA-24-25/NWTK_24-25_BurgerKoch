#import "@preview/htl3r-da:1.0.0" as htl3r

#htl3r.author("David Koch")
= Einführung

Dies ist die Dokumentation zur die "Little Big Topo" der 5ten Klasse im Ausbildungszweig Netzwerktechnik. In den folgenden Kapiteln wird ein Überblick über die eingesetzten Konzepte und die für ihre Umsetzung nötigen Konfigurationsschritte geboten.

== Firma Backstory
Gartenbedarfs GmbH

CEO: Huber "Huber" Huber

Verkauft u.a. die Rasensprengerköpfe "Sprühkönig" und "Sprengmeister" als auch den Stoff "Huberit".

Die Mitarbeiter der Gartenbedarfs GmbH gehen gerne in ihren Mittagspausen u.a. zu Kebapci futtern, aber die Gartenbedarfs GmbH ist heimlich mit Kebapci geschäftlich und infrastrukturtechnisch verwickelt, da Kepabci als Front für die Schwarzarbeit und Geldwäsche der Gartenbedarfs GmbH genutzt wird.

== Topologie <topologie>

Die gesamte Topologie besteht insgesamt aus 40 Netzwerkgeräten und 28 Endgeräten. Alle Geräte innerhalb der Topologie werden auf zwei Echtgeräten virtualisiert.

#htl3r.fspace(
  total-width: 100%,
  figure(
    image("../images/topology/lbt_v9.png"),
    caption: [Der logische Topologieplan (v9)]
  )
)

Der Zugang ins Internet ist durch die Anbindung einer #htl3r.short[nat]-Cloud an #htl3r.short[as]20 bzw. #htl3r.short[as]21 ermöglicht worden.

== Verwendete Geräte & Software

Für den Aufbau der Topologie wurde folgende Software verwendet:
- GNS3 v2.2.53
- VMware Workstation 17
- Cisco vIOS Switch & Router Images
- PfSense Linux Firewalls
- FortiGateVM
- VPCS

Die physischen Geräte, auf denen die Topologie läuft, sind zwei OptiPlex Tower Plus 7020 Desktop-PCs im Raum 076. Auf Arbeitsplatz 3 läuft die GNS3-VM mit den Netzwerkgeräten, auf Arbeitsplatz 4 laufen in VMware Workstation alle Endgeräte.

Um die zwei miteinander zu verbinden, wurde in GNS die IP-Addresse von Arbeitsplatz 4 als Remote-Server eingetragen und nach einem erfolgreichen Verbindungsaufbau werden VMnet Adapter in GNS3 verwendet, um die Endgeräte in die bestehende GNS-Topologie einzubinden und eine Konnektivität zwischen den Geräten herzustellen.

Zur Erstellung der Dokumentation wurden Typst und die Online-Plattform Draw.IO verwendet.
