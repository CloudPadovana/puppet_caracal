class controller_caracal::configure_calendarpanel inherits controller_caracal::params {

#  vcsrepo { '/root/calendarpanel':
#    ensure   => present,
#    provider => git,
#    remote   => 'origin',
#    source   => {
#      'origin'       => 'https://github.com/CloudPadovana/calendarpanel.git',
#      'other_remote' => 'https://github.com/CloudPadovana/calendarpanel.git'
#    }   
#  }

  file {'_1391_calendarpanel_settings.py':
       content     => template('controller_caracal/_1391_calendarpanel_settings.py.erb'),
       path        => '/usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.d/_1391_calendarpanel_settings.py',
       backup      => true,
   }
  
   file { '/usr/share/openstack-dashboard/openstack_dashboard/enabled/_1390_project_calendar_panel.py':
          ensure => present,
          source => "/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/calendarpanel/local/enabled/_1390_project_calendar_panel.py",
   }
   

  file {'settings.py':
       content     => template('controller_caracal/settings.py.erb'),
       path        => '/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/calendarpanel/settings.py',
   }   

}
