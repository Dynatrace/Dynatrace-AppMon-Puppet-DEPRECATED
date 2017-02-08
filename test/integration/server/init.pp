class { 'ruby':
  version            => '1.9.3',
  set_system_default => true
}

class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::server':
  installer_file_url => 'http://172.18.129.150:8000/dynatrace-server-linux-x86.jar',
  require            => [ Class['ruby'], Class['java'] ]
}
