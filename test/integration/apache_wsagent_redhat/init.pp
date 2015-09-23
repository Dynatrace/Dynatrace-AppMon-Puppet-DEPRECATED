class { 'apache': }

class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'http://downloads.dynatracesaas.com/6.2/dynatrace-wsagent-linux-x64.tar',
  require            => Class['apache']
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path     => '/etc/httpd/conf/httpd.conf',
  require                     => Class['dynatrace::role::wsagent_package']
}
