# vim: ft=sls

{#-
    Manages the OpenVPN and dnsmasq service configurations.
    Has a dependency on `vpngw.package`_.
#}

include:
  - .dnsdhcp
  - .vpn
