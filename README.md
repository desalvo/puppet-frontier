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
* **max_access_log**: The max size of the log before rotating them
* **install_resource**: set this to true if you want to instal the pacemaker FrontierSquid resource
* **resource_path**: the path where to install the pacemaker resource, default "/usr/lib/ocf/resource.d/lcg"
* $customize_params : hash that can be used to provide the customize_lines param with ... params.
* $customize_lines : array, containing lines that will be interpreted as inline templates and will be used to fill the default customize.sh 

Custom Facts
------------

This module also defines a custom fact `squidcachepartsize` which contains the size (in MB) of the partition
on which `cache_dir` is located. It can be used to define `cache_size` more easily, as shown in the
more complex usage example below.

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

### Example 2

This is a slightly more complex example, setting up custom configuration
and defining an appropriate `cache_size` using the custom fact `squidcachepartsize`,
granting monitoring access to CERN and FNAL and setting things up for an imaginary local network `10.0.0.0/21` with a local monitoring node at `10.0.0.1`. It also makes use of structured facts to set up SMP mode and `cache_mem`, and it uses the modern rock database backend, and disables cache purging on start since that's not needed with the rock backend.
```frontier_squid2
class { '::frontier::squid':
    clean_cache_on_start => false,
    customize_params => {
        worker_cnt => floor(0.5*$facts['processors']['count']),
        cache_size => floor(0.9*$facts['squidcachepartsize']),
        cache_mem  => floor(0.4*($facts['memory']['system']['total_bytes']/1024/1024)),
    },
    customize_lines => [
        'setoption("acl NET_LOCAL src", "10.0.0.0/21")',
        'setoption("acl HOST_MONITOR src", "127.0.0.1/32 128.142.0.0/16 188.184.128.0/17 188.185.128.0/17 131.225.240.232/32 10.0.0.1/32")',
        'setoption("cache_mem", "<%= scope["frontier::squid::customize_params"]["cache_mem"] -%> MB")',
        'setoption("cache_dir", "rock /var/cache/squid <%= scope["frontier::squid::customize_params"]["cache_size"] -%>")',
        'setoption("workers", "<%= scope["frontier::squid::customize_params"]["worker_cnt"] -%>")',
        'setoption("memory_cache_shared", "on")',
    ],
}
```

Contributors
------------

* https://github.com/desalvo/puppet-frontier/graphs/contributors

Release Notes
-------------

**0.1.3**

* Update the frontier repo RPM version
* Squid 3.5 support
* Puppet 4 support

**0.1.2**

* Add the max_access_log parameter

**0.1.1**

* Change the default of cache_dir to /var/squid/cache.

**0.1.0**

* Initial version.
