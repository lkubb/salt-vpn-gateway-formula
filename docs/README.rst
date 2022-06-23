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

Available states
----------------

.. contents::
   :local:

``vpngw``
^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

This runs the full installation and configuration.

``vpngw.package``
^^^^^^^^^^^^^^^^^

This state will install the relevant packages only (``openvpn``, ``dnsmasq``, ``resolvconf`` currently).

``vpngw.config``
^^^^^^^^^^^^^^^^

This state will configure the OpenVPN and dnsmasq services and has a dependency on ``vpngw.package`` via include list.

``vpngw.netconfig``
^^^^^^^^^^^^^^^^^^^

This state will configure the system and firewall to act as a gateway router and has a dependency on ``vpngw.config`` via include list.

``vpngw.service``
^^^^^^^^^^^^^^^^^

This state will start the OpenVPN and dnsmasq services and has a dependency on ``vpngw.config`` via include list.

``vpngw.clean``
^^^^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

This state will undo everything performed in the ``vpngw`` meta-state in reverse order, i.e.
stops the services,
removes the configuration files,
resets the system and firewall configuration and
then uninstalls the packages.

``vpngw.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^

This state will stop the OpenVPN and dnsmasq services and disable them at boot time.

``vpngw.config.clean``
^^^^^^^^^^^^^^^^^^^^^^

This state will remove the configuration of the OpenVPN and dnsmasq services and has a
dependency on ``vpngw.service.clean`` via include list.

``vpngw.netconfig.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the gateway router configuration of the system and firewall.

``vpngw.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^

This state will remove the relevant packages and has a depency on
``vpngw.config.clean`` via include list.

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
