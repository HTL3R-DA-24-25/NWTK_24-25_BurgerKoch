#import "@preview/htl3r-da:1.0.0" as htl3r

#show: htl3r.diplomarbeit.with(
  title: "Little Big Topo",
  subtitle: "Dokumentationsbuch der Gruppe 4",
  department: "ITN",
  school-year: "2024/2025",
  authors: (
    (name: "Julian Burger", supervisor: "Christian Schöndorfer", role: "Mitarbeiter"),
    (name: "David Koch", supervisor: "Christian Schöndorfer", role: "Projektleiter"),
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
  abbreviation: none,
  bibliography-content: none,
)

#include "text/cover.typ"

#include "text/toc.typ"

#include "text/ueberblick.typ"

#include "text/backbone.typ"

#include "text/firewalls.typ"

#include "text/standorte.typ"

#include "text/active_directory.typ"

#include "text/appendix.typ"
