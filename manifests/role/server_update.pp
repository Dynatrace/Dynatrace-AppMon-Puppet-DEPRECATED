class dynatrace::role::server_update (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server update',
  
  $update_file_url           = $dynatrace::update_file_url,
  $update_rest_url           = $dynatrace::update_rest_url,
  $update_user               = $dynatrace::update_user,
  $update_passwd             = $dynatrace::update_passwd,
  
  $dynatrace_owner           = $dynatrace::dynatrace_owner,
  $dynatrace_group           = $dynatrace::dynatrace_group
) inherits dynatrace {

  notify{"server": message => "executing dynatrace::role::server_update"; }
    
  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-server.sh'
      
      $service = 'dynaTraceServer'
      
      $collectorService = 'dynaTraceCollector'
      $dynaTraceAnalysis = 'dynaTraceAnalysis'
      $dynaTraceWebServerAgent = 'dynaTraceWebServerAgent'
      $dynaTraceHostagent = 'dynaTraceHostagent'
      
      $init_scripts = [$service, 'dynaTraceFrontendServer', 'dynaTraceBackendServer']
      
      $update_file_path = "${installer_cache_dir}/dynatrace/server_update/dynaTrace-6.5.1.1003.dtf"
    }
    default: {}
  }

  $directory_ensure = $ensure ? {
    'present' => 'directory',
    'absent'  => 'absent',
    default   => 'directory',
  }

#  $installation_ensure = $ensure ? {
#    'present' => 'installed',
#    'absent'  => 'uninstalled',
#    default   => 'installed',
#  }
  
  $installer_cache_dir = "$dynatrace::installer_cache_dir/dynatrace"
  $installer_cache_dir_tree = dirtree($installer_cache_dir)

  include dynatrace::role::dynatrace_user

  ensure_resource(file, $installer_cache_dir_tree, {
    ensure  => $directory_ensure,
    require => Class['dynatrace::role::dynatrace_user']
  })

  file { "${installer_cache_dir}/server_update":
    ensure => 'directory',
    mode   => '1777',
    owner  => $dynatrace_owner,
    group  => $dynatrace_group,
  }

  # introducing order (archive then update and stop then start services)  
  archive { 'dynaTrace-update':
     ensure => present,
     url => $update_file_url,
     target => "${installer_cache_dir}/server_update",
     follow_redirects => true,
     extension => 'zip',
     checksum => false,
     src_target => "/tmp",
  } ->
  make_server_update { "${update_file_path}":
    ensure => present,
    rest_update_url => $update_rest_url,
    rest_update_status_url => $update_rest_url,
    user => $update_user,
    passwd => $update_passwd
  } ->
    
  exec {"Stop the service ${service}":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${service} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${service}"],                  #stop service only if its service link exists
  } ->
  exec {"Start the service ${service}":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${service} start",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${service}"],                  #stop service only if its service link exists
  } ->
  
  exec {"Stop the ${role_name}'s service: '${collectorService}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${collectorService} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${collectorService}"],
  } ->
  exec {"Start the ${role_name}'s service: '${collectorService}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${collectorService} start",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${collectorService}"],
  } ->
  
  exec {"Stop the ${role_name}'s service: '${dynaTraceAnalysis}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceAnalysis} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceAnalysis}"],
  } ->
  exec {"Start the ${role_name}'s service: '${dynaTraceAnalysis}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceAnalysis} start",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceAnalysis}"],
  } ->
    
  exec {"Stop the ${role_name}'s service: '${dynaTraceWebServerAgent}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceWebServerAgent} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceWebServerAgent}"],
  } ->
  exec {"Start the ${role_name}'s service: '${dynaTraceWebServerAgent}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceWebServerAgent} start",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceWebServerAgent}"],
  } ->
  
  exec {"Stop the ${role_name}'s service: '${dynaTraceHostagent}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceHostagent} stop",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceHostagent}"],
  } ->
  exec {"Start the ${role_name}'s service: '${dynaTraceHostagent}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
    command => "service ${dynaTraceHostagent} start",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L /etc/init.d/${dynaTraceHostagent}"],
  } ->
  

# can be extended to  $collector_port but it looks like it isn't necessary
#  wait_until_port_is_open { $collector_port:
#    ensure  => $ensure,
#  }

  wait_until_port_is_open { '2021':
    ensure  => $ensure,
  } ->

#  if $collector_port != '6699' {
    wait_until_port_is_open { '6699':
      ensure  => $ensure,
    } ->
#  }

  wait_until_port_is_open { '8021':
    ensure  => $ensure,
  } ->

  wait_until_port_is_open { '9911':
    ensure  => $ensure,
  }
  
}
