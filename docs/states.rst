Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``vpngw``
^^^^^^^^^
*Meta-state*.

This installs the relevant packages,
manages the service configuration files,
configures routing and port forwards
and then starts the OpenVPN and dnsmasq services.


``vpngw.package``
^^^^^^^^^^^^^^^^^
Installs the relevant packages only (``openvpn``, ``dnsmasq``, ``resolvconf`` currently).


``vpngw.netconfig``
^^^^^^^^^^^^^^^^^^^
Applies basic routing firewall rules, including ensuring the
connection to the Salt master is not terminated after
starting the OpenVPN service.
Also applies custom port forwards, if configured.


``vpngw.netconfig.portforward``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Manages custom port forwards.


``vpngw.config``
^^^^^^^^^^^^^^^^
Manages the OpenVPN and dnsmasq service configurations.
Has a dependency on `vpngw.package`_.


``vpngw.config.dnsdhcp``
^^^^^^^^^^^^^^^^^^^^^^^^
Manages the dnsmasq service configuration.
Has a dependency on `vpngw.package`_.


``vpngw.config.vpn``
^^^^^^^^^^^^^^^^^^^^
Manages the OpenVPN service configuration and auth credentials.
Has a dependency on `vpngw.package`_.


``vpngw.service``
^^^^^^^^^^^^^^^^^
Starts the OpenVPN and dnsmasq services and enables them at boot time.
Has a dependency on `vpngw.config`_.


``vpngw.service.dnsdhcp``
^^^^^^^^^^^^^^^^^^^^^^^^^



``vpngw.service.vpn``
^^^^^^^^^^^^^^^^^^^^^



``vpngw.clean``
^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``vpngw`` meta-state
in reverse order, i.e.
stops the OpenVPN and dnsmasq services,
removes routing and port forward configuration
as well as the service configuration files and then
uninstalls the packages.


``vpngw.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes the VPN Gateway packages.
Has a depency on `vpngw.config.clean`_.


``vpngw.netconfig.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes basic routing firewall rules applied in `vpngw.netconfig`_.
Also removes custom port forwards, if configured.


``vpngw.netconfig.portforward.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes custom port forwards.


``vpngw.config.clean``
^^^^^^^^^^^^^^^^^^^^^^
Removes the OpenVPN and dnsmasq configurations and has a
dependency on `vpngw.service.clean`_.


``vpngw.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Stops the OpenVPN and dnsmasq services and disables them at boot time.


