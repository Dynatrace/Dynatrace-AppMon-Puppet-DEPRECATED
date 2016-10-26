class { 'ruby':
  version            => '1.9.3',
  set_system_default => true
}

class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::server':
  installer_file_url => 'http://172.18.129.150:8000/dynatrace-server-linux-x86.jar',
  do_pwh_connection  => true,
  require            => [ Class['ruby'], Class['java'] ]
}

class { 'dynatrace::role::collector':
  installer_file_url => 'http://172.18.129.150:8000/dynatrace-collector-linux-x86.jar',
  jvm_xms            => '256M',
  jvm_xmx            => '1024M',
  jvm_perm_size      => '256m',
  jvm_max_perm_size  => '384m',
  require            => [ Class['dynatrace::role::server'] ]
}

class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://172.18.129.150:8000/dynatrace-agent-unix.jar',
  require            => [ Class['dynatrace::role::collector'] ]
}
