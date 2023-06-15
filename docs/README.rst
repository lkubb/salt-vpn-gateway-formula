.. _readme:

VPN Gateway Formula
===================

|img_sr| |img_pc|

.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
.. |img_pc| image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
   :alt: pre-commit
   :scale: 100%
   :target: https://github.com/pre-commit/pre-commit

Manage a VPN gateway with Salt.

This formula installs OpenVPN and dnsmasq and configures the system as a gateway router to forward packets from a downstream network via the VPN connection. It is mostly intended for a VM environment.

.. contents:: **Table of Contents**
   :depth: 1

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please refer to:

- `how to configure the formula with map.jinja <map.jinja.rst>`_
- the ``pillar.example`` file
- the `Special notes`_ section

Special notes
-------------
* The resulting configuration will try to clear the non-VPN DNS configuration after a connection has been established, so if it goes down, the system will appear as offline. To re-establish a connection, you might need to reboot or manually reinsert a DNS server to resolve the VPN server domain.
* If the VPN interface is down, downstream packets will never be forwarded.
* You can configure port forwardings from the VPN to downstream clients.
* For detailed information, see the example pillar.

Configuration
-------------
An example pillar is provided, please see `pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in `map.jinja`.

Dynamic port forwards
^^^^^^^^^^^^^^^^^^^^^
In case your port forwards are dynamic (e.g. depending on assigned IP address), you can make use of the included reactor/orchestrator sls files:

You will need a script that returns a list of available ports in JSON:

.. code-block:: python

    #!/usr/bin/env python3

    import fcntl
    import json
    import socket
    import struct
    import sys

    SIOCGIFADDR = 0x8915


    def get_ports(ip):
        # do something to arrive at the ports
        pass


    def get_ip(interface):
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            packed_iface = struct.pack('256s', (interface[:15]).encode('utf_8'))
            packed_addr = fcntl.ioctl(sock.fileno(), SIOCGIFADDR, packed_iface)[20:24]
            return socket.inet_ntoa(packed_addr)


    def build_response(tag, ports, ip_downstream):
        return {
            "tag": tag,
            "data": {
                "gw_addr": ip_downstream,
                "ports": ports,
            }
        }


    if __name__ == "__main__":
        iface_upstream = sys.argv[1]
        ip_upstream = get_ip(iface_upstream)
        ports = get_ports(ip_upstream)
        if len(sys.argv) == 2:
            print(json.dumps(ports))
            exit(0)
        iface_downstream, tag = sys.argv[2:]
        ip_downstream = get_ip(iface_downstream)
        res = build_response(tag, ports, ip_downstream)
        print(json.dumps(res))

You can set this script in ``port_forward_script:source``, e.g. with ``port_forward_script:args=tun0``, which will update the port forwards during a state run. You can also set this script in an engine config on a minion, firing an event if the ports change:

.. code-block:: yaml

    engines:
     - script:
         cmd: /etc/openvpn/port-forwards tun0 eth1 vpngw/portforward/update
         output: json
         interval: 180
         onchange: true

On your master, you will need to map this event to the included reactor, which will run this formula on the minion and a highstate on dependent ones:

.. code-block:: yaml

    reactor:
      - vpngw/portforward/update:
        - salt://react/vpngw/update_port_forwards.sls

You can make use of the port mappings in the mine e.g. like this in your parameters:

.. code-block:: jinja

    {%- set vpngw_forwards = salt["mine.get"]("vpn*", "vpngw_port_forwards") %}
    {%- set local_gw = salt["grains.get"]("ip4_gw") %}
    {%- set forwards = {} %}
    {%- for _, gw_forwards in vpngw_forwards.items() %}
    {%-   if gw_forwards | first == local_gw %}
    {%-     do forwards.update(gw_forwards.values() | first) %}
    {%-     break %}
    {%-   endif %}
    {%- endfor %}
    {%- set addrs = grains.get("ip4_interfaces", {}).get("eth0") %}
    {%- set port = {"val": none} %}
    {%- for pf, tgt in forwards.items() %}
    {%-   if tgt in addrs %}
    {%-     do port.update({"val": pf | int}) %}
    {%-     break %}
    {%-   endif %}
    {%- endfor %}


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
Also applies custom port forwards and routes, if configured.


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
Has a dependency on `vpngw.config.clean`_.


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



Contributing to this repo
-------------------------

Commit messages
^^^^^^^^^^^^^^^

**Commit message formatting is significant!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``. ::

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Testing
-------

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

   $ gem install bundler
   $ bundle install
   $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``vpngw`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.
