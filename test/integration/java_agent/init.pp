class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-agent.jar',
  require            => Class['java']
}

file { 'dummy file':
  path    => '/tmp/environment',
  replace => 'no',
  ensure  => 'present',
  require => Class['dynatrace::role::agents_package']
}

class { 'dynatrace::role::java_agent':
  env_var_file_name => '/tmp/environment',
  require           => File['dummy file']
}
