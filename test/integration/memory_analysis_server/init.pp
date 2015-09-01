class { 'ruby':
  version  => '1.9.3'
}

class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::memory_analysis_server':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-analysisserver.jar',
  jvm_xms            => '256M',
  jvm_xmx            => '1024M',
  jvm_perm_size      => '256m',
  jvm_max_perm_size  => '384m',
  require            => [ Class['ruby'], Class['java'] ]
}
