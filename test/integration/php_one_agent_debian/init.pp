class { 'dynatrace::role::php_one_agent':
  service_name    => 'apache2',
  ini_file_path   => '/etc/php/7.0/apache2'
}