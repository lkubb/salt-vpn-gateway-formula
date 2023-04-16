# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``vpngw`` meta-state
    in reverse order, i.e.
    stops the OpenVPN and dnsmasq services,
    removes routing and port forward configuration
    as well as the service configuration files and then
    uninstalls the packages.
#}

include:
  - .service.clean
  - .config.clean
  - .netconfig.clean
  - .package.clean
