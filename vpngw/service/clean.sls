# vim: ft=sls

{#-
    Stops the OpenVPN and dnsmasq services and disables them at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

VPN Gateway is dead:
  service.dead:
    - names:
      - {{ vpngw.lookup.dnsmasq_service }}
      - {{ vpngw.lookup.service.name }}@{{ vpngw.connection }}
    - enable: false
