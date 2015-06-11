class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::server':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace.jar',
  license_file_url   => 'http://10.0.2.2/dynatrace/dynatrace-license.key',
  require            => Class['java']
}
