class dynatrace::role::server (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server',
  $version                 = $dynatrace::version,
  $installer_prefix_dir    = $dynatrace::server_installer_prefix_dir,
  $installer_file_name     = $dynatrace::server_installer_file_name,
  $installer_file_url      = $dynatrace::server_installer_file_url,
  $license_file_name       = $dynatrace::server_license_file_name,
  $license_file_url        = $dynatrace::server_license_file_url,
  $collector_port          = $dynatrace::server_collector_port,
  $do_pwh_connection       = $dynatrace::server_do_pwh_connection,
  $pwh_connection_hostname = $dynatrace::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatrace::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatrace::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatrace::server_pwh_connection_database,
  $pwh_connection_username = $dynatrace::server_pwh_connection_username,
  $pwh_connection_password = $dynatrace::server_pwh_connection_password,
  $dynatrace_owner         = $dynatrace::dynatrace_owner,
  $dynatrace_group         = $dynatrace::dynatrace_group) {
  validate_bool($do_pwh_connection)
  validate_string($installer_prefix_dir, $installer_file_name, $license_file_name)
  validate_string($collector_port)
  validate_string($pwh_connection_hostname, $pwh_connection_port, $pwh_connection_dbms, $pwh_connection_database, 
  $pwh_connection_username, $pwh_connection_password)

  case $::kernel {
    'Linux' : {
      $installer_script_name = 'install-server.sh'
      $service = 'dynaTraceServer'
      $init_scripts = [$service, 'dynaTraceFrontendServer', 'dynaTraceBackendServer']
    }
    default : {
    }
  }

  $directory_ensure = $ensure ? {
    'present' => 'directory',
    'absent'  => 'absent',
    default   => 'directory',
  }

  $link_ensure = $ensure ? {
    'present' => 'link',
    'absent'  => 'absent',
    default   => 'link',
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

  $enabled_ensure = $ensure ? {
    'present' => true,
    'absent'  => false,
    default   => true,
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"

  dynatrace::resource::copy_or_download_file { "Copy or download the ${role_name} installer":
    ensure    => $ensure,
    file_name => $installer_file_name,
    file_url  => $installer_file_url,
    path      => "${installer_cache_dir}/${installer_file_name}",
    require   => File['Create the installer cache directory'],
  }

  if $ensure == present {
    file { "Configure and copy the ${role_name}'s install script":
      ensure  => $ensure,
      path    => "${installer_cache_dir}/${installer_script_name}",
      content => template("dynatrace/server/${installer_script_name}"),
      mode    => '0744',
      before  => Exec["Run the ${role_name}'s install script"],
      require => Dynatrace::Resource::Copy_or_download_file["Copy or download the ${role_name} installer"],
    }

    exec { "Run the ${role_name}'s install script":
      command => "${installer_cache_dir}/${installer_script_name}",
      creates => "/opt/dynatrace-${version}/server",
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      user    => 'root',
      group   => 'root',
      before  => File["Create symbolic lync for dynatrace server"],
    }

    service { "Start and enable the ${role_name}'s service: '${service}'":
      ensure    => $service_ensure,
      require   => [
        File["Create symbolic lync for ${role_name} Server"],
        File["Create symbolic lync for ${role_name} FrontServer"],
        File["Create symbolic lync for ${role_name} BackendServer"],
        ],
      name      => $service,
      enable    => $enabled_ensure,
      hasstatus => false,
      status    => '/etc/init.d/dynaTraceServer status | grep "is running"',
    }

    wait_until_port_is_open { $collector_port:
      ensure  => $ensure,
      require => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }

    wait_until_port_is_open { '2021':
      ensure  => $ensure,
      require => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }

    wait_until_port_is_open { '6699':
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

  } else {
    service { "Stop and disable the ${role_name}'s service: '${service}'":
      ensure => $service_ensure,
      name   => $service,
      before => File["Create symbolic lync for ${role_name} Server"],
    }
    file { "Ensure ${role_name}'s directory deleted":
      ensure => $directory_ensure,
      path   => "/opt/dynatrace-${version}",
      force  => true,
      require => Service["Stop and disable the ${role_name}'s service: '${service}'"],
    }
  }

  file { "Create symbolic lync for dynatrace server":
    ensure => $link_ensure,
    path   => "${installer_prefix_dir}/dynatrace",
    target => "${installer_prefix_dir}/dynatrace-${version}",
  }

  if $::kernel == 'Linux' {
    file { "Create symbolic lync for ${role_name} Server":
      ensure  => $link_ensure,
      path    => "/etc/init.d/dynaTraceServer",
      target  => "${installer_prefix_dir}/dynatrace-${version}/init.d/dynaTraceServer",
      mode    => 'u=rwx,go=rx',
      require => File["Create symbolic lync for dynatrace server"],
    }

    file { "Create symbolic lync for ${role_name} FrontServer":
      ensure  => $link_ensure,
      path    => "/etc/init.d/dynaTraceFrontendServer",
      target  => "${installer_prefix_dir}/dynatrace-${version}/init.d/dynaTraceFrontendServer",
      mode    => 'u=rwx,go=rx',
      require => File["Create symbolic lync for dynatrace server"],
    }

    file { "Create symbolic lync for ${role_name} BackendServer":
      ensure  => $link_ensure,
      path    => "/etc/init.d/dynaTraceBackendServer",
      target  => "${installer_prefix_dir}/dynatrace-${version}/init.d/dynaTraceBackendServer",
      mode    => 'u=rwx,go=rx',
      require => File["Create symbolic lync for dynatrace server"],
    }
  }

  if $do_pwh_connection {
    wait_until_rest_endpoint_is_ready { 'https://localhost:8021/rest/management/pwhconnection/config':
      ensure  => $ensure,
      require => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }

    configure_pwh_connection { $pwh_connection_dbms:
      ensure   => $ensure,
      hostname => $pwh_connection_hostname,
      port     => $pwh_connection_port,
      database => $pwh_connection_database,
      username => $pwh_connection_username,
      password => $pwh_connection_password,
      require  => Wait_until_rest_endpoint_is_ready['https://localhost:8021/rest/management/pwhconnection/config']
    }
  }
}
