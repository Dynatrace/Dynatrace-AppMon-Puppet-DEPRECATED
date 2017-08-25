#server
class dynatraceappmon::role::server (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server',
  $installer_bitsize       = $dynatraceappmon::server_installer_bitsize,
  $installer_prefix_dir    = $dynatraceappmon::server_installer_prefix_dir,
  $installer_file_name     = $dynatraceappmon::server_installer_file_name,
  $installer_file_url      = $dynatraceappmon::server_installer_file_url,
  $license_file_name       = $dynatraceappmon::server_license_file_name,
  $license_file_url        = $dynatraceappmon::server_license_file_url,
  $collector_port          = $dynatraceappmon::server_embedded_collector_port,
  $dynatrace_owner         = $dynatraceappmon::dynatrace_owner,
  $dynatrace_group         = $dynatraceappmon::dynatrace_group
) inherits dynatraceappmon {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($installer_prefix_dir, $installer_file_name, $license_file_name)
  validate_string($collector_port)

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-server.sh'
      $service = $dynatraceappmon::dynaTraceServer
      $init_scripts = [$service, $dynatraceappmon::dynaTraceFrontendServer, $dynatraceappmon::dynaTraceBackendServer]
      $dynatrace_server_installation_info_file = '/tmp/dynatrace_server_installation.info'
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

  $installer_cache_dir = "${dynatraceappmon::installer_cache_dir}/dynatrace"
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
    before    => File["Configure and copy the ${role_name}'s install script"]
  }

  file { "Configure and copy the ${role_name}'s install script":
    ensure  => $ensure,
    path    => "${installer_cache_dir}/${installer_script_name}",
    content => template("dynatraceappmon/server/${installer_script_name}"),
    mode    => '0744',
  }

  dynatrace_installation { "Install the ${role_name}":
    ensure                  => $installation_ensure,
    installer_prefix_dir    => $installer_prefix_dir,
    installer_file_name     => $installer_file_name,
    installer_file_url      => $installer_file_url,
    installer_script_name   => $installer_script_name,
    installer_path_part     => 'server',
    installer_path_detailed => '',
    installer_owner         => $dynatrace_owner,
    installer_group         => $dynatrace_group,
    installer_cache_dir     => $installer_cache_dir,
    require                 => File["Configure and copy the ${role_name}'s install script"]
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
        'collector_port'       => $collector_port,
        'user'                 => $dynatrace_owner
      },
      require              => Dynatrace_installation["Install the ${role_name}"],
      notify               => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  }

  service { "Start and enable the ${role_name}'s service: '${service}'":
    ensure => $service_ensure,
    name   => $service,
    enable => true,
    notify => [ Wait_until_port_is_open['6699'], Wait_until_port_is_open['2021'], Wait_until_port_is_open['8021'], Wait_until_port_is_open['9911'] ]
  }

  wait_until_port_is_open { '6699':
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  wait_until_port_is_open { '2021':
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  wait_until_port_is_open { '8021':
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  wait_until_port_is_open { '9911':
    ensure  => $ensure,
    require => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }
}
