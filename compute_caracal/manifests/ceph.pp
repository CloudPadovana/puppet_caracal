class compute_caracal::ceph inherits compute_caracal::params {

#     package { 'ceph-common':
#                 ensure => 'installed',
#}


    exec { "Install ceph 18.2.5":
         command => "/usr/bin/yum -y install *ceph-common-18.2.5* --enablerepo=epel",
         unless => "/bin/rpm -q ceph-common",
         timeout => 3600,
  } ->



     file {'ceph.conf':
              source      => 'puppet:///modules/compute_caracal/ceph.conf',
              path        => '/etc/ceph/ceph.conf',
              backup      => true,
#              require => Package["ceph-common"],
          }

     file {'secret.xml':
             path        => '/etc/nova/secret.xml',
             backup      => true,
             content  => template('compute_caracal/secret.erb'),
             require => Package["openstack-nova-common"],
          }

      $cm = '/usr/bin/virsh secret-define --file /etc/nova/secret.xml | /usr/bin/awk \'{print $2}\' | sed \'/^$/d\' > /etc/nova/virsh.secret'
           
      exec { 'get-or-set virsh secret':
              command => $cm,
              unless  => "/usr/bin/virsh secret-list | grep -i $compute_caracal::params::libvirt_rbd_secret_uuid",
              require => File['secret.xml'],
            }

            
      exec { 'set-secret-value virsh':
          command => "/usr/bin/virsh secret-set-value --secret $compute_caracal::params::libvirt_rbd_secret_uuid --base64 $compute_caracal::params::libvirt_rbd_key",
        unless  => "/usr/bin/virsh secret-get-value $compute_caracal::params::libvirt_rbd_secret_uuid | grep $compute_caracal::params::libvirt_rbd_key",
        require => Exec['get-or-set virsh secret'],
           }
              
}
