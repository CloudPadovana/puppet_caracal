class controller_caracal::configure_shibboleth inherits controller_caracal::params {

  file { "/etc/yum.repos.d/shibboleth.repo":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0640",
    content  => file("controller_caracal/shibboleth.repo"),
  }

  package { "shibboleth":
    ensure  => present,
    require => File["/etc/yum.repos.d/shibboleth.repo"],
  }
  
  file { "/etc/shibboleth/horizon-infn-key.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0400",
    source   => "${horizon_infn_key}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/horizon-infn-cert.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0600",
    source   => "${horizon_infn_cert}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/horizon-unipd-key.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0400",
    source   => "${horizon_unipd_key}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/horizon-unipd-cert.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0600",
    source   => "${horizon_unipd_cert}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/keystone-infn-key.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0400",
    source   => "${keystone_infn_key}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/keystone-infn-cert.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0600",
    source   => "${keystone_infn_cert}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/keystone-unipd-key.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0400",
    source   => "${keystone_unipd_key}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/keystone-unipd-cert.pem":
    ensure   => file,
    owner    => "shibd",
    group    => "shibd",
    mode     => "0600",
    source   => "${keystone_unipd_cert}",
    tag      => ["shibboleth_sec"],
  }

  file { "/etc/shibboleth/attribute-map.xml":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    source   => "puppet:///modules/controller_caracal/attribute-map.xml",
    tag      => ["shibboleth_conf"],
  }

  file { "/etc/shibboleth/horizon-infn-metadata.xml":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => epp("controller_caracal/idem-template-metadata.xml.epp", {
                      "entityid" => "https://${site_fqdn}/dashboard-shib",
                      "info_url" => "${shib_info_url}",
                      "sp_name"  => "Cloud Area Padovana (Horizon)",
                      "sp_org"   => "INFN" }),
    tag      => ["shibboleth_conf"],
  }

  file { "/etc/shibboleth/keystone-infn-metadata.xml":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => epp("controller_caracal/idem-template-metadata.xml.epp", {
                      "entityid" => "https://${keystone_cap_fqdn}/v3",
                      "info_url" => "${shib_info_url}",
                      "sp_name"  => "Cloud Area Padovana (Keystone)",
                      "sp_org"   => "INFN" }),
    tag      => ["shibboleth_conf"],
  }

  file { "/etc/shibboleth/horizon-unipd-metadata.xml":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => epp("controller_caracal/idem-template-metadata.xml.epp", {
                      "entityid" => "https://${cv_site_fqdn}/dashboard-shib",
                      "info_url" => "${shib_info_url}",
                      "sp_name"  => "Cloud Veneto (Horizon)",
                      "sp_org"   => "Università degli Studi di Padova" }),
    tag      => ["shibboleth_conf"],
  }

  file { "/etc/shibboleth/keystone-unipd-metadata.xml":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => epp("controller_caracal/idem-template-metadata.xml.epp", {
                      "entityid" => "https://${keystone_cv_fqdn}/v3",
                      "info_url" => "${shib_info_url}",
                      "sp_name"  => "Cloud Veneto (Keystone)",
                      "sp_org"   => "Università degli Studi di Padova" }),
    tag      => ["shibboleth_conf"],
  }

#  controller_caracal::configure_shibboleth::srvmetadata { "/etc/shibboleth/horizon-infn-metadata.xml":
#    entityid => "https://${site_fqdn}/dashboard-shib",
#    info_url => "${shib_info_url}",
#    sp_name  => "Cloud Area Padovana (Horizon)",
#    sp_org   => "INFN"
#  }

#  controller_caracal::configure_shibboleth::srvmetadata { "/etc/shibboleth/keystone-infn-metadata.xml":
#    entityid => "https://${keystone_cap_fqdn}/v3",
#    info_url => "${shib_info_url}",
#    sp_name  => "Cloud Area Padovana (Keystone)",
#    sp_org   => "INFN"
#  }


#  controller_caracal::configure_shibboleth::srvmetadata { "/etc/shibboleth/horizon-unipd-metadata.xml":
#    entityid => "https://${cv_site_fqdn}/dashboard-shib",
#    info_url => "${shib_info_url}",
#    sp_name  => "Cloud Veneto (Horizon)",
#    sp_org   => "Università degli Studi di Padova"
#  }


#  controller_caracal::configure_shibboleth::srvmetadata { "/etc/shibboleth/keystone-unipd-metadata.xml":
#    entityid => "https://${keystone_cv_fqdn}/v3",
#    info_url => "${shib_info_url}",
#    sp_name  => "Cloud Veneto (Keystone)",
#    sp_org   => "Università degli Studi di Padova"
#  }

  file { "/etc/shibboleth/shibboleth2.xml":
    ensure   => file,
    owner    => "root",
    group    => "root",
    mode     => "0644",
    content  => template("controller_caracal/shibboleth2.xml.erb"),
    tag      => ["shibboleth_conf"],
  }
  
  Package["shibboleth"] -> File <| tag == 'shibboleth_sec' |>
  Package["shibboleth"] -> File <| tag == 'shibboleth_conf' |>

#  define srvmetadata ($entityid, $info_url, $sp_name, $sp_org) {
#    file { "$title":
#      ensure   => file,
#      owner    => "root",
#      group    => "root",
#      mode     => "0644",
#      content  => template("controller_caracal/idem-template-metadata.xml.erb"),
#      tag      => ["shibboleth_conf"],
#    }
#  }

}
