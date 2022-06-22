# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}
{%- set nftables = "nftables" == vpngw.lookup.netfilter %}

Separate portforward chain is not used:
  {{ vpngw.lookup.netfilter }}.delete:
    - table: filter
    - chain: forward
    - jump: portforward

Port forwarding chains do not exist:
  {{ vpngw.lookup.netfilter }}.chain_absent:
    - names:
      - portforward:
        - require:
          - Separate portforward chain is not used
{%- if nftables %}
      # this will throw an exception currently, but the chain is deleted
      # anyways (same with above). delete_chain returns a ret dict, not a string
      # File "/usr/lib/python3/dist-packages/salt/states/nftables.py", line 222, in chain_absent
      # name, table, command.strip(), family
      # AttributeError: 'dict' object has no attribute 'strip'
      # @TODO bug report
      - prerouting
{%- endif %}
    - table: filter
    - family: ipv4

{%- if not nftables %}
{%-   for dport, target in vpngw.port_forward.items() %}

DNAT for forwarded port {{ dport }} is inactive:
  {{ vpngw.lookup.netfilter }}.delete:
    - names:
      - dnat_tcp_{{ dport }}:
        - proto: tcp
      - dnat_udp_{{ dport }}:
        - proto: udp
    - table: nat
    - chain: prerouting
    - dport: {{ dport }}
    - jump: dnat
    - to-destination: {{ target }}
    - save: true
{%-   endfor %}
{%- endif %}
