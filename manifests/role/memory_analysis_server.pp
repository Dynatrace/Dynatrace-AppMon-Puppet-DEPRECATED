class dynatrace::role::memory_analysis_server (
  $role_name            = 'Dynatrace Memory Analysis Server',
  $installer_bitsize    = $dynatrace::params::memory_analysis_server_installer_bitsize,
  $installer_prefix_dir = $dynatrace::params::memory_analysis_server_installer_prefix_dir,
  $installer_file_name  = $dynatrace::params::memory_analysis_server_installer_file_name,
  $installer_file_url   = $dynatrace::params::memory_analysis_server_installer_file_url,
  $server_port          = $dynatrace::params::memory_analysis_server_server_port,
  $jvm_xms              = $dynatrace::params::memory_analysis_server_jvm_xms,
  $jvm_xmx              = $dynatrace::params::memory_analysis_server_jvm_xmx,
  $jvm_perm_size        = $dynatrace::params::memory_analysis_server_jvm_perm_size,
  $jvm_max_perm_size    = $dynatrace::params::memory_analysis_server_jvm_max_perm_size,
  $dynatrace_owner      = $dynatrace::params::dynatrace_owner,
  $dynatrace_group      = $dynatrace::params::dynatrace_group
) inherits dynatrace::params {
  
  validate_re($installer_bitsize, ['^32', '64'])
  validate_string($installer_prefix_dir, $installer_file_name)
  validate_string($server_port)

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-memory-analysis-server.sh'
      $service = 'dynaTraceAnalysis'
      $init_scripts = [$service]
    }
    default:
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
    content => template("dynatrace/memory_analysis_server/${installer_script_name}"),
    mode    => '0744',
    before  => Dynatrace_installation["Install the ${role_name}"]
  }

  dynatrace_installation { "Install the ${role_name}":
    ensure                => installed,
    installer_prefix_dir  => $installer_prefix_dir,
    installer_file_name   => $installer_file_name,
    installer_file_url    => $installer_file_url,
    installer_script_name => $installer_script_name,
    installer_path_part   => 'dtanalysisserver',
    installer_owner       => $dynatrace_owner,
    installer_group       => $dynatrace_group,
    installer_cache_dir   => $installer_cache_dir
  }

  if $::kernel == 'Linux' {
    dynatrace::resource::configure_init_script { $init_scripts:
      role_name            => $role_name,
      installer_prefix_dir => $installer_prefix_dir,
      owner                => $dynatrace_owner,
      group                => $dynatrace_group,
      notify               => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  }

  service { "Start and enable the ${role_name}'s service: '${service}'":
    ensure => running,
    name   => $service,
    enable => true
  }

  wait_until_port_is_open { $server_port:
    ensure  => present,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }
}
