class dynatrace::role::uninstall_all (
  $ensure                  = 'uninstalled',
  $role_name               = 'Dynatrace Server',
  $installer_bitsize       = $dynatrace::server_installer_bitsize,
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
  $dynatrace_group         = $dynatrace::dynatrace_group
) inherits dynatrace {

  case $::kernel {
    'Linux': {
      $service = 'dynaTraceServer'
      $collectorService = 'dynaTraceCollector'
      $dynaTraceAnalysis = 'dynaTraceAnalysis'
      $dynaTraceWebServerAgent = 'dynaTraceWebServerAgent'
      $dynaTraceHostagent = 'dynaTraceHostagent'
    }
    default: {}
  }

  $installation_ensure = $ensure ? {
    'absent'  => 'uninstalled',
    default   => 'installed',
  }

  $service_ensure = $ensure ? {
    'absent'  => 'stopped',
    default   => 'stopped',
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"
  $installer_cache_dir_tree = dirtree($installer_cache_dir)
  
  $install_link = "${installer_prefix_dir}/dynatrace"
  $symlink      = "${installer_prefix_dir}/dynatrace"

  service { "Stop the ${role_name}'s service: '${service}'  installer_cache_dir='${installer_cache_dir}'  install_link='${install_link}'":
    ensure => 'stopped',
    name   => $service,
    enable => false
  } ->

  exec {"Stop the service ${service}":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${service} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${service}"],                  #stop service only if its service link exists
  } ->
  
  exec {"Stop the ${role_name}'s service: '${collectorService}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${collectorService} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${collectorService}"],
  } ->
  
  exec {"Stop the ${role_name}'s service: '${dynaTraceAnalysis}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceAnalysis} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceAnalysis}"],
  } ->
    
  exec {"Stop the ${role_name}'s service: '${dynaTraceWebServerAgent}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceWebServerAgent} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceWebServerAgent}"],
  } ->
  
  exec {"Stop the ${role_name}'s service: '${dynaTraceHostagent}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceHostagent} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceHostagent}"],
  } ->

  
  dynatrace_installation { "Uninstall the ${role_name}":
    installer_prefix_dir  => $installer_prefix_dir,
    installer_file_name   => $installer_file_name,
    installer_file_url    => $installer_file_url,
    installer_script_name => 'install-server.sh',
    installer_path_part   => 'server',
    installer_path_detailed => '',
    installer_owner       => $dynatrace_owner,
    installer_group       => $dynatrace_group,
    installer_cache_dir   => $installer_cache_dir,
  } ->

  exec {"remove directory using symlink=${symlink}":
    # remove directory using symlink (Chef directory resource does not work in this case)
    command => "rm -rf \"$(readlink ${symlink})\"; rm -rf ${symlink}",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L ${symlink}"],
  } ->
  
  file {"remove directory by symlink=${symlink}":
    path => $symlink,
    recurse => true,
    purge => true,
    force => true,
    notify               => tidy ['clean /tmp folder from dynatrace files']
  }
  
  tidy { 'clean /tmp folder from dynatrace files':
    path    => '/tmp',
    recurse => 1,
    matches => [ 'dt*', 'java_*', 'dynaTrace*.zip' ],
  } ->

  tidy { 'clean dynatrace temp folder':
    path    => '/tmp/hsperfdata_dynatrace',
    recurse => 1,
    matches => [ '[0-9]*' ],
  } ->

  tidy { 'clean temp folder':
    path    => '/tmp/hsperfdata_root',
    recurse => 1,
    matches => [ '[0-9]*' ],
  } ->
  
  file {'remove tmp dynatrace directory':
    ensure => absent,
    path => '/tmp/hsperfdata_dynatrace',
    recurse => true,
    purge => true,
    force => true,
  } ->

  file {'remove tmp directory':
    ensure => absent,
    path => '/tmp/hsperfdata_root',
    recurse => true,
    purge => true,
    force => true,
   }
}

