# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}
{%- set nftables = "nftables" == vpngw.lookup.netfilter %}

include:
  - .portforward.clean

Packet forwarding is disabled:
  sysctl.absent:
    - name: net.ipv4.ip_forward

{%- if nftables %}

# These are not present with nftables by default
Required nftables tables are present:
  nftables.table_absent:
    - names:
      - filter
      - nat
    - family: ipv4
{%- else %}

ipf does not forward packages from intranet for new connections:
  {{ vpngw.lookup.netfilter }}.delete:
    - table: filter
    - chain: forward
    - jump: accept
    - if: {{ vpngw.network.interface_in }}
    - of: {{ vpngw.network.interface_vpn }}
    - source: {{ vpngw.network.cidr_in }}
    - connstate: {{ "new" if not nftables else "'0x8'" }}
    - save: true

ipf does not forward all packages belonging to existing connections:
  {{ vpngw.lookup.netfilter }}.delete:
    - table: filter
    - chain: forward
    - jump: accept
    - connstate: {{ "established,related" if not nftables else "'0x2, 0x4'" }}
    - save: true

ipf does not masquerade outgoing packages (NAT):
  {{ vpngw.lookup.netfilter }}.delete:
    - table: nat
    - chain: postrouting
    - jump: masquerade
    - save: true
{%- endif %}
