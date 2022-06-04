# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_dnsdhcp = tplroot ~ '.config.dnsdhcp' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

include:
  - {{ sls_config_dnsdhcp }}

dnsmasq is running:
  service.running:
    - name: {{ vpngw.lookup.dnsmasq_service }}
    - enable: True
    - watch:
      - sls: {{ sls_config_dnsdhcp }}
