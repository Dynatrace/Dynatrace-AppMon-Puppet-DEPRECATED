class dynatrace::role::apache_wsagent (
  $role_name                   = 'Dynatrace Apache WebServer Agent',
  $apache_config_file_path     = $dynatrace::apache_wsagent_apache_config_file_path,
  $apache_init_script_path     = $dynatrace::apache_wsagent_apache_init_script_path,
  $apache_do_patch_init_script = $dynatrace::apache_wsagent_apache_do_patch_init_script,
  $agent_path                  = $dynatrace::apache_wsagent_linux_agent_path
) {
  
  validate_bool($apache_do_patch_init_script)
  validate_string($apache_config_file_path, $apache_init_script_path)

  file_line { "Inject the ${role_name} into Apache HTTPD's config file":
    path => $apache_config_file_path,
    line => "LoadModule dtagent_module \"${agent_path}\""
  }

  if $apache_do_patch_init_script {
    editfile { "Patch the Apache HTTPD's init script so that it is started after the ${role_name}":
      path   => $apache_init_script_path,
      match  => '/^(# Required-Start:)(.*?)( dynaTraceWebServeragent)?$/',
      ensure => "\\1\\2 dynaTraceWebServeragent"
    }

    editfile { "Patch the Apache HTTPD's init script so that it is stopped before the ${role_name}":
      path    => $apache_init_script_path,
      match   => '/^(# Required-Stop:)(.*?)( dynaTraceWebServeragent)?$/',
      ensure  => "\\1\\2 dynaTraceWebServeragent",
      require => Editfile["Patch the Apache HTTPD's init script so that it is started after the ${role_name}"]
    }
  }
}
