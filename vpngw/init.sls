# vim: ft=sls

{#-
    *Meta-state*.

    This installs the relevant packages,
    manages the service configuration files,
    configures routing and port forwards
    and then starts the OpenVPN and dnsmasq services.
#}

include:
  - .package
  - .netconfig
  - .config
  - .service
