# == Class: frontier::squid
#
# Installation and configuration of a frontier squid
#
# === Parameters
#
# [*customize_file*]
#   The customization config file to be used.
#
# [*customize_template*]
#   The customization config template to be used.
#
# [*cache_dir*]
#   The cache directory.
#
# [*max_access_log*]
#   The max size of the log before rotating them
#
# [*install_resource*]
#   The cache directory.
#
# [*resource_path*]
#   The cache directory.
#
# [* daemons *]
#   Self explanatory
#
# [ *customize_params / customize_lines *]
#   Provides a way for filling up the customize.sh automatically, using params.
#   The customize_lines array can refer to params inside the customize_params hash using the scope[] erb function, because the lines will be interpreted as erb inline templates afterwards.
#
# For multi daemons frontiers, params could look like this (untested) :
#    cusomize params :
#    {
#      'process_numbers' => inline_template('<%= (1..@daemons).to_a.join(",") -%>',
#      'cores' => inline_template('<%= (2..(@daemons+1)).to_a.join(",") -%>')
#    }
#    customize_lines :
#     (the cpu_affinity_map workers param is set to 1)
#    [
#    'setoptionparameter("cache_dir", 2, "<%=cache_dir%>/squid${service_name}")',
#    'setoptionparameter("access_log", 1, "daemon:/var/log/squid/squid${service_name}/access.log")',
#    'setoption("cache_log", "/var/log/squid/squid${service_name}/cache.log")',
#    'setoption("pid_filename", "/var/run/squid/squid${service_name}.pid")',
#    'setoption("visible_hostname", "<%= @hostname %>/${service_name}")',
#    'setserviceoption("http_port", "", 3128, <%= @daemons.to_i -1 %>, -1)',
#    'setserviceoption("snmp_port", "", 3401, <%= @daemons.to_i -1 %>, 1)',
#    'setserviceoption("cpu_affinity_map", "process_numbers=<%= scope["frontier::squid::customize_params"]["process_numbers"]%> cores=", "<%= scope["frontier::squid::customize_params"]["cores"] %>", <%= @daemons.to_i -1 %>, 1',
#    ]
#
# a multi *worker* frontier instance, could look like this (tested) :
#    cusomize params :
#
#    customize_lines :
#    [
#      'setoption("coredump_dir","<%= scope["frontier::squid::cache_dir"] %>")',
#      'setoption("acl NET_LOCAL src", "<%= scope["myfirewall::params::cidr"] %> <%= scope["myfirewall::params::ipv6cidr"] %> fc00::/7 fe80::/10")',
#      'setoption("cache_mem", "<%= scope["server::squid::cache_mem_MB"] -%> MB")',
#      'setoptionparameter("cache_dir", 3, "<%= scope["server::squid::cache_size"] -%>")',
#      'setoption("workers", <%= scope["server::squid::workers"] %>)',
#      'setoptionparameter("cache_dir", 2, "<%= scope["frontier::squid::cache_dir"] %>/squid${process_number}")',
#      'setoption("cpu_affinity_map", "process_numbers=<%= (1..scope["server::squid::workers"].to_i).to_a.join(",") -%> cores=<%= (2..(scope["server::squid::workers"].to_i+1)).to_a.join(",")  -%>")',
#    ]
#

# === Examples
#
#  class { frontier::squid:
#    customize_file => 'puppet:///modules/mymodule/customize.sh',
#    cache_dir      => '/var/squid/cache'
#  }
#
# === Authors
#
# Alessandro De Salvo <Alessandro.DeSalvo@roma1.infn.it>
#
# modifications :
# Frederic Schaer - CEA
#
# === Copyright
#
# Copyright 2014 Alessandro De Salvo
#
class frontier::squid (
  $customize_file = undef,
  $customize_template = 'frontier/customize.sh.erb',
  $cache_dir = $frontier::params::frontier_cache_dir,
  $max_access_log = undef,
  $install_resource = false,
  $resource_path = $frontier::params::resource_agents_path,
  #multi daemons additions
  $daemons = 1,
  #customize additions
  $customize_params={},
  $customize_lines=[
    'setoption("acl NET_LOCAL src", "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 fc00::/7 fe80::/10")',
    'setoption("cache_mem", "128 MB")',
    'setoptionparameter("cache_dir", 3, "<%= scope["frontier::squid::customize_params"]["cache_size"] -%>")',
  ],
) inherits frontier::params {
  include ::frontier::repo

  package {$frontier::params::frontier_packages:
      ensure  => latest,
      require => Yumrepo['frontier-squid-cern'],
      notify  => Service[$frontier::params::frontier_service]
  }

  if ($cache_dir) {
      file { $cache_dir:
          ensure  => directory,
          owner   => squid,
          group   => squid,
          mode    => '0755',
          require => Package[$frontier::params::frontier_packages],
          notify  => Service[$frontier::params::frontier_service]
      }
  }

  if ($customize_file) {
      file {$frontier::params::frontier_customize:
          ensure  => file,
          owner   => squid,
          group   => squid,
          mode    => '0755',
          source  => $customize_file,
          require => Package[$frontier::params::frontier_packages],
          notify  => Service[$frontier::params::frontier_service]
      }
  }

  if ($customize_template) {
      file {$frontier::params::frontier_customize:
          ensure  => file,
          owner   => squid,
          group   => squid,
          mode    => '0755',
          content => template($customize_template),
          require => Package[$frontier::params::frontier_packages],
          notify  => Service[$frontier::params::frontier_service]
      }
  }

  if ($install_resource) {
      file { $resource_path:
          ensure  => directory,
          owner   => "root",
          group   => "root",
          mode    => '0755',
      }

      file { "${resource_path}/FrontierSquid":
          ensure  => file,
          owner   => "root",
          group   => "root",
          mode    => '0755',
          source  => "puppet:///modules/frontier/FrontierSquid",
          require => File[$resource_path]
      }
  }

  file {$frontier::params::frontier_squidconf:
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('frontier/squidconf.erb'),
      require => Package[$frontier::params::frontier_packages],
  }

  service {$frontier::params::frontier_service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => Package[$frontier::params::frontier_packages]
  }
}
