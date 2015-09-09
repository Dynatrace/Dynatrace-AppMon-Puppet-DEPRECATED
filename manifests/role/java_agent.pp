class dynatrace::role::java_agent (
  $role_name          = 'Dynatrace Java Agent',
  $env_var_name       = $dynatrace::java_agent_env_var_name,
  $env_var_file_name  = $dynatrace::java_agent_env_var_file_name,
  $agent_name         = $dynatrace::java_agent_name,
  $collector_hostname = $dynatrace::java_agent_collector_hostname,
  $collector_port     = $dynatrace::java_agent_collector_port
  $agent_path         = $dynatrace::java_agent_linux_agent_path
) inherits {
  
  validate_string($env_var_name, $env_var_file_name)
  validate_string($agent_name, $collector_hostname, $collector_port)

  file_line { "Inject the ${role_name} into ${env_var_file_name}":
    path => $env_var_file_name,
    line => "export ${env_var_name}=\"$${env_var_name} -agentpath:${agent_path}=name=${agent_name},collector=${collector_hostname}:${collector_port}\""
  }
}
