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
# [*install_resource*]
#   The cache directory.
#
# [*resource_path*]
#   The cache directory.
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
# === Copyright
#
# Copyright 2014 Alessandro De Salvo
#
class frontier::squid (
  $customize_file = undef,
  $customize_template = undef,
  $cache_dir = undef,
  $install_resource = false,
  $resource_path = $frontier::params::resource_agents_path
) inherits params {
  yumrepo {'cern-frontier':
      baseurl => 'http://frontier.cern.ch/dist/rpms/',
      enabled => 1,
      gpgcheck => 1,
      gpgkey   => 'http://frontier.cern.ch/dist/rpms/cernFrontierGpgPublicKey'
  }

  package {$frontier::params::frontier_packages:
      ensure  => latest,
      require => Yumrepo['cern-frontier'],
      notify  => Service[$frontier::params::frontier_service]
  }

  if ($cache_dir) {
      file { $cache_dir:
          ensure  => directory,
          owner   => squid,
          group   => squid,
          mode    => 0755,
          require => Package[$frontier::params::frontier_packages],
          notify  => Service[$frontier::params::frontier_service]
      }
  }

  if ($customize_file) {
      file {$frontier::params::frontier_customize:
          ensure  => file,
          owner   => squid,
          group   => squid,
          mode    => 0755,
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
          mode    => 0755,
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
          mode    => 0755,
      }

      file { "${resource_path}/FrontierSquid":
          ensure  => file,
          owner   => "root",
          group   => "root",
          mode    => 0755,
          source  => "puppet:///modules/frontier/FrontierSquid",
          require => File[$resource_path]
      }
  }

  service {$frontier::params::frontier_service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => Package[$frontier::params::frontier_packages]
  }
}
