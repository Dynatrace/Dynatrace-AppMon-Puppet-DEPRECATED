class dynatrace::role::pwh_connection (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server PHW connection',
  $collector_port          = $dynatrace::server_collector_port,
  $pwh_connection_hostname = $dynatrace::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatrace::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatrace::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatrace::server_pwh_connection_database,
  $pwh_connection_username = $dynatrace::server_pwh_connection_username,
  $pwh_connection_password = $dynatrace::server_pwh_connection_password,
) inherits dynatrace {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($installer_prefix_dir, $installer_file_name, $license_file_name)
  validate_string($collector_port)
  validate_string($pwh_connection_hostname, $pwh_connection_port, $pwh_connection_dbms, $pwh_connection_database, $pwh_connection_username, $pwh_connection_password)
    
  case $::kernel {
    'Linux': {
      $service = $dynatrace::dynaTraceServer
    }
    default: {}
  }
  
  $service_ensure = $ensure ? {
    'present' => 'running',
    'absent'  => 'stopped',
    default   => 'running',
  }

  service { "Start and enable the ${role_name}'s service: '${service}'":
    ensure => $service_ensure,
    name   => $service,
    enable => true
  }
  
  wait_until_port_is_open { $collector_port:
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  wait_until_port_is_open { '2021':
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  if $collector_port != '6699' {
    wait_until_port_is_open { '6699':
      ensure  => $ensure,
      require => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  }

  wait_until_port_is_open { '8021':
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  wait_until_port_is_open { '9911':
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }
  
  wait_until_rest_endpoint_is_ready { 'https://localhost:8021/rest/management/pwhconnection/config':
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  configure_pwh_connection { $pwh_connection_dbms:
    ensure   => $ensure,
    hostname => $pwh_connection_hostname,
    port     => $pwh_connection_port,
    database => $pwh_connection_database,
    username => $pwh_connection_username,
    password => $pwh_connection_password,
    require  => Wait_until_rest_endpoint_is_ready['https://localhost:8021/rest/management/pwhconnection/config']
  }
}
