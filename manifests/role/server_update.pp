#server_update
class dynatraceappmon::role::server_update (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server update',

  $collector_port          = $dynatraceappmon::server_collector_port,

  $update_file_url         = $dynatraceappmon::update_file_url,
  $update_rest_url         = $dynatraceappmon::update_rest_url,
  $update_user             = $dynatraceappmon::update_user,
  $update_passwd           = $dynatraceappmon::update_passwd,

  $dynatrace_owner         = $dynatraceappmon::dynatrace_owner,
  $dynatrace_group         = $dynatraceappmon::dynatrace_group

) inherits dynatraceappmon {

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-server.sh'

      $service                 = $dynatraceappmon::dynaTraceServer
      $collectorService        = $dynatraceappmon::dynaTraceCollector
      $dynaTraceAnalysis       = $dynatraceappmon::dynaTraceAnalysis
      $dynaTraceWebServerAgent = $dynatraceappmon::dynaTraceWebServerAgent
      $dynaTraceHostagent      = $dynatraceappmon::dynaTraceHostagent

      $installer_cache_dir = "${dynatraceappmon::installer_cache_dir}/dynatrace"
      $installer_cache_dir_tree = dirtree($installer_cache_dir)
      $update_file_path = $installer_cache_dir
      $services_to_stop_array = $dynatraceappmon::services_to_manage_array

      $services_to_start_array = [
        $dynatraceappmon::dynaTraceServer,
        $dynatraceappmon::dynaTraceCollector,
        $dynatraceappmon::dynaTraceAnalysis,
        $dynatraceappmon::dynaTraceWebServerAgent,
        $dynatraceappmon::dynaTraceHostagent,
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

  include dynatraceappmon::role::dynatrace_user

  ensure_resource(file, $installer_cache_dir_tree, {
    ensure  => $directory_ensure,
    require => Class['dynatraceappmon::role::dynatrace_user']
  })

  file { "${installer_cache_dir}/server_update":
    ensure => 'directory',
    mode   => '1777',
    owner  => $dynatrace_owner,
    group  => $dynatrace_group,
  }

  # introducing order (archive then update and stop then start services)
  archive { 'dynaTrace-update':
    ensure           => present,
    url              => $update_file_url,
    target           => "${installer_cache_dir}/server_update",
    follow_redirects => true,
    extension        => 'zip',
    checksum         => false,
    src_target       => '/tmp',
  }
  -> make_server_update { $update_file_path:
    ensure           => present,
    update_file_path => $update_file_path,
    rest_update_url  => $update_rest_url,
    user             => $update_user,
    passwd           => $update_passwd,
    notify           => Wait_until_port_is_open[  $collector_port ]
  }

  wait_until_port_is_open { $collector_port:
    ensure  => $ensure,
  }

  -> wait_until_port_is_open { '2021':
    ensure  => $ensure,
  }

  -> wait_until_port_is_open { '8021':
    ensure  => $ensure,
  }

  -> wait_until_port_is_open { '9911':
    ensure  => $ensure,
  }

  if $collector_port != '6699' {
    wait_until_port_is_open { '6699':
      ensure  => $ensure,
    }
  }
}
