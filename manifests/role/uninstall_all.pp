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
      $dynaTraceBackendServer = 'dynaTraceBackendServer'
      $dynaTraceFrontendServer = 'dynaTraceFrontendServer'
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

  if ("test -L /etc/init.d/${service}") {
    notify {"Service ${service} exists ": }
  }  
  
  service { "Service ${service} exists ":
    ensure => 'stopped',
    name   => $service,
    enable => false
  }

  
  if ("test -L /etc/init.d/${collectorService}") {
    notify {"Service ${collectorService} exists ": }
  }  
  service { "Service ${collectorService} exists ":
    ensure => 'stopped',
    name   => $collectorService,
    enable => false
  }
  
    
  if ("test -L /etc/init.d/${dynaTraceAnalysis}") {
    notify {"Service ${dynaTraceAnalysis} exists ": }
  }  
  service { "Service ${dynaTraceAnalysis} exists ":
    ensure => 'stopped',
    name   => $dynaTraceAnalysis,
    enable => false
  }

      
  if ("test -L /etc/init.d/${dynaTraceWebServerAgent}") {
    notify {"Service ${dynaTraceWebServerAgent} exists ": }
  }  
  service { "Service ${dynaTraceWebServerAgent} exists ":
    ensure => 'stopped',
    name   => $dynaTraceWebServerAgent,
    enable => false
  }
  
        
  if ("test -L /etc/init.d/${dynaTraceHostagent}") {
    notify {"Service ${dynaTraceHostagent} exists ": }
  }  
  service { "Service ${dynaTraceHostagent} exists ":
    ensure => 'stopped',
    name   => $dynaTraceHostagent,
    enable => false
  }
      
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
    # remove directory using symlink (Puppet file resource does not work sometimes in this case)
    command => "rm -rf \"$(readlink ${symlink})\"; rm -rf ${symlink}",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L ${symlink}"],
  } ->
  
  file {"remove directory by symlink=${symlink}":
    path => $symlink,
    recurse => true,
    purge => true,
    force => true,
#    notify               => tidy ['clean /tmp folder from dynatrace files']
#  }
  } ->
  
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
  }
  
  file {"remove tmp dynatrace directory":
    ensure => absent,
    path => '/tmp/hsperfdata_dynatrace',
    recurse => true,
    purge => true,
    force => true,
  } ->

  file {"remove tmp directory":
    ensure => absent,
    path => '/tmp/hsperfdata_root',
    recurse => true,
    purge => true,
    force => true,
  } ->
  
  file {"remove /etc/init.d/${service} link":
    ensure => absent,
    path => "/etc/init.d/${service}",
    recurse => true,
    purge => true,
    force => true,
  } ->

  file {"remove /etc/init.d/${collectorService} link":
    ensure => absent,
    path => "/etc/init.d/${collectorService}",
    recurse => true,
    purge => true,
    force => true,
  } ->
  
  file {"remove /etc/init.d/${dynaTraceAnalysis} link":
    ensure => absent,
    path => "/etc/init.d/${dynaTraceAnalysis}",
    recurse => true,
    purge => true,
    force => true,
  } ->
    
  file {"remove /etc/init.d/${dynaTraceWebServerAgent} link":
    ensure => absent,
    path => "/etc/init.d/${dynaTraceWebServerAgent}",
    recurse => true,
    purge => true,
    force => true,
  } ->
      
  file {"remove /etc/init.d/${dynaTraceHostagent} link":
    ensure => absent,
    path => "/etc/init.d/${dynaTraceHostagent}",
    recurse => true,
    purge => true,
    force => true,
  } ->
        
  file {"remove /etc/init.d/${dynaTraceBackendServer} link":
    ensure => absent,
    path => "/etc/init.d/${dynaTraceBackendServer}",
    recurse => true,
    purge => true,
    force => true,
  } ->
      
  file {"remove /etc/init.d/${dynaTraceFrontendServer} link":
    ensure => absent,
    path => "/etc/init.d/${dynaTraceFrontendServer}",
    recurse => true,
    purge => true,
    force => true,
  }
}
