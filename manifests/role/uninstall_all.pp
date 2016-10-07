class dynatrace::role::uninstall_all (
  $ensure                  = 'absent',
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
  
  validate_re($ensure, ['^absent$'])

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-server.sh'
      $service = 'dynaTraceServer'
      $init_scripts = [$service, 'dynaTraceFrontendServer', 'dynaTraceBackendServer']
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

  service { "Stop the ${role_name}'s service: '${service}'  installer_cache_dir='${installer_cache_dir}'  install_link='${install_link}'":
    ensure => 'stopped',
    name   => $service,
    enable => false
  }


  $symlink = "${installer_prefix_dir}/dynatrace"
  if defined(File[$symlink]) {
    notice("${symlink} is defined.")

    dynatrace_installation { "Uninstall the ${role_name}":
      ensure                => uninstalled,
      installer_prefix_dir  => $installer_prefix_dir,
      installer_file_name   => $installer_file_name,
      installer_file_url    => $installer_file_url,
      installer_script_name => $installer_script_name,
      installer_path_part   => 'server',
      installer_path_detailed => '',
      installer_owner       => $dynatrace_owner,
      installer_group       => $dynatrace_group,
      installer_cache_dir   => $installer_cache_dir,
    }
  } else {
    notice("${symlink} is defined - nothing to do.")
  }
    
  file {'remove_directory':
    ensure => absent,
    path => $symlink,
    recurse => true,
    purge => true,
    force => true,
  }
  

#    #execute fact on agent - will kill all orphaned dynatrace server processes
  if $dynatrace_clean_agent == 1 {          #TODO how to pass $::osfamily as an argumet to dynatrace_clean_agent fact
  }  
}

