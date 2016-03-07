class { 'apache': }

class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/6.3/dynatrace-wsagent.tar'
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path => '/etc/apache2/apache2.conf',
  require                 => Class['dynatrace::role::wsagent_package']
}
