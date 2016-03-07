class { 'ruby':
  version            => '1.9.3',
  set_system_default => true
}

class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::server':
  installer_file_url => 'http://10.0.2.2/dynatrace/6.3/dynatrace-server.jar',
  do_pwh_connection  => true,
  require            => [ Class['ruby'], Class['java'] ]
}
