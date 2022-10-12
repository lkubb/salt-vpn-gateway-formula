# reactor for vpngw/portforward/update events

Kickoff port update:
  runner.state.orchestrate:
    - args:
      - mods: orch.vpngw.update_ports
      - pillar:
          vpn_gw_minion: {{ data["id"] }}
          vpn_gw_addr: {{ data["data"]["gw_addr"] }}
