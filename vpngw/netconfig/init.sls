# vim: ft=sls

{#-
    Applies basic routing firewall rules, including ensuring the
    connection to the Salt master is not terminated after
    starting the OpenVPN service.
    Also applies custom port forwards, if configured.
#}

include:
  - .base
  - .portforward
