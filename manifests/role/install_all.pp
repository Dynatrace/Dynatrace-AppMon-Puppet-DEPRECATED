class dynatrace::role::install_all (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server componnets installer',
  $installer_bitsize       = $dynatrace::server_installer_bitsize,
  $installer_prefix_dir    = $dynatrace::server_installer_prefix_dir,
  $installer_file_name     = $dynatrace::server_installer_file_name,
  $installer_file_url      = $dynatrace::server_installer_file_url,
  $license_file_name       = $dynatrace::server_license_file_name,
  $license_file_url        = $dynatrace::server_license_file_url,
  $collector_port          = $dynatrace::server_collector_port,
  $do_pwh_connection       = $dynatrace::server_do_pwh_connection,
  $pwh_connection_hostname = $dynatrace::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatrace::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatrace::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatrace::server_pwh_connection_database,
  $pwh_connection_username = $dynatrace::server_pwh_connection_username,
  $pwh_connection_password = $dynatrace::server_pwh_connection_password,

  $env_var_name            = $dynatrace::env_var_name,
  $env_var_file_name       = $dynatrace::env_var_file_name,
  $agent_name              = $dynatrace::agent_name,

  $dynatrace_owner         = $dynatrace::dynatrace_owner,
  $dynatrace_group         = $dynatrace::dynatrace_group
) inherits dynatrace {

  notify{"install_all": message => "executing dynatrace::role::install_all"; }

  validate_re($ensure, ['^present$', '^absent$'])

  # classes will be exeuted in following order: server, server_license, collector, agents_package, wsagent_package, apache_wsagent, java_agent
  class { 'dynatrace::role::server':
  }  -> # and then:
  class { 'dynatrace::role::server_license':
    license_file_url => $license_file_url,
  }  -> # and then:
  class { 'dynatrace::role::collector':
  }  -> # and then:
  class { 'dynatrace::role::agents_package':
  }  -> # and then:
  class { 'dynatrace::role::wsagent_package':
  }  -> # and then:
  class { 'dynatrace::role::apache_wsagent':
  }  -> # and then:
  class { 'dynatrace::role::java_agent':
    env_var_name      => $env_var_name,
    env_var_file_name => $env_var_file_name,
    agent_name        => $agent_name,
  }
}
