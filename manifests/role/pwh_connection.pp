#pwh_connection
class dynatraceappmon::role::pwh_connection (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server PWH connection',
  $collector_port          = $dynatraceappmon::server_collector_port,
  $pwh_connection_hostname = $dynatraceappmon::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatraceappmon::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatraceappmon::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatraceappmon::server_pwh_connection_database,
  $pwh_connection_username = $dynatraceappmon::server_pwh_connection_username,
  $pwh_connection_password = $dynatraceappmon::server_pwh_connection_password,
) inherits dynatraceappmon {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($collector_port)
  validate_string($pwh_connection_hostname, $pwh_connection_port, $pwh_connection_dbms, $pwh_connection_database, $pwh_connection_username, $pwh_connection_password)

  case $::kernel {
    'Linux': {
      $service = $dynatraceappmon::dynaTraceServer
    }
    default: {}
  }

  wait_until_rest_endpoint_is_ready { 'https://localhost:8021/rest/management/pwhconnection/config':
    ensure  => $ensure,
    require => Service["Start and enable the Dynatrace Server's service: '${service}'"]
  }

  configure_pwh_connection { $pwh_connection_dbms:
    ensure   => $ensure,
    hostname => $pwh_connection_hostname,
    port     => $pwh_connection_port,
    database => $pwh_connection_database,
    username => $pwh_connection_username,
    password => $pwh_connection_password,
    require  => [ Service["Start and enable the Dynatrace Server's service: '${service}'"], Wait_until_rest_endpoint_is_ready['https://localhost:8021/rest/management/pwhconnection/config'] ]
  }
}
