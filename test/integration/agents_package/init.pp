class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://downloads.dynatracesaas.com/6.2/dynatrace-agent-unix.jar',
  require            => Class['java']
}
