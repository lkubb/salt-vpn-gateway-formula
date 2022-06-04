# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

VPN Gateway packages are installed:
  pkg.installed:
    - pkgs: {{ vpngw.lookup.pkgs }}
