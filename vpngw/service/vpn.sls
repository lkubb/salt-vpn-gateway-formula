# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_vpn = tplroot ~ '.config.vpn' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

include:
  - {{ sls_config_vpn }}

vpngw-service-vpn-service-running:
  service.running:
    # @TODO proper service name with .format
    - name: {{ vpngw.lookup.service.name }}@{{ vpngw.connection }}
    - enable: True
    - watch:
      - sls: {{ sls_config_vpn }}
