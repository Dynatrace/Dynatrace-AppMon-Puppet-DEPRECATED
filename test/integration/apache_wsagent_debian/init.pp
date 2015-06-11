class { 'apache': }

class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-wsagent.tar',
  require            => Class['apache']
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path     => '/etc/apache2/apache2.conf',
  apache_init_script_path     => '/etc/init.d/apache2',
  apache_do_patch_init_script => true,
  require                     => Class['dynatrace::role::wsagent_package']
}
