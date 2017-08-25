#stop_all_processes
class dynatraceappmon::role::stop_all_processes (
  $ensure                  = 'stopped',
  $role_name               = 'Dynatrace Server stop all processes',
  $installer_bitsize       = $dynatraceappmon::server_installer_bitsize,
  $installer_prefix_dir    = $dynatraceappmon::server_installer_prefix_dir,
  $installer_file_name     = $dynatraceappmon::server_installer_file_name,
  $installer_file_url      = $dynatraceappmon::server_installer_file_url,
  $license_file_name       = $dynatraceappmon::server_license_file_name,
  $license_file_url        = $dynatraceappmon::server_license_file_url,
  $collector_port          = $dynatraceappmon::server_collector_port,
  $pwh_connection_hostname = $dynatraceappmon::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatraceappmon::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatraceappmon::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatraceappmon::server_pwh_connection_database,
  $pwh_connection_username = $dynatraceappmon::server_pwh_connection_username,
  $pwh_connection_password = $dynatraceappmon::server_pwh_connection_password,
  $dynatrace_owner         = $dynatraceappmon::dynatrace_owner,
  $dynatrace_group         = $dynatraceappmon::dynatrace_group
) inherits dynatraceappmon {

  case $::kernel {
    'Linux': {
      $services_to_stop_array = $dynatraceappmon::services_to_manage_array
    }
    default: {}
  }

  $services_to_stop_array.each |$x| {
    service { "${role_name}: Service ${x} will be stopped.":
      ensure => 'stopped',
      name   => $x,
    }
  }

  #TODO add lambda to delay execution on agent
  $services_to_stop_string = join($services_to_stop_array,',')
#  notify{"server - stop all processes": message => "executing dynatraceappmon::role::stop_all_processes  services_to_stop=${services_to_stop_string}"; }

  stop_processes { "Stop the ${role_name} processes: ${services_to_stop_string}":
    services_to_stop => $services_to_stop_string,
    installer_owner  => $dynatrace_owner,
    installer_group  => $dynatrace_group,
  }
}
