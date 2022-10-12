# -*- coding: utf-8 -*-
# vim: ft=yaml
---
vpngw:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    config: '/etc/openvpn/client'
    service:
      name: openvpn-client
    dnsmasq_config: /etc/dnsmasq.d/user.conf
    dnsmasq_service: dnsmasq
    netfilter: iptables
    pkgs:
      - dnsmasq
      - resolvconf
      - openvpn
    port_forward_script: /etc/openvpn/port-forwards
    update_resolv_conf: /etc/openvpn/update-resolv-conf
  auth:
    password: ''
    password_pillar: ''
    username: ''
  config_archive:
    hash: ''
    src: ''
  connection: salt
  dhcp:
    lease_time: 12h
    range_end: 192.168.234.200
    range_start: 192.168.234.50
    static: {}
  dns:
    resolvconf_clear:
      interface_gw:
        - dhcp
        - ifup
      misc: []
      original: true
  network:
    cidr_in: 192.168.234.0/24
    interface_gw: eth0
    interface_in: eth1
    interface_vpn: tun0
    ipaddr_in: 192.168.234.1
    netmask_in: 255.255.255.0
  port_forward: {}
  port_forward_script:
    args: []
    source: ''
    targets: []

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://vpngw/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   vpngw-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      vpngw-config-file-file-managed:
        - 'example.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
