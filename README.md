puppet-frontier
======

Puppet module for managing Frontier configurations.

#### Table of Contents
1. [Overview - What is the frontier module?](#overview)

Overview
--------

This module is intended to be used to install and configure Frontier services.
The [Frontier](http://frontier.cern.ch/) distributed database caching system
distributes data from data sources to many clients around the world.
The name comes from "N Tier" where N is any number and Tiers are layers of
locations of distribution. The protocol is http-based and uses a RESTful
architecture which is excellent for caching and scales well.
The Frontier system uses the standard web caching tool squid to cache
the http objects at every site. It is ideal for applications where there are
large numbers of widely distributed clients that read basically the same data
at close to the same time, in much the same way that popular websites are read
by many clients.

Parameters
----------

The following parameters are supported:

* **customize_file**: the customization configuration file to be used, not used if unset
* **customize_template**: the customization configuration template to be used, not used if unset
* **cache_dir**: the cache directory to use
* **install_resource**: set this to true if you want to instal the pacemaker FrontierSquid resource
* **resource_path**: the path where to install the pacemaker resource, default "/usr/lib/ocf/resource.d/lcg"

Usage
-----

### Example

This is a simple example to configure a frontier squid.

**Using the frontier squid module**

```frontier-squid
class { 'frontier::squid':
    customize_file => 'puppet:///modules/mymodule/customize.sh',
    cache_dir      => 'var/squid/cache'
}
```

Contributors
------------

* https://github.com/desalvo/puppet-frontier/graphs/contributors

Release Notes
-------------

**0.1.0**

* Initial version.

**0.1.1**

* Change the default of cache_dir to /var/squid/cache.
