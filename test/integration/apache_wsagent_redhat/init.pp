class { 'apache': }

class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-wsagent.tar',
  require            => Class['apache']
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path => '/etc/httpd/conf/httpd.conf',
  require                 => Class['dynatrace::role::wsagent_package']
}
