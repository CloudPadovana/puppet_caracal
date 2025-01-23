class compute_caracal::stopservices inherits compute_caracal::params {

########
#i servizi devono venir spenti solo in fase di installazione dei compute quindi quando la release e' ancora a yoga 
########
# Services needed
#systemctl stop openvswitch
#systemctl stop neutron-openvswitch-agent
#systemctl stop openstack-nova-compute
########
    
    #notify { 'stopservices': 
    #                    message => "sono in stop services"
    #       }
    service { "stop openvswitch service":
                        stop        => "/usr/bin/systemctl stop openvswitch",
                        require => Exec['checkForRelease'],
            }
    service { 'stop neutron-openvswitch-agent service':
                        stop        => "/usr/bin/systemctl stop neutron-openvswitch-agent",
                        require => Exec['checkForRelease'],
            }
    service { 'stop openstack-nova-compute service':
                        stop        => "/usr/bin/systemctl stop openstack-nova-compute",
                        require => Exec['checkForRelease'],
            }
    
    exec { 'checkForRelease':
       command => "/usr/bin/yum list installed | grep centos-release-openstack-yoga ; /usr/bin/echo $?",
       returns => "0",
       refreshonly => true,
    }
}
