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

  $oldrelease = [ 'centos-release-openstack-yoga',
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

  exec { "yum remove bareos packages":
         command => "/usr/bin/yum -y remove bareos-common bareos-filedaemon",
         onlyif => "/usr/bin/yum list installed | grep bareos-common | grep -v 'commandline'",
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

  exec { "yum update for Ceph from Yoga to Caracal enabling epel":
         command => "/usr/bin/yum -y update *ceph* --enablerepo=epel",
         onlyif => "/usr/bin/yum list installed | grep ceph-common | grep -i 'yoga'",
         timeout => 3600,
  } ->

  exec { "yum update to Caracal in DELL hosts":
         command => "/usr/bin/yum -y --disablerepo dell-system-update_independent --disablerepo dell-system-update_dependent",
         onlyif => "/bin/rpm -qi dell-system-update | grep 'Architecture:' &&  /usr/bin/yum list installed | grep openstack-neutron.noarch | grep -i 'yoga'",
         timeout => 3600,
  } ->

  exec { "yum update to Caracal in non DELL hosts":
         command => "/usr/bin/yum -y update",
         onlyif => "/bin/rpm -qi dell-system-update | grep 'not installed' &&  /usr/bin/yum list installed | grep openstack-neutron.noarch | grep -i 'yoga'",
         timeout => 3600,
  } ->

# Rename nova config file  
  exec { "mv_nova_conf_old":
         command => "/usr/bin/mv /etc/nova/nova.conf /etc/nova/nova.conf.yoga",
         onlyif  => "/usr/bin/test -e /etc/nova/nova.conf.rpmnew",
  } ->
 
  exec { "mv_nova_conf_new":
         command => "/usr/bin/mv /etc/nova/nova.conf.rpmnew /etc/nova/nova.conf",
         onlyif  => "/usr/bin/test -e /etc/nova/nova.conf.rpmnew",
  } ->

# Rename neutron config file  
  exec { "mv_neutron_conf_old":
         command => "/usr/bin/mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.yoga",
         onlyif  => "/usr/bin/test -e /etc/neutron/neutron.conf.rpmnew",
  } ->

  exec { "mv_neutron_conf_new":
         command => "/usr/bin/mv /etc/neutron/neutron.conf.rpmnew /etc/neutron/neutron.conf",
         onlyif  => "/usr/bin/test -e /etc/neutron/neutron.conf.rpmnew",
  } ->

  exec { "mv_neutron_openvswitch_old":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/openvswitch_agent.ini /etc/neutron/plugins/ml2/openvswitch_agent.ini.yoga",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew",
  } ->

  exec { "mv_neutron_openvswitch_new":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew /etc/neutron/plugins/ml2/openvswitch_agent.ini",
         onlyif  => "/usr/bin/test -e /etc/neutron/plugins/ml2/openvswitch_agent.ini.rpmnew",
  } ->


  exec { "mv_neutron_ml2_old":
         command => "/usr/bin/mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.yoga",
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
