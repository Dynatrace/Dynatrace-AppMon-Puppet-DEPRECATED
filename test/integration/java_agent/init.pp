class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://172.18.129.150:8000/dynatrace-agent-unix.jar',
  require            => Class['java']
}

class { 'dynatrace::role::java_agent':
  env_var_file_name => '/tmp/environment',
  require           => Class['dynatrace::role::agents_package']
}
