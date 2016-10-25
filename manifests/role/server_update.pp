class dynatrace::role::server_update (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server update',
  
  $update_file_url           = $dynatrace::update_file_url,
  $update_rest_url           = $dynatrace::update_rest_url,
  $update_rest_version_url   = $dynatrace::update_rest_version_url,
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

  $installation_ensure = $ensure ? {
    'present' => 'installed',
    'absent'  => 'uninstalled',
    default   => 'installed',
  }
  
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

  # introducing order (archive then update and stop then start service)  
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
  service { "Stop the ${role_name}'s service: '${service}'":    #hack to ensure restart service (stop service then start it)  
    ensure => stopped,
    name   => $service,
    enable => true
  } -> 
  exec {"Start the service ${service}":
    command => "service ${service} start",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
  }  
}
