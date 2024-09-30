class controller_caracal ($cloud_role_foreman = "undefined") {

  $cloud_role = $cloud_role_foreman

  $ocatapackages = [ "crudini",

                   ]


     package { $ocatapackages: ensure => "installed" }

  # Install CA
  class {'controller_caracal::install_ca_cert':}

  # Ceph
  class {'controller_caracal::ceph':}
  
  # Configure keystone
  class {'controller_caracal::configure_keystone':}
  
  # Configure glance
  class {'controller_caracal::configure_glance':}

  # Configure nova
  class {'controller_caracal::configure_nova':}

## FF for placement in xena
  # Configure placement
  class {'controller_caracal::configure_placement':}
###

  # Configure ec2
  class {'controller_caracal::configure_ec2':}

  # Configure neutron
  class {'controller_caracal::configure_neutron':}

  # Configure cinder
  class {'controller_caracal::configure_cinder':}

  # Configure heat
  class {'controller_caracal::configure_heat':}

  # Configure horizon
  class {'controller_caracal::configure_horizon':}

  # Configure Shibboleth if AII and Shibboleth are enabled
  if ($::controller_caracal::params::enable_aai_ext and $::controller_caracal::params::enable_shib)  {
    class {'controller_caracal::configure_shibboleth':}
  }

  # Configure OpenIdc if AII and openidc are enabled
  if ($::controller_caracal::params::enable_aai_ext and ($::controller_caracal::params::enable_oidc or $::controller_caracal::params::enable_infncloud))  {
    class {'controller_caracal::configure_openidc':}
  }
 
  # Service
  class {'controller_caracal::service':}

  
  # do passwdless access
  class {'controller_caracal::pwl_access':}
  
  
  # configure remote syslog
  class {'controller_caracal::rsyslog':}
  
  

       Class['controller_caracal::install_ca_cert'] -> Class['controller_caracal::configure_keystone']
       Class['controller_caracal::configure_keystone'] -> Class['controller_caracal::configure_glance']
       Class['controller_caracal::configure_glance'] -> Class['controller_caracal::configure_nova']
       Class['controller_caracal::configure_nova'] -> Class['controller_caracal::configure_placement']
       Class['controller_caracal::configure_placement'] -> Class['controller_caracal::configure_neutron']
       Class['controller_caracal::configure_neutron'] -> Class['controller_caracal::configure_cinder']
       Class['controller_caracal::configure_cinder'] -> Class['controller_caracal::configure_horizon']
       Class['controller_caracal::configure_horizon'] -> Class['controller_caracal::configure_heat']

  }
