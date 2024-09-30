class compute_caracal::nagiossetting inherits compute_caracal::params {

     file {'nagios_check_ovs':
             source      => 'puppet:///modules/compute_caracal/nagios_check_ovs.sh',
             path => '/usr/local/bin/nagios_check_ovs.sh',
             mode => '+x',
             #subscribe   => Class['compute_caracal::neutron'],
          }

     file {'nagios_check_kvm':
             source      => 'puppet:///modules/compute_caracal/check_kvm',
             path        => '/usr/local/bin/check_kvm',
             mode        => '+x',
             #subscribe   => Class['compute_caracal::nova'],
          }

     file {'nagios_check_kvm_wrapper':
             source      => 'puppet:///modules/compute_caracal/check_kvm_wrapper.sh',
             path        => '/usr/local/bin/check_kvm_wrapper.sh',
             mode        => '+x',
             require => File['nagios_check_kvm'],
             #subscribe   => Class['compute_caracal::nova'],
          }

     file {'check_total_disksize.sh':
             source      => 'puppet:///modules/compute_caracal/check_total_disksize.sh',
             path        => '/usr/lib64/nagios/plugins/check_total_disksize.sh',
             mode        => '+x',
             #subscribe   => Class['compute_caracal::nova'],
          }

### FEDE vedi ticket PDCL-2010
     if $operatingsystemrelease =~ /^9.*/ {
         file {'check_lvs.py':
                 content  => template('compute_caracal/check_lvs.py.template'),
                 #source      => 'puppet:///template/compute_caracal/check_lvs.py.template',
                 path        => '/usr/local/bin/check_lvs.py',
                 mode        => '+x',
              }
     }
###
# NAGIOS - various crontabs

### FEDE cron per check_lvs:  */5 * * * * root /usr/local/bin/check_lvs.py -w 80 --critical 90
     if $operatingsystemrelease =~ /^9.*/ {
         cron {'check_lvs':
                 ensure      => present,
                 command     => "/usr/local/bin/check_lvs.py -w 80 --critical 90",
                 user        => root,
                 minute      => '*/5',
                 hour        => '*',
              }
     }
###
     cron {'nagios_check_ovs':
             ensure      => present,
             command     => "/usr/local/bin/nagios_check_ovs.sh",
             user        => root,
             minute      => '*/10',
             hour        => '*',
             require     => File["nagios_check_ovs"]
          }

     cron {'nagios_check_kvm':
             ensure     => present,
             command    => "/usr/local/bin/check_kvm_wrapper.sh",
             user       => root,
             minute      => 0,
             hour        => '*/1',
             require    => File["nagios_check_kvm_wrapper"]
          }
}
