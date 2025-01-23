class controller_caracal::configure_horizon inherits controller_caracal::params {

  ############################################################################
  #  Portal keys
  ############################################################################

  file { "/etc/pki/tls/private/horizon-infn-key.pem":
    ensure   => file,
    mode     => "0400",
    source   => "${horizon_infn_key}",
    tag      => ["portal_keys"],
  }

  file { "/etc/pki/tls/certs/horizon-infn-cert.pem":
    ensure   => file,
    mode     => "0600",
    source   => "${horizon_infn_cert}",
    tag      => ["portal_keys"],
  }

  file { "/etc/pki/tls/private/horizon-unipd-key.pem":
    ensure   => file,
    mode     => "0400",
    source   => "${horizon_unipd_key}",
    tag      => ["portal_keys"],
  }

  file { "/etc/pki/tls/certs/horizon-unipd-cert.pem":
    ensure   => file,
    mode     => "0600",
    source   => "${horizon_unipd_cert}",
    tag      => ["portal_keys"],
  }

  file { "/etc/pki/tls/private/keystone-infn-key.pem":
    ensure   => file,
    mode     => "0400",
    source   => "${keystone_infn_key}",
    tag      => ["portal_keys"],
  }

  file { "/etc/pki/tls/certs/keystone-infn-cert.pem":
    ensure   => file,
    mode     => "0600",
    source   => "${keystone_infn_cert}",
    tag      => ["portal_keys"],
  }

  file { "/etc/pki/tls/private/keystone-unipd-key.pem":
    ensure   => file,
    mode     => "0400",
    source   => "${keystone_unipd_key}",
    tag      => ["portal_keys"],
  }

  file { "/etc/pki/tls/certs/keystone-unipd-cert.pem":
    ensure   => file,
    mode     => "0600",
    source   => "${keystone_unipd_cert}",
    tag      => ["portal_keys"],
  }

#  File <| tag == 'portal_keys' |> ~> Service["controller_caracal::service::httpd"]

  ############################################################################
  #  Dashboard
  ############################################################################

  file { "/etc/httpd/conf.d/ssl.conf":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => template("controller_caracal/ssl.conf.erb"),
    tag      => ["dashboad_cfg"],
  }
  
  file { "/etc/httpd/conf.d/openstack-dashboard.conf":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => file("controller_caracal/openstack-dashboard.conf"),
    tag      => ["dashboad_cfg"],
  }
 
  file { "/etc/openstack-dashboard/local_settings":
    ensure   => file,
    owner    => "root",
    group    => "apache",
    mode     => "0640",
    content  => template("controller_caracal/local_settings.erb"),
    tag      => ["dashboad_cfg"],
  }

  file { "/var/log/horizon/horizon_log":
    path    => '/var/log/horizon/horizon.log',
    ensure  => 'present',
    owner   => 'apache',
    group   => 'apache',
    mode     => "0644",
    tag      => ["dashboad_cfg"],
  }

#  File <| tag == 'dashboad_cfg' |> ~> Service["controller_caracal::service::httpd"]

  ############################################################################
  #  OS-Federation
  ############################################################################
  if $enable_aai_ext {
    file { "/etc/yum.repos.d/openstack-security-integrations.repo":
      ensure   => file,
      owner    => "root",
      group    => "root",
      mode     => "0640",
      content  => file("controller_caracal/openstack-security-integrations.repo"),
    }

    package { "mariadb":
      ensure  => installed,
    }

    package { "openstack-cloudveneto":
      ensure  => latest,
      require => File["/etc/yum.repos.d/openstack-security-integrations.repo"],
    }
  
    file { "/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1002_aai_settings.py":
      ensure   => file,
      owner    => "root",
      group    => "apache",
      mode     => "0640",
      content  => template("controller_caracal/aai_settings.py.erb"),
      tag      => ["aai_conf"],
    }

    file { "/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1003_infnaai_settings.py":
      ensure   => file,
      owner    => "root",
      group    => "apache",
      mode     => "0640",
      content  => template("controller_caracal/infnaai_settings.py.erb"),
      tag      => ["aai_conf"],
    }

    file { "/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1003_unipdsso_settings.py":
      ensure   => file,
      owner    => "root",
      group    => "apache",
      mode     => "0640",
      content  => template("controller_caracal/unipdsso_settings.py.erb"),
      tag      => ["aai_conf"],
    }

    file { "/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1003_oidc_settings.py":
      ensure   => file,
      owner    => "root",
      group    => "apache",
      mode     => "0640",
      content  => template("controller_caracal/oidc_settings.py.erb"),
      tag      => ["aai_conf"],
    }

    file { "/etc/openstack-auth-shib/notifications/notifications_en.txt":
      ensure   => file,
      owner    => "root",
      group    => "root",
      mode     => "0644",
      content  => template("controller_caracal/notifications_en.txt.erb"),
      tag      => ["aai_conf"],
    }

    Package["openstack-cloudveneto"] -> File <| tag == 'aai_conf' |>
  }

  ############################################################################
  #  Cron-scripts configuration
  ############################################################################

  file { "/etc/openstack-auth-shib/actions.conf":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0600",
    content  => template("controller_caracal/actions.conf.erb"),
  }
  
  if "${::fqdn}" =~ /01/ {
    $chk_exp_schedule = "5 0 * * 0,2,4,6"
    $noti_exp_schedule = "10 0 * * 0,2,4,6"
    $renew_schedule = "15 0 * * *"
    $chk_gate_schedule = "0 6-20 * * *"
  } else {
    $chk_exp_schedule = "5 0 * * 1,3,5"
    $noti_exp_schedule = "10 0 * * 1,3,5"
    $renew_schedule = "30 0 * * *"
    $chk_gate_schedule = "30 6-20 * * *"
  }
  
  file { "/etc/cron.d/openstack-auth-shib-cron":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => '0644',
    content  => template("controller_caracal/openstack-auth-shib-cron.erb"),
  }

  ############################################################################
  #  gate configuration
  ############################################################################

  exec { "gate key check":
    command => "/usr/bin/test -e ${gate_credentials}",
    returns => 0,
  }

  ############################################################################
  #  Memcached configuration
  ############################################################################

  file_line { 'memcached sysconfig':
    ensure => present,
    path   => '/etc/sysconfig/memcached',
    line   => "OPTIONS=\"-l $::mgmtnw_ip\"",
    match  => 'OPTIONS',
  }
}
