# vim: ft=sls

{#-
    Manages the dnsmasq service configuration.
    Has a dependency on `vpngw.package`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as vpngw with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

dnsmasq configuration is managed:
  file.managed:
    - name: {{ vpngw.lookup.dnsmasq_config }}
    - source: {{ files_switch(
                    ["dnsmasq.conf", "dnsmasq.conf.j2"],
                    config=vpngw,
                    lookup="dnsmasq configuration is managed",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ vpngw.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        vpngw: {{ vpngw | json }}


{%- if vpngw.dns.hosts %}

dnsmasq host overrides are managed:
  file.managed:
    - name: {{ vpngw.lookup.dnsmasq_hosts }}
    - source: {{ files_switch(
                    ["dnsmasq.hosts", "dnsmasq.hosts.j2"],
                    config=vpngw,
                    lookup="dnsmasq host overrides are managed",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ vpngw.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        vpngw: {{ vpngw | json }}
{%- endif %}
