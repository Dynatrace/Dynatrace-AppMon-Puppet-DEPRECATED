class { 'apache': }

class { 'dynatraceappmon::role::wsagent_package':
  # installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.2/7.2.0.1697/dynatrace-wsagent-7.2.0.1697-linux-x86-64.tar',
  require            => Class['apache']
}

class { 'dynatraceappmon::role::apache_wsagent':
  apache_config_file_path => '/etc/httpd/conf/httpd.conf',
  require                 => Class['dynatraceappmon::role::wsagent_package']
}
