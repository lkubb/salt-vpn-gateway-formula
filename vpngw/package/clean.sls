# vim: ft=sls

{#-
    Removes the VPN Gateway packages.
    Has a depency on `vpngw.config.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}

include:
  - {{ sls_config_clean }}

VPN Gateway packages are removed:
  pkg.removed:
    - pkgs: {{ vpngw.lookup.pkgs }}
    - require:
      - sls: {{ sls_config_clean }}
