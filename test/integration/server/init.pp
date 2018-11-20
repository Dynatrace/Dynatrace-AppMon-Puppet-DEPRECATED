class { 'dynatraceappmon::role::server':
  # installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.2/7.2.0.1697/dynatrace-server-7.2.0.1697-linux-x86.jar',
}

class { 'dynatraceappmon::role::pwh_connection':
  require            => [ Class['dynatraceappmon::role::server'] ]
}
