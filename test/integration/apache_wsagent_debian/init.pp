class { 'apache': }

class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'http://172.18.129.150:8000/dynatrace-wsagent-linux-x86-64.tar'
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path => '/etc/apache2/apache2.conf',
  require                 => Class['dynatrace::role::wsagent_package']
}
