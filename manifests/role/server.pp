class dynatrace::role::server (
  $ensure                  = 'present',
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

#  notify{"server": message => "executing dynatrace::role::server  do_pwh_connection=${do_pwh_connection}"; }
    
  validate_bool($do_pwh_connection)
  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($installer_prefix_dir, $installer_file_name, $license_file_name)
  validate_string($collector_port)
  validate_string($pwh_connection_hostname, $pwh_connection_port, $pwh_connection_dbms, $pwh_connection_database, $pwh_connection_username, $pwh_connection_password)

    
  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-server.sh'
      $service = $dynatrace::dynaTraceServer
      $init_scripts = [$service, $dynatrace::dynaTraceFrontendServer, $dynatrace::dynaTraceBackendServer]
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

  $installer_cache_dir = "$dynatrace::installer_cache_dir/dynatrace"
  $installer_cache_dir_tree = dirtree($installer_cache_dir)


  include dynatrace::role::dynatrace_user

  ensure_resource(file, $installer_cache_dir_tree, {
    ensure  => $directory_ensure,
    require => Class['dynatrace::role::dynatrace_user']
  })

  $installation_info_step_1 = "copy_or_download_file=${installer_cache_dir}/${installer_file_name}"
  if $install_server__copy_or_download =='not there' {
    $executed_installation_step_1 = 'true'
    notify {"STEP 1 : dynatrace::resource::copy_or_download_file": }
    dynatrace::resource::copy_or_download_file { "Copy or download the ${role_name} installer":
      ensure    => $ensure,
      file_name => $installer_file_name,
      file_url  => $installer_file_url,
      path      => "${installer_cache_dir}/${installer_file_name}",
      require   => File[$installer_cache_dir_tree],
    }
  } else {
    $executed_installation_step_1 = ''
  }
  
  $installation_info_step_2 = "file_configure_and_copy_install_script=${installer_cache_dir}/${installer_script_name}"
  if $install_server__configure_and_copy_install_script =='not there' {
    $executed_installation_step_2 = 'true'
    notify {"STEP 2 : install script file": }
    file { "Configure and copy the ${role_name}'s install script":
      ensure  => $ensure,
      path    => "${installer_cache_dir}/${installer_script_name}",
      content => template("dynatrace/server/${installer_script_name}"),
      mode    => '0744',
#      before  => Dynatrace_installation["Install the ${role_name}"]
    }
  } else {
    $executed_installation_step_2 = ''
  }

  $installation_info_step_3 = "dynatrace_installation=${installer_prefix_dir}/dynatrace/server"
  if $install_server__dynatrace_installation =='not there' {
    $executed_installation_step_3 = 'true'
    notify {"STEP 3 : dynatrace_installation": }
#    $installation_info_step_3 = "dynatrace_installation=${installer_prefix_dir}/dynatrace/server"
    dynatrace_installation { "Install the ${role_name}":
      ensure                => $installation_ensure,
      installer_prefix_dir  => $installer_prefix_dir,
      installer_file_name   => $installer_file_name,
      installer_file_url    => $installer_file_url,
      installer_script_name => $installer_script_name,
      installer_path_part   => 'server',
      installer_path_detailed => '',
      installer_owner       => $dynatrace_owner,
      installer_group       => $dynatrace_group,
      installer_cache_dir   => $installer_cache_dir
    }
  } else {
    $executed_installation_step_3 = ''
  }

  if $executed_installation_step_1 != '' or $executed_installation_step_2 != '' or $executed_installation_step_3 != '' {
  
    file { "${dynatrace_server_installation_info_file}":
      ensure  => file,
      content => '#initialize installation history file',
    }
    
#    $installation_info_array.each |String $install_entry| {
#      $key_val_array = split($install_entry, '=')
#      $key = $key_val_array[0]
#      
#      file_line { "someline ${key_val_array}":
#        path  => $dynatrace_server_installation_info_file,
#        line  => $install_entry,
#        match => "^${key}.*",
#      }
#    }

    if $installation_info_step_1 != '' {
      $key_val_array_1 = split($installation_info_step_1, '=')
      $key_1 = $key_val_array_1[0]
      file_line { "someline ${installation_info_step_1}":
        ensure => present,
        path  => $dynatrace_server_installation_info_file,
        line  => $installation_info_step_1,
        match => "^${key_1}.*",
      }
    }
  
    if $installation_info_step_2 != '' {
      $key_val_array_2 = split($installation_info_step_2, '=')
      $key_2 = $key_val_array_2[0]
      file_line { "someline ${installation_info_step_2}":
        ensure => present,
        path  => $dynatrace_server_installation_info_file,
        line  => $installation_info_step_2,
        match => "^${key_2}.*",
      }
    }
  
    if $installation_info_step_3 != '' {
      $key_val_array_3 = split($installation_info_step_3, '=')
      $key_3 = $key_val_array_3[0]
      file_line { "someline ${installation_info_step_3}":
        ensure => present,
        path  => $dynatrace_server_installation_info_file,
        line  => $installation_info_step_3,
        match => "^${key_3}.*",
      }
    }
    
  }
  
  if $install_server__check_service =='not there' {
  
    service { "Start and enable the ${role_name}'s service: '${service}'":
      ensure => $service_ensure,
      name   => $service,
      enable => true
    }
    
    wait_until_port_is_open { $collector_port:
      ensure  => $ensure,
      require => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  
    wait_until_port_is_open { '2021':
      ensure  => $ensure,
      require => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  
    if $collector_port != '6699' {
      wait_until_port_is_open { '6699':
        ensure  => $ensure,
        require => Service["Start and enable the ${role_name}'s service: '${service}'"]
      }
    }
  
    wait_until_port_is_open { '8021':
      ensure  => $ensure,
      require => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  
    wait_until_port_is_open { '9911':
      ensure  => $ensure,
      require => Service["Start and enable the ${role_name}'s service: '${service}'"]
    }
  
    if $do_pwh_connection {     #TODO configure PHW connection will be run only when server will be started (it means that only when dynatrace server service is stopped)
      notify{"server 2": message => "executing dynatrace::role::server  do_pwh_connection"; }
    
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
}

