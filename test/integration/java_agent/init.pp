class { 'java':
  distribution => 'jdk'
}

class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://downloads.dynatracesaas.com/6.2/dynatrace-agent-unix.jar',
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
