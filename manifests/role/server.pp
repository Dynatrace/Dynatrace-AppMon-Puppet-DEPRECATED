class dynatrace::role::server (
  $role_name               = 'Dynatrace Server',
  $installer_prefix_dir    = $dynatrace::params::server_installer_prefix_dir,
  $installer_file_name     = $dynatrace::params::server_installer_file_name,
  $installer_file_url      = $dynatrace::params::server_installer_file_url,
  $license_file_name       = $dynatrace::params::server_license_file_name,
  $license_file_url        = $dynatrace::params::server_license_file_url,
  $collector_port          = $dynatrace::params::server_collector_port,
  $do_pwh_connection       = $dynatrace::params::server_do_pwh_connection,
  $pwh_connection_hostname = $dynatrace::params::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatrace::params::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatrace::params::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatrace::params::server_pwh_connection_database,
  $pwh_connection_username = $dynatrace::params::server_pwh_connection_username,
  $pwh_connection_password = $dynatrace::params::server_pwh_connection_password,
  $dynatrace_owner         = $dynatrace::params::dynatrace_owner,
  $dynatrace_group         = $dynatrace::params::dynatrace_group
) inherits dynatrace::params {
  
  validate_bool($do_pwh_connection)
  validate_string($installer_prefix_dir, $installer_file_name, $license_file_name)
  validate_string($collector_port)
  validate_string($pwh_connection_hostname, $pwh_connection_port, $pwh_connection_dbms, $pwh_connection_database, $pwh_connection_username, $pwh_connection_password)

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-server.sh'
      $service = 'dynaTraceServer'
      $init_scripts = [$service, 'dynaTraceFrontendServer', 'dynaTraceBackendServer']
    }
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"


  class { 'dynatrace::role::dynatrace_user':
    dynatrace_owner => $dynatrace_owner,
    dynatrace_group => $dynatrace_group
  }

  file { "Create the installer cache directory":
    path    => $installer_cache_dir,
    ensure  => directory,
    require => Class['dynatrace::role::dynatrace_user']
  }

  dynatrace::resource::copy_or_download_file { "Copy or download the ${role_name} installer":
    file_name => $installer_file_name,
    file_url  => $installer_file_url,
    path      => "${installer_cache_dir}/${installer_file_name}",
    require   => File["Create the installer cache directory"],
    notify    => [
      File["Configure and copy the ${role_name}'s install script"],
      Dynatrace_installation["Install the ${role_name}"]
    ]
  }

  file { "Configure and copy the ${role_name}'s install script":
    path    => "${installer_cache_dir}/${installer_script_name}",
    content => template("dynatrace/server/${installer_script_name}"),
    mode    => '0744',
    before  => Dynatrace_installation["Install the ${role_name}"]
  }

  if $::dynatrace_server_service_installed {
    service { "Stop and disable the ${role_name}'s service(s): '$service'":
      name      => $service,
      ensure    => stopped,
      enable    => false,
      subscribe => Dynatrace_installer["Fetch the ${role_name} installer"],
      before    => Dynatrace_installation["Install the ${role_name}"]
    }
  }

  dynatrace_installation { "Install the ${role_name}":
    installer_prefix_dir  => $installer_prefix_dir,
    installer_file_name   => $installer_file_name,
    installer_file_url    => $installer_file_url,
    installer_script_name => $installer_script_name,
    installer_path_part   => 'server',
    installer_owner       => $dynatrace_owner,
    installer_group       => $dynatrace_group,
    installer_cache_dir   => $installer_cache_dir,
    ensure                => installed
  }

  if $::kernel == 'Linux' {
    dynatrace::resource::configure_init_script { $init_scripts:
      role_name            => $role_name,
      installer_prefix_dir => $installer_prefix_dir,
      notify               => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  }

  service { "Start and enable the ${role_name}'s service: '${service}'":
    name   => $service,
    ensure => running,
    enable => true
  }

  dynatrace::resource::copy_or_download_file { "Copy or download the Dynatrace license file":
    file_name => $license_file_name,
    file_url  => $license_file_url,
    path      => "${installer_prefix_dir}/dynatrace/server/conf/dtlicense.key",
    require   => Service["Start and enable the ${role_name}'s service: '${service}'"]
  }

  wait_until_rest_endpoint_is_ready { 'http://localhost:8020/rest/management/pwhconnection/config':
    require => Service["Start and enable the ${role_name}'s service: '${service}'"],
    ensure  => present
  }
}
