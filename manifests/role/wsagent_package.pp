class dynatrace::role::wsagent_package (
  $role_name            = 'Dynatrace WebServer Agent',
  $installer_prefix_dir = $dynatrace::wsagent_package_installer_prefix_dir,
  $installer_file_name  = $dynatrace::wsagent_package_installer_file_name,
  $installer_file_url   = $dynatrace::wsagent_package_installer_file_url,
  $agent_name           = $dynatrace::wsagent_package_agent_name,
  $collector_hostname   = $dynatrace::wsagent_package_collector_hostname,
  $collector_port       = $dynatrace::wsagent_package_collector_port,
  $dynatrace_owner      = $dynatrace::dynatrace_owner,
  $dynatrace_group      = $dynatrace::dynatrace_group
) inherits dynatrace {
  
  validate_string($installer_prefix_dir, $installer_file_name)
  validate_string($agent_name, $collector_hostname, $collector_port)

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-wsagent-package.sh'
      $service = 'dynaTraceWebServerAgent'
      $init_scripts = [$service]
    }
    default: {}
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"


  class { 'dynatrace::role::dynatrace_user':
    dynatrace_owner => $dynatrace_owner,
    dynatrace_group => $dynatrace_group
  }

  file { 'Create the installer cache directory':
    ensure  => directory,
    path    => $installer_cache_dir,
    require => Class['dynatrace::role::dynatrace_user']
  }

  dynatrace::resource::copy_or_download_file { "Copy or download the ${role_name} installer":
    file_name => $installer_file_name,
    file_url  => $installer_file_url,
    path      => "${installer_cache_dir}/${installer_file_name}",
    require   => File['Create the installer cache directory'],
    notify    => [
      File["Configure and copy the ${role_name}'s install script"],
      Dynatrace_installation["Install the ${role_name}"]
    ]
  }

  file { "Configure and copy the ${role_name}'s install script":
    path    => "${installer_cache_dir}/${installer_script_name}",
    content => template("dynatrace/wsagent_package/${installer_script_name}"),
    mode    => '0744',
    before  => Dynatrace_installation["Install the ${role_name}"]
  }

  dynatrace_installation { "Install the ${role_name}":
    ensure                => installed,
    installer_prefix_dir  => $installer_prefix_dir,
    installer_file_name   => $installer_file_name,
    installer_file_url    => $installer_file_url,
    installer_script_name => $installer_script_name,
    installer_path_part   => 'agent',
    installer_owner       => $dynatrace_owner,
    installer_group       => $dynatrace_group,
    installer_cache_dir   => $installer_cache_dir
  }

  file { "Configure and copy the ${role_name}'s 'dtwsagent.ini' file":
    path    => "${installer_prefix_dir}/dynatrace/agent/conf/dtwsagent.ini",
    owner   => $dynatrace_owner,
    group   => $dynatrace_group,
    content => template('dynatrace/wsagent_package/dtwsagent.ini.erb'),
    require => Dynatrace_installation["Install the ${role_name}"],
    notify  => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  if $::kernel == 'Linux' {
    dynatrace::resource::configure_init_script { $init_scripts:
      role_name            => $role_name,
      installer_prefix_dir => $installer_prefix_dir,
      owner                => $dynatrace_owner,
      group                => $dynatrace_group,
      params               => { 'installer_prefix_dir' => $installer_prefix_dir },
      notify               => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  }

  service { "Start and enable the ${role_name}'s service: '${service}'":
    ensure => running,
    name   => $service,
    enable => true
  }
}
