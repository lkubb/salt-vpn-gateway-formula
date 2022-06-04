# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

include:
  - {{ sls_service_clean }}

vpngw-config-clean-file-absent:
  file.absent:
    - names:
      - {{ vpngw.lookup.config }}
      - {{ vpngw.lookup.dnsmasq_config }}
    - require:
      - sls: {{ sls_service_clean }}

Packet forwarding is disabled:
  sysctl.absent:
    - name: net.ipv4.ip_forward
    - require:
      - sls: {{ sls_service_clean }}

ipf does not forward packages from intranet for new connections:
  {{ vpngw.lookup.netfilter }}.delete:
    - table: filter
    - chain: FORWARD
    - jump: ACCEPT
    - if: {{ vpngw.network.interface_in }}
    - of: {{ vpngw.network.interface_vpn }}
    - source: {{ vpngw.network.cidr_in }}
    - connstate: NEW
    - save: true
    - require:
      - sls: {{ sls_service_clean }}

ipf does not forward all packages belonging to existing connections:
  {{ vpngw.lookup.netfilter }}.delete:
    - table: filter
    - chain: FORWARD
    - jump: ACCEPT
    - connstate: ESTABLISHED,RELATED
    - save: true
    - require:
      - sls: {{ sls_service_clean }}

ipf does not masquerade outgoing packages (NAT):
  {{ vpngw.lookup.netfilter }}.delete:
    - table: nat
    - chain: POSTROUTING
    - jump: MASQUERADE
    - save: true
    - require:
      - sls: {{ sls_service_clean }}
