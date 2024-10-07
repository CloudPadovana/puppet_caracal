class controller_caracal::install_ca_cert inherits controller_caracal::params {

  yumrepo { "EGI-trustanchors":
          baseurl=> "http://repository.egi.eu/sw/production/cas/1/current/",
          descr=> "EGI Software Repository - REPO META (releaseId,repositoryId,repofileId) - (13352,-,2387)",
          enabled=> 1,
          gpgcheck=> 1,
          gpgkey=> 'http://repository.egi.eu/sw/production/cas/1/GPG-KEY-EUGridPMA-RPM-3',
  }

  $capackages = [ "ca-policy-egi-core",  "fetch-crl" ]
  package { $capackages:
    ensure  => "installed",
    require => YUMREPO[ "EGI-trustanchors" ],
  }

  # TODO remove old INFN CA certificate
  file {'INFN-CA.pem':
    source  => 'puppet:///modules/controller_caracal/INFN-CA.pem',
    path    => '/etc/grid-security/certificates/INFN-CA.pem',
  }

  # Deployment of the CA GEANT_OV_RSA_CA4
  file { '/etc/grid-security/certificates/GEANT_OV_RSA_CA4.pem':
    source => 'puppet:///modules/controller_caracal/GEANT_OV_RSA_CA4.pem',
    tag    => [ "ca_GEANT_OV_RSA_CA4" ],
  }

  file { '/etc/grid-security/certificates/GEANT-OV-RSA-CA-4.crl_url':
    content => "http://crl.usertrust.com/USERTrustRSACertificationAuthority.crl",
    tag     => [ "ca_GEANT_OV_RSA_CA4" ],
  }

  file { '/etc/grid-security/certificates/08ab1bf8.0':
    target => '/etc/grid-security/certificates/GEANT_OV_RSA_CA4.pem',
    tag     => [ "ca_GEANT_OV_RSA_CA4" ],
  }

  file { '/etc/grid-security/certificates/260b2ae6.0':
    target => '/etc/grid-security/certificates/GEANT_OV_RSA_CA4.pem',
    tag     => [ "ca_GEANT_OV_RSA_CA4" ],
  }

  # Registering the external CAs in the system truststore
  file { '/etc/pki/ca-trust/source/anchors/GEANT_OV_RSA_CA4.pem':
    ensure  => link,
    target  => '/etc/grid-security/certificates/GEANT_OV_RSA_CA4.pem',
    tag     => [ "ca_conf" ],
  }
  File <| tag == 'ca_GEANT_OV_RSA_CA4' |> -> File[ "/etc/pki/ca-trust/source/anchors/GEANT_OV_RSA_CA4.pem" ]

  file { '/etc/pki/ca-trust/source/anchors/GEANTeScienceSSLCA4.pem':
    ensure  => link,
    target  => '/etc/grid-security/certificates/GEANTeScienceSSLCA4.pem',
    require => Package[ $capackages ],
    tag     => [ "ca_conf" ],
  }

  file { '/etc/pki/ca-trust/source/anchors/USERTrustRSACertificationAuthority.pem':
    ensure  => link,
    target  => '/etc/grid-security/certificates/USERTrustRSACertificationAuthority.pem',
    require => Package[ $capackages ],
    tag     => [ "ca_conf" ],
  }

  exec { 'update-ca-trust':
    command     => "/usr/bin/update-ca-trust extract",
    refreshonly => true,
  }

  File <| tag == 'ca_conf' |> ~> Exec[ "update-ca-trust" ]
}
