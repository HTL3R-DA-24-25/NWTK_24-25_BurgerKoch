#import "@preview/htl3r-da:0.1.0" as htl3r

#show: htl3r.diplomarbeit.with(
  title: "Fenrir",
  subtitle: "Zum Schutz von OT-Netzwerken",
  department: "ITN",
  school-year: "2024/2025",
  authors: (
    (name: "Julian Burger", supervisor: "Christian Schöndorfer", role: "Mitarbeiter"),
    (name: "David Koch", supervisor: "Christian Schöndorfer", role: "Projektleiter"),
    (name: "Bastian Uhlig", supervisor: "Clemens Kussbach", role: "Stv. Projektleiter"),
    (name: "Gabriel Vogler", supervisor: "Clemens Kussbach", role: "Mitarbeiter"),
  ),
  supervisor-incl-ac-degree: (
    "Prof. Dipl.-Ing. Christian Schöndorfer",
    "Prof. Dipl.-Ing. Clemens Kussbach",
  ),
  sponsors: (),
  date: datetime.today(),
  disable-book-binding: true,
  disable-cover: true,
  print-ref: false,
  generative-ai-clause: none,
  abbreviation: yaml("abbr.yml"),
  bibliography-content: bibliography("refs.yml", full: true, title: [Literaturverzeichnis]),
)

#include "text/cover.typ"

#include "text/toc.typ"

#include "text/ueberblick.typ"

#include "text/backbone.typ"

#include "text/firewalls.typ"

#include "text/standorte.typ"

#include "text/active_directory.typ"