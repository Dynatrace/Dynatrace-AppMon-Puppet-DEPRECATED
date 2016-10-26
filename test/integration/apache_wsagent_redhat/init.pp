class { 'apache': }

class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'http://172.18.129.150:8000/dynatrace-wsagent-linux-x86-64.tar',
  require            => Class['apache']
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path => '/etc/httpd/conf/httpd.conf',
  require                 => Class['dynatrace::role::wsagent_package']
}
