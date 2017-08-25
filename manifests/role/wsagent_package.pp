#wsagent_package
class dynatraceappmon::role::wsagent_package (
  $ensure               = 'present',
  $role_name            = 'Dynatrace WebServer Agent',
  $installer_prefix_dir = $dynatraceappmon::wsagent_package_installer_prefix_dir,
  $installer_file_name  = $dynatraceappmon::wsagent_package_installer_file_name,
  $installer_file_url   = $dynatraceappmon::wsagent_package_installer_file_url,
  $agent_name           = $dynatraceappmon::wsagent_package_agent_name,
  $collector_hostname   = $dynatraceappmon::wsagent_package_collector_hostname,
  $collector_port       = $dynatraceappmon::wsagent_package_collector_port,
  $dynatrace_owner      = $dynatraceappmon::dynatrace_owner,
  $dynatrace_group      = $dynatraceappmon::dynatrace_group,
) inherits dynatraceappmon {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($installer_prefix_dir, $installer_file_name)
  validate_string($agent_name, $collector_hostname, $collector_port)

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-wsagent-package.sh'
      $service = $dynatraceappmon::dynaTraceWebServerAgent
      $init_scripts = [$service]
    }
    default: {}
  }

  $directory_ensure = $ensure ? {
    'present' => 'directory',
    'absent'  => 'absent',
    default   => 'directory',
  }

  $installation_ensure = $ensure ? {
    'present' => 'installed',
    'absent'  => 'uninstalled',
    default   => 'installed',
  }

  $service_ensure = $ensure ? {
    'present' => 'running',
    'absent'  => 'stopped',
    default   => 'running',
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"
  $installer_cache_dir_tree = dirtree($installer_cache_dir)


  include dynatraceappmon::role::dynatrace_user

  ensure_resource(file, $installer_cache_dir_tree, {
    ensure  => $directory_ensure,
    require => Class['dynatraceappmon::role::dynatrace_user']
  })

  dynatraceappmon::resource::copy_or_download_file { "Copy or download the ${role_name} installer":
    ensure    => $ensure,
    file_name => $installer_file_name,
    file_url  => $installer_file_url,
    path      => "${installer_cache_dir}/${installer_file_name}",
    require   => File[$installer_cache_dir_tree],
    notify    => [
      File["Configure and copy the ${role_name}'s install script"],
      Dynatrace_installation["Install the ${role_name}"]
    ]
  }

  file { "Configure and copy the ${role_name}'s install script":
    ensure  => $ensure,
    path    => "${installer_cache_dir}/${installer_script_name}",
    content => template("dynatraceappmon/wsagent_package/${installer_script_name}"),
    mode    => '0744',
    before  => Dynatrace_installation["Install the ${role_name}"]
  }

  dynatrace_installation { "Install the ${role_name}":
    ensure                  => $installation_ensure,
    installer_prefix_dir    => $installer_prefix_dir,
    installer_file_name     => $installer_file_name,
    installer_file_url      => $installer_file_url,
    installer_script_name   => $installer_script_name,
    installer_path_part     => 'agent',
    installer_path_detailed => "${installer_prefix_dir}/dynatrace/agent/conf/agentversion.${agent_name}",
    installer_owner         => $dynatrace_owner,
    installer_group         => $dynatrace_group,
    installer_cache_dir     => $installer_cache_dir
  }

  file { "Configure and copy the ${role_name}'s 'dtwsagent.ini' file":
    ensure  => $ensure,
    path    => "${installer_prefix_dir}/dynatrace/agent/conf/dtwsagent.ini",
    owner   => $dynatrace_owner,
    group   => $dynatrace_group,
    content => template('dynatraceappmon/wsagent_package/dtwsagent.ini.erb'),
    require => Dynatrace_installation["Install the ${role_name}"],
    notify  => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  if $::kernel == 'Linux' {
    dynatraceappmon::resource::configure_init_script { $init_scripts:
      ensure               => $ensure,
      role_name            => $role_name,
      installer_prefix_dir => $installer_prefix_dir,
      owner                => $dynatrace_owner,
      group                => $dynatrace_group,
      init_scripts_params  => {
        'installer_prefix_dir' => $installer_prefix_dir,
        'user'                 => $dynatrace_owner
      },
      notify               => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  }

  service { "Start and enable the ${role_name}'s service: '${service}'":
    ensure => $service_ensure,
    name   => $service,
    enable => true
  }
}
