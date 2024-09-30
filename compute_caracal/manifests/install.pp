class compute_caracal::install inherits compute_caracal::params {

#include compute_caracal::params

$cloud_role = $compute_caracal::cloud_role          

### Repository settings (remove old rpm and install new one)
  
  define removepackage {
    exec {
        "removepackage_$name":
            command => "/usr/bin/yum -y erase $name",
            onlyif => "/bin/rpm -ql $name",
    }
  }

  $oldrelease = [ 'centos-release-openstack-train',
                ]

  $newrelease =  'centos-release-openstack-caracal'

  $yumutils = 'yum-utils'

  $genericpackages = [ "crudini",
                       "ipset",
                       "sysfsutils", ]

  $neutronpackages = [ "openstack-neutron",
                       "openstack-neutron-openvswitch",
                       "openstack-neutron-common",
                       "openstack-neutron-ml2", ]

  $novapackages = [ "openstack-nova-compute",
                     "openstack-nova-common", ]

  file { "/etc/yum/vars/contentdir":
         path    => '/etc/yum/vars/contentdir',
         ensure  => 'present',
         content => 'centos',
  } ->

  compute_caracal::install::removepackage{
     $oldrelease :
  } ->

  exec { "removestring_failover":
            command => "/usr/bin/sed -i \"/failovermethod/d\" /etc/yum.repos.d/puppet5.repo",
            onlyif => "/usr/bin/grep failovermethod=priority /etc/yum.repos.d/puppet5.repo",
  } ->

  package { $yumutils :
    ensure => 'installed',
  } ->

  if $operatingsystemrelease =~ /^9.*/ {
      exec { "yum enable crb repo":
             command => "/usr/bin/yum-config-manager --enable crb",
             unless => "/usr/bin/yum repolist enabled | grep -i crb",
             timeout => 3600,
             require => Package[$yumutils],
      }
  }
  else { 
      exec { "yum enable PowerTools repo":
             command => "/usr/bin/yum-config-manager --enable powertools",
             unless => "/usr/bin/yum repolist enabled | grep -i powertools",
             timeout => 3600,
             require => Package[$yumutils],
      }
  }

### non serve
#  if $operatingsystemrelease =~ /^9.*/ {
#      exec { "yum install rdma-core-devel rdma-core ":
#             command => "/usr/bin/yum -y install rdma-core-devel rdma-core",
#             timeout => 3600,
#      }
#  }


# Esegue yum clean all once (lo si fa a meno che non stiamo gia` usando il repo caracal)
  exec { "clean repo cache":
         command => "/usr/bin/yum clean all",
         unless => "/bin/rpm -q centos-release-openstack-caracal",
  } ->

  package { $newrelease :
    ensure => 'installed',
  } ->

  ### negli update si consiglia di disabilitare EPEL (epel-next e' l'unico abilitato da disabilitare) 
  exec { "yum disable EPEL repo":
         command => "/usr/bin/yum-config-manager --disable epel\\*",
         onlyif => "/bin/rpm -qa | grep centos-release-openstack-caracal && /usr/bin/yum repolist enabled | grep epel",
         timeout => 3600,
         require => Package[$yumutils],
  } -> 

## FF in caracal forse questo non serve piu', da provare ##
  exec { "yum update for update from Train in DELL hosts":
         command => "/usr/bin/yum -y --disablerepo dell-system-update_independent --disablerepo dell-system-update_dependent -x facter update",
         onlyif => "/bin/rpm -qi dell-system-update | grep 'Architecture:' &&  /usr/bin/yum list installed | grep openstack-neutron.noarch | grep -i 'train'",
         timeout => 3600,
  } ->

  exec { "yum update for update from Train":
         command => "/usr/bin/yum -y update",
         onlyif => "/bin/rpm -qi dell-system-update | grep 'not installed' &&  /usr/bin/yum list installed | grep openstack-neutron.noarch | grep -i 'train'",
         timeout => 3600,
  } ->
#####

# Rename nova config file  
  exec { "mv_nova_conf_old":
         command => "/usr/bin/mv /etc/nova/nova.conf /etc/nova/nova.conf.train",
         onlyif  => "/usr/bin/test -e /etc/nova/nova.conf.rpmnew",
  } ->
 
  exec { "mv_nova_conf_new":
         command => "/usr/bin/mv /etc/nova/nova.conf.rpmnew /etc/nova/nova.conf",
         onlyif  => "/usr/bin/test -e /etc/nova/nova.conf.rpmnew",
  } ->

# Rename neutron config file  
  exec { "mv_neutron_conf_old":
         command => "/usr/bin/mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.train",
         onlyif  => "/usr/bin/test -e /etc/neutron/neutron.conf.rpmnew",
  } ->

  exec { "mv_neutron_conf_new":
         command => "/usr/bin/mv /etc/neutron/neutron.conf.rpmnew /etc/neutron/neutron.conf",
         onlyif  => "/usr/bin/test -e /etc/neutron/neutron.conf.rpmnew",
  } ->

  exec { "mv_neutron_openvswitch_old":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini.train",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew",
  } ->

  exec { "mv_neutron_openvswitch_new":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew /etc/neutron/plugins/ml2/openvswitch_agent.ini",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew",
  } ->


  exec { "mv_neutron_ml2_old":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.train",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/ml2_conf.ini.rpmnew",
  } ->

  exec { "mv_neutron_ml2_new":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/ml2_conf.ini.rpmnew /etc/neutron/plugins/ml2/ml2_conf.ini",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/ml2_conf.ini.rpmnew",
  } ->


## Install generic packages
  package { $genericpackages: 
    ensure => "installed",
    require => Package[$newrelease]
   } ->

  package { $neutronpackages: 
    ensure => "installed",
    require => Package[$newrelease]
  } ->

  package { $novapackages: 
    ensure => "installed",
    require => Package[$newrelease]
  } ->

# Eseguo uno yum update se il pacchetto python*-networkx.noarch non proviene dal repo caracal 
# (Il nome del pacchetto varia tra centos7 e centos8)
# Serve a quanto pare solo per installazioni da scratch su centos8 (cosa che non dovrebbe piu' succedere)
# Almeno per il momento lo commento
##
##  exec { "yum update in DELL hosts":
##         command => "/usr/bin/yum -y --disablerepo dell-system-update_independent --disablerepo dell-system-update_dependent -x facter update",
##         onlyif => "/bin/rpm -q dell-system-update &&  /usr/bin/yum list installed | grep python3-networkx | grep -v 'centos-openstack-caracal'",
##         timeout => 3600,
##
## } ->

 ## exec { "yum update":
 ##       command => "/usr/bin/yum -y update",
 ##        onlyif => "/bin/rpm -q dell-system-update | grep 'not installed' &&  /usr/bin/yum list installed | grep python3-networkx | grep -v 'centos-openstack-caracal'",
 ##       timeout => 3600,
 ## } ->

  
  file_line { '/etc/sudoers.d/neutron  syslog':
               path   => '/etc/sudoers.d/neutron',
               line   => 'Defaults:neutron !requiretty, !syslog',
               match  => 'Defaults:neutron !requiretty',
            }
 
if $::compute_caracal::cloud_role == "is_prod_localstorage" or $::compute_caracal::cloud_role ==  "is_prod_sharedstorage" {

   package { 'glusterfs-fuse':
              ensure => 'installed',
           }
 } 
}
