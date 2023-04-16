# vim: ft=sls

{#-
    Removes the OpenVPN and dnsmasq configurations and has a
    dependency on `vpngw.service.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

include:
  - {{ sls_service_clean }}

VPN Gateway configuration is absent:
  file.absent:
    - names:
      - {{ vpngw.lookup.config }}
      - {{ vpngw.lookup.dnsmasq_config }}
      - {{ vpngw.lookup.dnsmasq_hosts }}
    - require:
      - sls: {{ sls_service_clean }}
