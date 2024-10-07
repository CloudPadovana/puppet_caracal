class controller_caracal::configure_horizon inherits controller_caracal::params {

  file { "/etc/httpd/conf.d/ssl.conf":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => template("controller_caracal/ssl.conf.erb"),
  }
  
  file { "/etc/httpd/conf.d/openstack-dashboard.conf":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => file("controller_caracal/openstack-dashboard.conf"),
  }
 
  file { "/etc/openstack-dashboard/local_settings":
    ensure   => file,
    owner    => "root",
    group    => "apache",
    mode     => "0640",
    content  => template("controller_caracal/local_settings.erb"),
  }

  file { '/var/log/horizon/horizon_log':
    path    => '/var/log/horizon/horizon.log',
    ensure  => 'present',
    owner   => 'apache',
    group   => 'apache',
    mode     => "0644",
  }

#  exec { "port_80_closed":
#    command => "/usr/bin/sed -i -e 's|^Listen\\s*80\\s*|#Listen 80|g' /etc/httpd/conf/httpd.conf" ,
#    unless  => "/bin/grep '#Listen\\s*80\\s*$' /etc/httpd/conf/httpd.conf",
#  }


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


  ### DB Creation if not exist and grant privileges.

    package { "mariadb":
      ensure  => installed,
    }

    exec { "create-$aai_db_name-db":
        command => "/usr/bin/mysql -u root -p${mysql_admin_password} -h ${aai_db_host} -e \"create database IF NOT EXISTS ${aai_db_name}; grant all on ${aai_db_name}.* to ${aai_db_user}@localhost identified by '${aai_db_pwd}'; grant all on ${aai_db_name}.* to ${aai_db_user}@'${vip_mgmt}' identified by '${aai_db_pwd}'; grant all on ${aai_db_name}.* to ${aai_db_user}@'${ip_ctrl1}' identified by '${aai_db_pwd}'; grant all on ${aai_db_name}.* to ${aai_db_user}@'${ip_ctrl2}' identified by '${aai_db_pwd}';\"",
        unless  => "/usr/bin/mysql -u root -p${mysql_admin_password} -h ${aai_db_host} -e \"show DATABASES LIKE '${aai_db_name}';\"",
        require => Package["mariadb"],
    }

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
  #  Memcached configuration
  ############################################################################

  file_line { 'memcached sysconfig':
    ensure => present,
    path   => '/etc/sysconfig/memcached',
    line   => "OPTIONS=\"-l $::mgmtnw_ip\"",
    match  => 'OPTIONS'
  }
}
