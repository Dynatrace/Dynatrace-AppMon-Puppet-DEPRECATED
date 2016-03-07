class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/6.3/dynatrace-agent.jar',
  require            => Class['java']
}

file { 'dummy file':
  ensure  => 'present',
  path    => '/tmp/environment',
  replace => 'no',
  require => Class['dynatrace::role::agents_package']
}

class { 'dynatrace::role::java_agent':
  env_var_file_name => '/tmp/environment',
  require           => File['dummy file']
}
