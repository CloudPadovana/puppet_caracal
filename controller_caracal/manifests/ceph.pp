class controller_caracal::ceph inherits controller_caracal::params {


     package { 'ceph-common':
              ensure => 'installed',
             }
####ceph.conf, ceph.client.cinder ceph.client.glance keyring file are in /controller_caracal/files dir
                                                            
     file {'ceph.conf':
            source      => 'puppet:///modules/controller_caracal/ceph.conf',
            path        => '/etc/ceph/ceph.conf',
            backup      => true,
            require => Package["ceph-common"],
          }
     file {'ceph-ec.conf':
            source      => 'puppet:///modules/controller_caracal/ceph-ec.conf',
            path        => '/etc/ceph/ceph-ec.conf',
            backup      => true,
            require => Package["ceph-common"],
          }

  if $::controller_caracal::cloud_role == "is_production" {

      file {'cinder-prod.keyring':
              source      => 'puppet:///modules/controller_caracal/ceph.client.cinder-prod.keyring',
              path        => '/etc/ceph/ceph.client.cinder-prod.keyring',
              backup      => true,
              owner   => cinder,
              group   => cinder,
              mode    => "0640",
              require => Package["ceph-common"],
           }

      file {'glance-prod.keyring':
              source      => 'puppet:///modules/controller_caracal/ceph.client.glance-prod.keyring',
              path        => '/etc/ceph/ceph.client.glance-prod.keyring',
              backup      => true,
              owner   => glance,
              group   => glance,
              mode    => "0640",
              require => Package["ceph-common"],
         }

  }                          
      
  if $::controller_caracal::cloud_role == "is_test" {

      file {'cinder-cloudtest.keyring':
              source      => 'puppet:///modules/controller_caracal/ceph.client.cinder-cloudtest.keyring',
              path        => '/etc/ceph/ceph.client.cinder-cloudtest.keyring',
              backup      => true,
              owner   => cinder,
              group   => cinder,
              mode    => "0640",
              require => Package["ceph-common"],
           }

      file {'glance-test.keyring':
              source      => 'puppet:///modules/controller_caracal/ceph.client.glance-cloudtest.keyring',
              path        => '/etc/ceph/ceph.client.glance-cloudtest.keyring',
              backup      => true,
              owner   => glance,
              group   => glance,
              mode    => "0640",
              require => Package["ceph-common"],
         }

  }                 
} 
