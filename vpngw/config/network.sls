# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}
{%- set nftables = "nftables" == vpngw.lookup.netfilter %}

include:
  - {{ sls_package_install }}

Downstream network interface has static IP:
  network.managed:
    - name: {{ vpngw.network.interface_in }}
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ vpngw.network.ipaddr_in }}
    - netmask: {{ vpngw.network.netmask_in }}
    - enable_ipv6: false

Packet forwarding is enabled:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1

{%- if nftables %}

# These are not present with nftables by default
Required nftables tables are present:
  nftables.table_present:
    - names:
      - filter
      - nat
    - family: ipv4

# These are not present with nftables by default
Required nftables chains are present:
  nftables.chain_present:
    - names:
      - postrouting:
        - table: nat
        - table_type: nat
        - hook: postrouting
        - priority: 0
      - forward:
        - table: filter
        - table_type: filter
        - hook: forward
        - priority: 0
    - family: ipv4

forward chain drops by default:
  nftables.set_policy:
    - table: filter
    - chain: forward
    - policy: drop
    - save: true
    # This always reports "changes" otherwise
    - unless:
      - nft list chain filter forward | grep "type filter hook forward priority filter; policy drop;"
{%- endif %}

ipf forwards packages from intranet for new connections:
  {{ vpngw.lookup.netfilter }}.append:
    - table: filter
    - chain: forward
    - jump: accept
    - if: {{ vpngw.network.interface_in }}
    - of: {{ vpngw.network.interface_vpn }}
    - source: {{ vpngw.network.cidr_in }}
    # works around one issue, but if/of still make this not idempotent
    - connstate: {{ "new" if not nftables else "'0x8'" }}
{%- if nftables %}
    - unless:
      - nft list chain filter forward | grep 'iifname "{{ vpngw.network.interface_in }}" oifname "{{ vpngw.network.interface_vpn }}" ct state { new } ip saddr {{ vpngw.network.cidr_in }} accept'
{%- endif %}
    - save: true
    - require:
      - Packet forwarding is enabled
{%- if nftables %}
      - Required nftables chains are present
{%- endif %}
      - sls: {{ sls_package_install }}

ipf forwards all packages belonging to existing connections:
  {{ vpngw.lookup.netfilter }}.append:
    - table: filter
    - chain: forward
    - jump: accept
    # workaround https://github.com/saltstack/salt/issues/62203
    - connstate: {{ "established,related" if not nftables else "'0x2, 0x4'" }}
    - save: true
    - require:
      - Packet forwarding is enabled
{%- if nftables %}
      - Required nftables chains are present
{%- endif %}
      - sls: {{ sls_package_install }}

ipf masquerades outgoing packages (NAT):
  {{ vpngw.lookup.netfilter }}.append:
    - table: nat
    - chain: postrouting
    - jump: masquerade
    - save: true
    - require:
      - Packet forwarding is enabled
{%- if nftables %}
      - Required nftables chains are present
{%- endif %}
