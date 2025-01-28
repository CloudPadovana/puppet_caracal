class controller_caracal::service inherits controller_caracal::params {
  
 ## Services

 service { "memcached":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_horizon'],
           }


file { "/etc/cron.d/fetch-crl":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0600",
    content  => file("controller_caracal/fetch-crl.cron"),
  }



 # Services for keystone, placement       
    service { "httpd":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => [ Class['controller_caracal::configure_keystone'], Class['controller_caracal::configure_horizon'], Class['controller_caracal::configure_placement'], ],
           }

 # Services for Shibboleth
    service { "shibd":
                   ensure     => running,
                   enable     => true,
                   hasstatus  => true,
                   hasrestart => true,
                   subscribe  => Class['controller_caracal::configure_shibboleth'],
           }

 # Services for Glance
    service { "openstack-glance-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_glance'],
           }

 # Services for nova       
    service { "openstack-nova-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_nova'],
           }
    service { "openstack-nova-scheduler":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_nova'],
           }
    service { "openstack-nova-novncproxy":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_nova'],
           }
    service { "openstack-nova-conductor":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_nova'],
           }
 

 # Services for ec2       
    service { "openstack-ec2-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_ec2'],
           }
    service { "openstack-ec2-api-metadata":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_ec2'],
           }

 # Services for neutron       
    service { "openvswitch":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_neutron'],
           }
    service { "neutron-server":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_neutron'],
           }
    service { "neutron-openvswitch-agent":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_neutron'],
           }
    service { "neutron-dhcp-agent":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_neutron'],
           }
    service { "neutron-metadata-agent":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_neutron'],
           }
    service { "neutron-l3-agent":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_neutron'],
           }

 # Services for cinder
    service { "openstack-cinder-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_cinder'],
           }
    service { "openstack-cinder-scheduler":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_cinder'],
           }
    service { "openstack-cinder-volume":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_cinder'],
           }
           
 # Services for heat
    service { "openstack-heat-api":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_heat'],
           }
    service { "openstack-heat-api-cfn":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_heat'],
           }
    service { "openstack-heat-engine":
                   ensure      => running,
                   enable      => true,
                   hasstatus   => true,
                   hasrestart  => true,
                   subscribe   => Class['controller_caracal::configure_heat'],
           }
           
  }
