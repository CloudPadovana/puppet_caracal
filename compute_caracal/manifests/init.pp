class compute_caracal ($cloud_role_foreman = "undefined") { 

  $cloud_role = $cloud_role_foreman  

  # system check setting (network, selinux, CA files)
    class {'compute_caracal::systemsetting':}

  # stop services 
    class {'compute_caracal::stopservices':}

  # install
    class {'compute_caracal::install':}

  # setup firewall
    class {'compute_caracal::firewall':}

  # setup bacula
    class {'compute_caracal::bacula':}
  
  # setup libvirt
    class {'compute_caracal::libvirt':}

  # setup ceph
    class {'compute_caracal::ceph':}

  # setup rsyslog
    class {'compute_caracal::rsyslog':}

  # service
    class {'compute_caracal::service':}

  # install and configure nova
     class {'compute_caracal::nova':}

  # install and configure neutron
     class {'compute_caracal::neutron':}

  # nagios settings
     class {'compute_caracal::nagiossetting':}

  # do passwdless access
      class {'compute_caracal::pwl_access':}

    # configure collectd
      class {'compute_caracal::collectd':}


# execution order
             Class['compute_caracal::firewall'] -> Class['compute_caracal::systemsetting']
             Class['compute_caracal::systemsetting'] -> Class['compute_caracal::stopservices']
             Class['compute_caracal::stopservices'] -> Class['compute_caracal::install']
             Class['compute_caracal::install'] -> Class['compute_caracal::bacula']
             Class['compute_caracal::bacula'] -> Class['compute_caracal::nova']
             Class['compute_caracal::nova'] -> Class['compute_caracal::libvirt']
             Class['compute_caracal::libvirt'] -> Class['compute_caracal::neutron']
             Class['compute_caracal::neutron'] -> Class['compute_caracal::ceph']
             Class['compute_caracal::ceph'] -> Class['compute_caracal::nagiossetting']
             Class['compute_caracal::nagiossetting'] -> Class['compute_caracal::pwl_access']
             Class['compute_caracal::pwl_access'] -> Class['compute_caracal::collectd']
             Class['compute_caracal::collectd'] -> Class['compute_caracal::service']
################           
}
  
