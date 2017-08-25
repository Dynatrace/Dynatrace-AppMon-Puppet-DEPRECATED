#install_all
class dynatraceappmon::role::install_all (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server componnets installer',
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

  # java Agent parameters
  $env_var_name            = $dynatraceappmon::java_agent_env_var_name,
  $env_var_file_name       = $dynatraceappmon::java_agent_env_var_file_name,
  $agent_name              = $dynatraceappmon::java_agent_name,

  # Host Agent parameters
  $hostagent_name             = $dynatraceappmon::host_agent_name,
  $host_installer_prefix_dir = $dynatraceappmon::host_agent_installer_prefix_dir,
  $host_installer_file_name  = $dynatraceappmon::host_agent_installer_file_name,
  $host_installer_file_url   = $dynatraceappmon::host_agent_installer_file_url,
  $host_collector_name       = $dynatraceappmon::host_agent_collector_name,

  $dynatrace_owner         = $dynatraceappmon::dynatrace_owner,
  $dynatrace_group         = $dynatraceappmon::dynatrace_group,

  ) inherits dynatraceappmon {

  validate_re($ensure, ['^present$', '^absent$'])

  # classes will be exeuted in following order: server, server_license, collector, agents_package, wsagent_package, apache_wsagent, java_agent, host agent
  # note that installation order is important for base modules: server, server_license, collector, agents_package
  class { 'dynatraceappmon::role::server':
  }# and then:
  -> class { 'dynatraceappmon::role::server_license':
    license_file_url => $license_file_url,
  }# and then:
  -> class { 'dynatraceappmon::role::collector':
  }# and then:
  -> class { 'dynatraceappmon::role::agents_package':
  }# and then:
  -> class { 'dynatraceappmon::role::wsagent_package':
  }# and then:
  -> class { 'dynatraceappmon::role::apache_wsagent':
  }# and then:
  -> class { 'dynatraceappmon::role::java_agent':
    env_var_name      => $env_var_name,
    env_var_file_name => $env_var_file_name,
    agent_name        => $agent_name,
  }
  -> class { 'dynatraceappmon::role::host_agent':
    host_agent_name           => $hostagent_name,
    host_installer_prefix_dir => $host_installer_prefix_dir,
    host_installer_file_name  => $host_installer_file_name,
    host_installer_file_url   => $host_installer_file_url,
    host_collector_name       => $host_collector_name,
  }
  -> class { 'dynatraceappmon::role::memory_analysis_server':
  }
  -> class { 'dynatraceappmon::role::php_one_agent':
  }
}
