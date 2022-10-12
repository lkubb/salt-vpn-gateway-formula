Update port forwards and mine:
  salt.state:
    - tgt: {{ pillar["vpn_gw_minion"] }}
    - sls:
      - vpngw

Update ports downstream:
  salt.state:
    - tgt: 'ip4_gw:{{ pillar["vpn_gw_addr"] }}'
    - tgt_type: grain
    - highstate: true
    - require:
      - Update port forwards and mine
