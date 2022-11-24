# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

dnsmasq configuration is managed:
  file.managed:
    - name: {{ vpngw.lookup.dnsmasq_config }}
    - source: {{ files_switch(['dnsmasq.conf.j2'],
                              lookup='dnsmasq configuration is managed'
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


{%- if vpngw.dns.hosts %}

dnsmasq host overrides are managed:
  file.managed:
    - name: {{ vpngw.lookup.dnsmasq_hosts }}
    - source: {{ files_switch(['dnsmasq.hosts.j2'],
                              lookup='dnsmasq host overrides are managed'
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
