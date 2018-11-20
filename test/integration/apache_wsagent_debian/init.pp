class { 'apache': }

class { 'dynatraceappmon::role::wsagent_package':
  # installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.2/7.2.0.1697/dynatrace-wsagent-7.2.0.1697-linux-x86-64.tar'
}

class { 'dynatraceappmon::role::apache_wsagent':
  apache_config_file_path => '/etc/apache2/apache2.conf',
  require                 => Class['dynatraceappmon::role::wsagent_package']
}
