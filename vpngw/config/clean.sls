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
      - {{ vpngw.lookup.dnsmasq_hosts }}
    - require:
      - sls: {{ sls_service_clean }}
