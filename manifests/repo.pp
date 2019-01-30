/**
 * This defines the frontier repository.
 */
 class frontier::repo (
  $cost             = 1000,
  $priority         = 50, #this uses the yum priority plugin.
  $baseurl          = 'http://frontier.cern.ch/dist/rpms/',
  $enabled          = 1,
  $protect          = 1,
  $metadata_expire  = 5400,
) {

  $gpgkey="RPM-GPG-KEY-CernFrontier"
  file {"/etc/pki/rpm-gpg/$gpgkey":
    source => "puppet:///modules/frontier/$gpgkey",
    ensure => present,
  }
  ~>
  exec { "gpgfile $gpgkey import":
    refreshonly => true,
    command =>"/bin/rpm --import /etc/pki/rpm-gpg/$gpgkey",
  }

  $reponame="frontier-squid-cern"
  yumrepo{ $reponame:
    descr=>"Repository for frontier-squid",
    baseurl=>"$baseurl",
    enabled => $enabled,
    gpgcheck => 1,
    cost => $cost,
    protect => $protect,
    priority=> $priority,
    gpgkey => "file:///etc/pki/rpm-gpg/${gpgkey}",
    metadata_expire => $metadata_expire,
    require => Exec["gpgfile $gpgkey import"],
  }

  #If there is a "purge" on the repos dir, make sure we're not purged :
  file {"/etc/yum.repos.d/${reponame}.repo":
    ensure  => present,
  }

}
