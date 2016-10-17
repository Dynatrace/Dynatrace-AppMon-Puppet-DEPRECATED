class dynatrace::role::host_agent (
  $ensure               = 'present',
  $role_name            = 'Dynatrace Host Agent',

  $installer_prefix_dir = $dynatrace::host_agent_installer_prefix_dir,
  $installer_file_name  = $dynatrace::host_agent_installer_file_name,
  $installer_file_url   = $dynatrace::host_agent_installer_file_url,
  $agent_name           = $dynatrace::host_agent_name,
  $collector            = $dynatrace::host_agent_collector,

  $dynatrace_owner      = $dynatrace::dynatrace_owner,
  $dynatrace_group      = $dynatrace::dynatrace_group

) inherits dynatrace {

  notify{"host_agent": message => "executing dynatrace::role::host_agent"; }

  include dynatrace::role::agents_package

  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($env_var_name, $env_var_file_name)
  validate_string($agent_name, $collector_hostname, $collector_port)

  case $::kernel {
    'Linux': {
      $service = 'dynaTraceHostagent'
      $ini_file = "${installer_prefix_dir}/dynatrace/agent/conf/dthostagent.ini"
      $init_scripts = [$service]
    }
    default: {}
  }

  file { $ini_file :
    ensure => file,
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"
  $installer_cache_dir_tree = dirtree($installer_cache_dir)

  include dynatrace::role::dynatrace_user

  file_line { "Inject the Host Agent name ${agent_name} and ${collector} into ${ini_file}":
    ensure => $ensure,
    path   => $ini_file,
    line   => "Name ${agent_name}",
    match  => "^Name host.*$"
  }

  file_line { "Inject the collector name ${agent_name} and ${collector} into ${ini_file}":
    ensure => $ensure,
    path   => $ini_file,
    line   => "Server ${collector}",
    match  => "^Server localhost.*$"
  }
}
