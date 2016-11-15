class dynatrace::role::server_update (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server update',

  $collector_port          = $dynatrace::server_collector_port,
    
  $update_file_url         = $dynatrace::update_file_url,
  $update_rest_url         = $dynatrace::update_rest_url,
  $update_user             = $dynatrace::update_user,
  $update_passwd           = $dynatrace::update_passwd,
  
  $dynatrace_owner         = $dynatrace::dynatrace_owner,
  $dynatrace_group         = $dynatrace::dynatrace_group
  
) inherits dynatrace {

  notify{"server update": message => "executing dynatrace::role::server_update"; }
    
  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-server.sh'
      
      $service                 = $dynatrace::dynaTraceServer
      $collectorService        = $dynatrace::dynaTraceCollector
      $dynaTraceAnalysis       = $dynatrace::dynaTraceAnalysis
      $dynaTraceWebServerAgent = $dynatrace::dynaTraceWebServerAgent
      $dynaTraceHostagent      = $dynatrace::dynaTraceHostagent
      
      $update_file_path = "${installer_cache_dir}/${dynatrace::update_file_path_dtf}"
    }
    default: {}
  }

  $directory_ensure = $ensure ? {
    'present' => 'directory',
    'absent'  => 'absent',
    default   => 'directory',
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
    update_file_path => $update_file_path,
    rest_update_url => $update_rest_url,
    rest_update_status_url => $update_rest_url,
    user => $update_user,
    passwd => $update_passwd,
  } ->

  dynatrace::resource::stop_all_services { "stop_all_services 1":
    ensure  => 'stopped',
    require => Class['dynatrace::role::dynatrace_user']
  } ~>

  dynatrace::resource::start_all_services { "start_all_services 1":
    ensure                  => 'running',
    collector_port          => $collector_port,
  }
}
