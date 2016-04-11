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

class { 'dynatrace::role::collector':
  installer_file_url => 'http://10.0.2.2/dynatrace/6.3/dynatrace-collector.jar',
  jvm_xms            => '256M',
  jvm_xmx            => '1024M',
  jvm_perm_size      => '256m',
  jvm_max_perm_size  => '384m',
  require            => [ Class['dynatrace::role::server'] ]
}

class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/6.3/dynatrace-agent.jar',
  require            => [ Class['dynatrace::role::collector'] ]
}
