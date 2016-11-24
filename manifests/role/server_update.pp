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
      
      $installer_cache_dir = "$dynatrace::installer_cache_dir/dynatrace"
      $installer_cache_dir_tree = dirtree($installer_cache_dir)
      $update_file_path = "${installer_cache_dir}/${dynatrace::update_file_path_dtf}"
      $services_to_stop_array = $dynatrace::services_to_manage_array
      
      $services_to_start_array = [
        $dynatrace::dynaTraceServer,
        $dynatrace::dynaTraceCollector,
        $dynatrace::dynaTraceAnalysis,  
        $dynatrace::dynaTraceWebServerAgent,
        $dynatrace::dynaTraceHostagent,
#        'dynaTraceBackendServer',
#        'dynaTraceFrontendServer' 
        ]

    }
    default: {}
  }

  $directory_ensure = $ensure ? {
    'present' => 'directory',
    'absent'  => 'absent',
    default   => 'directory',
  }

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
    
    notify => Wait_until_port_is_open[  $collector_port ]
  }

  wait_until_port_is_open { $collector_port:
    ensure  => $ensure,
  } -> 

  wait_until_port_is_open { '2021':
    ensure  => $ensure,
  } ->

  wait_until_port_is_open { '8021':
    ensure  => $ensure,
  } ->

  wait_until_port_is_open { '9911':
    ensure  => $ensure,
  }
    
  if $collector_port != '6699' {
    wait_until_port_is_open { '6699':
      ensure  => $ensure,
    }
  }
}
