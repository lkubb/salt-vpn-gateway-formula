# vim: ft=sls

{#-
    Starts the OpenVPN and dnsmasq services and enables them at boot time.
    Has a dependency on `vpngw.config`_.
#}

include:
  - .dnsdhcp
  - .vpn
