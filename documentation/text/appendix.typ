#import "@preview/htl3r-da:1.0.0" as htl3r

#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  counter(heading).update(0)
  body
}

#show: appendix
#htl3r.author("")

= Gesamte logische Topologie <app1>
#align(center, 
  rotate(90deg, reflow: true,
    htl3r.fspace(
      total-width: 100%,
      figure(
        image("../images/topology/lbt_v9.png"),
      )
    )
  )
)

= Cisco-Gerät Grundkonfiguration <app2>
#htl3r.code()[
```ciscoios
! David Koch & Julian Burger 5CN
! Little Big Topo
! BASE
! ============================

en
conf t
hostname BASE
no ip domain-lookup
ip domain name 5CN
banner motd *!!!KEEP OUT - Property of Koch & Burger!!!*
service password-encryption
username cisco priv 15
username cisco algorithm-type scrypt secret cisco
crypto key generate rsa usage-keys modulus 1024
ip ssh version 2

line vty 0 15
login local
logging synchronous
exec-timeout 0 0
transport input telnet ssh
exit

line con 0
logging synchronous
exec-timeout 0 0
exit

! config goes here

end
wr
```
]