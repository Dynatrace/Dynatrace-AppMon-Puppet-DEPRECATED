class dynatrace::role::apache_wsagent (
  $role_name                   = 'Dynatrace Apache WebServer Agent',
  $apache_config_file_path     = $dynatrace::apache_wsagent_apache_config_file_path
) {
  
  validate_string($apache_config_file_path)

  case $::kernel {
    'Linux': {
      $agent_path = $dynatrace::params::apache_wsagent_linux_agent_path
    }
    default: {}
  }


  file_line { "Inject the ${role_name} into Apache HTTPD's config file":
    path => $apache_config_file_path,
    line => "LoadModule dtagent_module \"${agent_path}\""
  }
}
