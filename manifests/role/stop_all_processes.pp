#stop_all_processes
class dynatrace::role::stop_all_processes (
  $ensure                  = 'stopped',
  $role_name               = 'Dynatrace Server stop all processes',
  $installer_bitsize       = $dynatrace::server_installer_bitsize,
  $installer_prefix_dir    = $dynatrace::server_installer_prefix_dir,
  $installer_file_name     = $dynatrace::server_installer_file_name,
  $installer_file_url      = $dynatrace::server_installer_file_url,
  $license_file_name       = $dynatrace::server_license_file_name,
  $license_file_url        = $dynatrace::server_license_file_url,
  $collector_port          = $dynatrace::server_collector_port,
  $pwh_connection_hostname = $dynatrace::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatrace::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatrace::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatrace::server_pwh_connection_database,
  $pwh_connection_username = $dynatrace::server_pwh_connection_username,
  $pwh_connection_password = $dynatrace::server_pwh_connection_password,
  $dynatrace_owner         = $dynatrace::dynatrace_owner,
  $dynatrace_group         = $dynatrace::dynatrace_group
) inherits dynatrace {

  case $::kernel {
    'Linux': {
      $services_to_stop_array = $dynatrace::services_to_manage_array
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
#  notify{"server - stop all processes": message => "executing dynatrace::role::stop_all_processes  services_to_stop=${services_to_stop_string}"; }

  stop_processes { "Stop the ${role_name} processes: ${services_to_stop_string}":
    services_to_stop => $services_to_stop_string,
    installer_owner  => $dynatrace_owner,
    installer_group  => $dynatrace_group,
  }
}
