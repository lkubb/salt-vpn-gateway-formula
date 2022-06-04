# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

vpngw-service-clean-service-dead:
  service.dead:
    - names:
      - {{ vpngw.lookup.dnsmasq_service }}
      - {{ vpngw.lookup.service.name }}@{{ vpngw.connection }}
    - enable: False
