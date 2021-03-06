# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_netconfig_base = tplroot ~ '.netconfig.base' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}
{%- set nftables = "nftables" == vpngw.lookup.netfilter %}

include:
  - {{ sls_netconfig_base }}

Port forwarding chains exist:
  {{ vpngw.lookup.netfilter }}.chain_present:
    - names:
      - portforward
{%- if nftables %}
      - prerouting:
        - table: nat
        - table_type: nat
        - hook: prerouting
        - priority: -100
{%- endif %}
    - table: filter
    - family: ipv4

Separate portforward chain is used:
  {{ vpngw.lookup.netfilter }}.append:
    - table: filter
    - chain: forward
    #{# accept etc omit jump, but custom chains need it. salt does not account for that #}
    - jump: {{ "jump " if nftables }}portforward

{%- if not nftables %}

# this fails and might not be necessary
portforward chain drops by default:
  {{ vpngw.lookup.netfilter }}.set_policy:
    - table: filter
    - chain: portforward
    - policy: drop
    - save: true
{%- endif %}

{%- for dport, target in vpngw.port_forward.items() %}

Incoming packets for forwarded port {{ dport }} are accepted:
  {{ vpngw.lookup.netfilter }}.append:
    - names:
      - pfwd_tcp_{{ dport }}:
        - proto: tcp
{%-   if nftables %}
        - unless:
          - nft list chain filter portforward | grep 'iifname "{{ vpngw.network.interface_vpn }}" oifname "{{ vpngw.network.interface_in }}" tcp dport { {{ dport }} } accept'
{%-   endif %}
      - pfwd_udp_{{ dport }}:
        - proto: udp
{%-   if nftables %}
        - unless:
          - nft list chain filter portforward | grep 'iifname "{{ vpngw.network.interface_vpn }}" oifname "{{ vpngw.network.interface_in }}" udp dport { {{ dport }} } accept'
{%-   endif %}
    - table: filter
    - chain: portforward
    - jump: accept
    - if: {{ vpngw.network.interface_vpn }}
    - of: {{ vpngw.network.interface_in }}
    - dport: {{ dport }}
    - save: true

DNAT for forwarded port {{ dport }} is active:
  {{ vpngw.lookup.netfilter }}.append:
    - names:
      - dnat_tcp_{{ dport }}:
        - proto: tcp
      - dnat_udp_{{ dport }}:
        - proto: udp
    - table: nat
    - chain: prerouting
    - dport: {{ dport }}
    - jump: dnat
    #{# nft list prints `dnat to <target>`, but salt searches without to, so not idempotent #}
    - to-destination: {{ "to " if nftables }}{{ target }}
    - save: true
{%- endfor %}
