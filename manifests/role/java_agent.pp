class dynatrace::role::java_agent (

  $ensure             = 'present',
  $role_name          = 'Dynatrace Java Agent',
  $env_var_name       = $dynatrace::java_agent_env_var_name,
  $env_var_file_name  = $dynatrace::java_agent_env_var_file_name,
  $agent_name         = $dynatrace::java_agent_name,
  $collector_hostname = $dynatrace::java_agent_collector_hostname,
  $collector_port     = $dynatrace::java_agent_collector_port,
  $java_agent_linux_agent_path = $dynatrace::java_agent_linux_agent_path
) inherits dynatrace {
  
  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($env_var_name, $env_var_file_name)
  validate_string($agent_name, $collector_hostname, $collector_port)

  case $::kernel {
    'Linux': {
      $agent_path = $dynatrace::java_agent_linux_agent_path
    }
    default: {}
  }

  file { $env_var_file_name :
    ensure => file,
  }
  
  file_line { "Inject the ${role_name} into ${env_var_file_name}":
    ensure => $ensure,
    path   => $env_var_file_name,
    line   => "export ${env_var_name}=\"$${env_var_name} -agentpath:${agent_path}=name=${agent_name},collector=${collector_hostname}:${collector_port}\"",
    match  => "^.+-agentpath:.+"
  }
}
