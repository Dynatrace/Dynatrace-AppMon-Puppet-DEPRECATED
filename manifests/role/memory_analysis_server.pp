class dynatrace::role::memory_analysis_server (
  $ensure               = 'present',
  $role_name            = 'Dynatrace Memory Analysis Server',
  $installer_bitsize    = $dynatrace::memory_analysis_server_installer_bitsize,
  $installer_prefix_dir = $dynatrace::memory_analysis_server_installer_prefix_dir,
  $installer_file_name  = $dynatrace::memory_analysis_server_installer_file_name,
  $installer_file_url   = $dynatrace::memory_analysis_server_installer_file_url,
  $server_port          = $dynatrace::memory_analysis_server_server_port,
  $jvm_xms              = $dynatrace::memory_analysis_server_jvm_xms,
  $jvm_xmx              = $dynatrace::memory_analysis_server_jvm_xmx,
  $jvm_perm_size        = $dynatrace::memory_analysis_server_jvm_perm_size,
  $jvm_max_perm_size    = $dynatrace::memory_analysis_server_jvm_max_perm_size,
  $dynatrace_owner      = $dynatrace::dynatrace_owner,
  $dynatrace_group      = $dynatrace::dynatrace_group
) inherits dynatrace {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_re($installer_bitsize, ['^32', '64'])
  validate_string($installer_prefix_dir, $installer_file_name)
  validate_string($server_port)

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-memory-analysis-server.sh'
      $service = $dynatrace::dynaTraceAnalysis
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


  include dynatrace::role::dynatrace_user

  ensure_resource(file, $installer_cache_dir_tree, {
    ensure  => $directory_ensure,
    require => Class['dynatrace::role::dynatrace_user']
  })

  dynatrace::resource::copy_or_download_file { "Copy or download the ${role_name} installer":
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
    content => template("dynatrace/memory_analysis_server/${installer_script_name}"),
    mode    => '0744',
    before  => Dynatrace_installation["Install the ${role_name}"]
  }

  dynatrace_installation { "Install the ${role_name}":
    ensure                  => $installation_ensure,
    installer_prefix_dir    => $installer_prefix_dir,
    installer_file_name     => $installer_file_name,
    installer_file_url      => $installer_file_url,
    installer_script_name   => $installer_script_name,
    installer_path_part     => 'dtanalysisserver',
    installer_path_detailed => '',
    installer_owner         => $dynatrace_owner,
    installer_group         => $dynatrace_group,
    installer_cache_dir     => $installer_cache_dir
  }

  if $::kernel == 'Linux' {
    dynatrace::resource::configure_init_script { $init_scripts:
      ensure               => $ensure,
      role_name            => $role_name,
      installer_prefix_dir => $installer_prefix_dir,
      owner                => $dynatrace_owner,
      group                => $dynatrace_group,
      init_scripts_params  => {
        'installer_prefix_dir' => $installer_prefix_dir,
        'server_port'          => $server_port,
        'jvm_xms'              => $jvm_xms,
        'jvm_xmx'              => $jvm_xmx,
        'jvm_perm_size'        => $jvm_perm_size,
        'jvm_max_perm_size'    => $jvm_max_perm_size,
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

  wait_until_port_is_open { $server_port:
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }
}
