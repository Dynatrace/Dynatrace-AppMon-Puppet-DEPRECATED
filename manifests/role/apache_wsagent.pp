class dynatrace::role::apache_wsagent (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Apache WebServer Agent',
  $apache_config_file_path = $dynatrace::apache_wsagent_apache_config_file_path
) inherits dynatrace {

  notify{"apache_wsagent": message => "executing dynatrace::role::apache_wsagent"; }
  
  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($apache_config_file_path)

  case $::kernel {
    'Linux': {
      $agent_path = $dynatrace::apache_wsagent_linux_agent_path
    }
    default: {}
  }

  file_line { "Inject the ${role_name} into Apache HTTPD's config file":
    ensure => $ensure,
    path   => $apache_config_file_path,
    line   => "LoadModule dtagent_module \"${agent_path}\"",
    match  => '^LoadModule\ dtagent_module .+'
  }
}
