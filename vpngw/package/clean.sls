# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

include:
  - {{ sls_config_clean }}

vpngw-package-clean-pkg-removed:
  pkg.removed:
    - pkgs: {{ vpngw.lookup.pkgs }}
    - require:
      - sls: {{ sls_config_clean }}
