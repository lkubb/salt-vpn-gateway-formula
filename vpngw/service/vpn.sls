# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_vpn = tplroot ~ ".config.vpn" %}
{%- set sls_netconfig = tplroot ~ ".config.vpn" %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

include:
  - {{ sls_config_vpn }}

VPN Gateway service is running:
  service.running:
    # @TODO proper service name with .format
    - name: {{ vpngw.lookup.service.name }}@{{ vpngw.connection }}
    - enable: true
    - watch:
      - sls: {{ sls_config_vpn }}
      - network: {{ vpngw.network.interface_gw }}
