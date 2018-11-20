class { 'dynatraceappmon::role::agents_package':
  # installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.2/7.2.0.1697/dynatrace-agent-7.2.0.1697-unix.jar',
}

class { 'dynatraceappmon::role::java_agent':
  env_var_file_name => '/tmp/environment',
  require           => Class['dynatraceappmon::role::agents_package']
}
