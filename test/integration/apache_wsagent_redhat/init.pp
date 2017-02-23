class { 'apache': }

class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/6.5/6.5.0.1289/dynatrace-wsagent-6.5.0.1289-linux-x86-64.tar',
  require            => Class['apache']
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path => '/etc/httpd/conf/httpd.conf',
  require                 => Class['dynatrace::role::wsagent_package']
}
