class { 'ruby':
  version            => '1.9.3',
  set_system_default => true
}

class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::server':
  installer_file_url => 'http://downloads.dynatracesaas.com/6.2/dynatrace-linux-x64.jar',
  do_pwh_connection  => true,
  require            => [ Class['ruby'], Class['java'] ]
}
