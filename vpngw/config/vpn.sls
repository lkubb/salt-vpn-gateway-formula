# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- set sls_config_network = tplroot ~ '.config.network' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}
  - {{ sls_config_network }}

{%- if vpngw.config_archive.src %}

VPN configuration files are sourced from archive:
  archive.extracted:
    - name: {{ vpngw.lookup.config }}
    - source: {{ vpngw.config_archive.src }}
{%-   if vpngw.config_archive.hash %}
    - source_hash: {{ vpngw.config_archive.hash }}
{%-   elif vpngw.config_archive.hash is sameas false %}
    - skip_verify: true
{%-   endif %}
    - enforce_toplevel: false
    - makedirs: true
{%- else %}

VPN configuration is managed:
  file.managed:
    - name: {{ vpngw.lookup.config | path_join("salt.conf") }}
    - source: {{ files_switch(['vpn-client.conf'],
                              lookup='VPN configuration is managed'
                 )
              }}
    - mode: 644
    - user: root
    - group: {{ vpngw.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        vpngw: {{ vpngw | json }}
{%- endif %}

{%- if vpngw.auth.username and (vpngw.auth.password or vpngw.auth.password_pillar) %}

Authentication file is present:
  file.managed:
    - name: {{ vpngw.lookup.config | path_join("p.txt") }}
    - source: {{ files_switch(['p.txt.j2'],
                              lookup='Authentication file is present'
                 )
              }}
    - mode: 600
    - user: root
    - group: {{ vpngw.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        vpngw: {{ vpngw | json }}

{%-   set conffiles = salt["file.find"](vpngw.lookup.config | path_join("*.conf")) %}

Ensure authentication is used by VPN configuration:
  # This ensures you don't need two runs
  cmd.run:
    - name: |
        for file in {{ vpngw.lookup.config | path_join("*.conf") }}; do
            grep 'auth-user-pass p.txt' "$file" && continue >/dev/null
            sed -i '/^auth-user-pass/d' "$file" >/dev/null
            sed -i '1s;^;auth-user-pass p.txt\n;' "$file" >/dev/null
        done
    - onchanges:
{%-   if vpngw.config_archive.src %}
      - VPN configuration files are sourced from archive
{%-   else %}
      - VPN configuration is managed
{%-   endif %}
{%-   if conffiles %}
  file.prepend:
    - names:
{%-     for f in conffiles %}
      - {{ f }}
{%-     endfor %}
    - text: auth-user-pass p.txt
{%-   endif %}
{%- endif %}
