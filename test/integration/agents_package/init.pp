class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://172.18.129.150:8000/dynatrace-agent-unix.jar',
  require            => Class['java']
}
