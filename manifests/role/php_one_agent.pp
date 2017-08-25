#php_one_agent
class dynatraceappmon::role::php_one_agent (

  $ensure               = 'present',
  $role_name            = 'Dynatrace PHP OneAgent',
  $ini_file_name        = $dynatraceappmon::php_one_agent_php_config_file_name,
  $ini_file_path        = $dynatraceappmon::php_one_agent_php_config_file_path,
  $installer_prefix_dir = $dynatraceappmon::php_one_agent_installer_prefix_dir,
  $agent_name           = $dynatraceappmon::php_one_agent_name,
  $agent_version        = $dynatraceappmon::php_one_agent_version,
  $server_hostname      = $dynatraceappmon::php_one_agent_server_hostname,
  $one_agent_port       = $dynatraceappmon::php_one_agent_port,
  $one_agent_name       = $dynatraceappmon::php_one_agent_name,
  $installer_file_name  = $dynatraceappmon::php_one_agent_installer_file_name,
  $installer_file_url   = $dynatraceappmon::php_one_agent_installer_file_url,
  $installer_bitsize    = $dynatraceappmon::php_one_agent_installer_bitsize,
  $service_name         = $dynatraceappmon::php_one_agent_apache_service_name,
) inherits dynatraceappmon {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_re($installer_bitsize, ['^32', '64'])
  validate_string($ini_file_name, $installer_file_name, $installer_file_url)
  validate_string($agent_name, $server_hostname, $one_agent_port)

  case $::kernel {
    'Linux': {
      $ini_file = "${ini_file_path}/${ini_file_name}"
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

  file { $ini_file :
    ensure => file,
  }

  $installer_cache_dir = $settings::vardir

  archive { "Copy and extracting ${role_name}":
    ensure       => $ensure,
    temp_dir     => $installer_cache_dir,
    path         => "${installer_cache_dir}/${installer_file_name}",
    filename     => $installer_file_name,
    source       => $installer_file_url,
    extract      => true,
    extract_path => $installer_prefix_dir,
    creates      => "${installer_prefix_dir}/dynatrace-oneagent-${agent_version}/agent/bin/linux-x86-${installer_bitsize}/liboneagentloader.so"
  }

  file_line { "Inject extension with '${installer_prefix_dir}/dynatrace-oneagent-${agent_version}/agent/bin/linux-x86-${installer_bitsize}/liboneagentloader.so' path into ${ini_file}":
    ensure => $ensure,
    path   => $ini_file,
    line   => "extension = ${installer_prefix_dir}/dynatrace-oneagent-${agent_version}/agent/bin/linux-x86-${installer_bitsize}/liboneagentloader.so",
    match  => '^extension\s?=\s?.*liboneagentloader.so$',
    before => Exec["Start the service: ${service_name}"]
  }

  file_line { "Inject phpagent.agentname '${one_agent_name}' into ${ini_file}":
    ensure => $ensure,
    path   => $ini_file,
    line   => "phpagent.agentname = ${one_agent_name}",
    match  => '^phpagent.agentname\s?=\s?.*$',
    before => Exec["Start the service: ${service_name}"]
  }

  file_line { "Inject phpagent.server address 'https://${server_hostname}:${one_agent_port}' into ${ini_file}":
    ensure => $ensure,
    path   => $ini_file,
    line   => "phpagent.server = https://${server_hostname}:${one_agent_port}",
    match  => '^phpagent.server\s?=\s?.*$',
    before => Exec["Start the service: ${service_name}"]
  }

  file_line { "Inject phpagent.tenant into ${ini_file}":
    ensure => $ensure,
    path   => $ini_file,
    line   => 'phpagent.tenant = 1',
    match  => '^phpagent.tenant\s?=\s?.*$',
    before => Exec["Start the service: ${service_name}"]
  }

  exec { "Start the service: ${service_name}":
    command => "service ${service_name} restart",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -x /usr/sbin/${service_name}"]
  }

}
