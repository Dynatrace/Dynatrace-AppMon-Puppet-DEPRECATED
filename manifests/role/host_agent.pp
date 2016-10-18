class dynatrace::role::host_agent (
  $ensure               = 'present',
  $role_name            = 'Dynatrace Host Agent',

  $host_installer_prefix_dir = $dynatrace::host_agent_installer_prefix_dir,

  #Host Agent is installed with server; agents_package should be executed first to install configuration files

  # host_installer_file_name parameter for future useage
  $host_installer_file_name  = $dynatrace::host_agent_installer_file_name,
  # host_installer_file_url parameter for future useage
  $host_installer_file_url   = $dynatrace::host_agent_installer_file_url,

  $host_agent_name      = $dynatrace::host_agent_name,
  $host_collector_name  = $dynatrace::host_agent_collector_name,

  $dynatrace_owner      = $dynatrace::dynatrace_owner,
  $dynatrace_group      = $dynatrace::dynatrace_group

) inherits dynatrace {

  notify{"host_agent": message => "executing dynatrace::role::host_agent"; }

#  include dynatrace::role::agents_package

  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($host_agent_name, $host_collector_name)

  case $::kernel {
    'Linux': {
      $service = 'dynaTraceHostagent'
      $ini_file = "${host_installer_prefix_dir}/dynatrace/agent/conf/dthostagent.ini"
      $init_scripts = [$service]
    }
    default: {}
  }

  file { $ini_file :
    ensure => file,
  }

  $service_ensure = $ensure ? {
    'present' => 'running',
    'absent'  => 'stopped',
    default   => 'running',
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"
  $installer_cache_dir_tree = dirtree($installer_cache_dir)

  include dynatrace::role::dynatrace_user

  file_line { "Inject the Host Agent name ${host_agent_name} and ${host_collector_name} into ${ini_file}":
    ensure => $ensure,
    path   => $ini_file,
    line   => "Name ${host_agent_name}",
    match  => "^Name host.*$"
  }

  file_line { "Inject the collector name ${host_agent_name} and ${host_collector_name} into ${ini_file}":
    ensure => $ensure,
    path   => $ini_file,
    line   => "Server ${host_collector_name}",
    match  => "^Server localhost.*$"
  }

  # ln -s /opt/dynatrace/init.d/dynaTraceHostagent /etc/init.d/dynaTraceHostagent
  exec {"Creates link to execute service":
    command => "ln -s ${host_installer_prefix_dir}/dynatrace/init.d/dynaTraceHostagent /etc/init.d/${service}",
    path    => ['/usr/bin', '/usr/sbin', '/bin'],
    unless  => ["test -L /etc/init.d/${service}"],
    }
  } ->
  service { "Start and enable the ${role_name}'s service: '${service}'":
    ensure => $service_ensure,
    name   => $service,
    enable => true
  }
}
