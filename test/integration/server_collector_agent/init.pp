class { 'ruby':
  version            => '1.9.3',
  set_system_default => true
}

class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::server':
  # installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/6.5/6.5.0.1289/dynatrace-server-6.5.0.1289-linux-x86.jar',
  require            => [ Class['ruby'], Class['java'] ]
}

class { 'dynatrace::role::pwh_connection':
  require            => [ Class['dynatrace::role::server'] ]
}

class { 'dynatrace::role::collector':
  # installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/6.5/6.5.0.1289/dynatrace-collector-6.5.0.1289-linux-x86.jar',
  jvm_xms            => '256M',
  jvm_xmx            => '1024M',
  jvm_perm_size      => '256m',
  jvm_max_perm_size  => '384m',
  require            => [ Class['dynatrace::role::pwh_connection'] ]
}

class { 'dynatrace::role::agents_package':
  # installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/6.5/6.5.0.1289/dynatrace-agent-6.5.0.1289-unix.jar',
  require            => [ Class['dynatrace::role::collector'] ]
}
