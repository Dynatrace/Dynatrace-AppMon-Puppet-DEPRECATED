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
