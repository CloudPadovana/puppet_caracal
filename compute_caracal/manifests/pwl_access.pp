class compute_caracal::pwl_access {

include compute_caracal::params

  $home_dir = "/var/lib/nova"
  $config = "Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
  "

  user {'nova':
        ensure	=> present,
        shell	=> '/bin/bash',
        require	=> Package["openstack-nova-common"],
       }

# Needed to attach equallogic volumes
    exec {"nova disk membership":
                  unless => "/bin/grep 'disk.*nova' /etc/group 2>/dev/null",
                  command => "/sbin/usermod -a -G disk nova",
                  require => User['nova'],
         }
         
       
  file {"nova_sshdir":
            ensure  => directory,
            path    => "$home_dir/.ssh",
            owner   => nova,
            group   => nova,
            mode    => "0700",
       }

  file {"config_ssh":
            ensure  => file,
            path    => "$home_dir/.ssh/config",
	    content => "$config",
            owner   => nova,
            group   => nova,
       }

  file {"private_key":
	    source  => "puppet:///modules/compute_caracal/$compute_caracal::params::private_key",
	    path    => "$home_dir/.ssh/id_rsa",
            ensure  => file,
            owner   => nova,
            group   => nova,
            mode    => "0600",
       }

  file {"public_key":
            ensure  => file,
            path    => "$home_dir/.ssh/id_rsa.pub",
            content => "$compute_caracal::params::pub_key",
            owner   => nova,
            group   => nova,
       }

  file {"authorized_keys":
            ensure  => file,
            path    => "$home_dir/.ssh/authorized_keys",
            content => "$compute_caracal::params::pub_key",
            owner   => nova,
            group   => nova,
       }
}
