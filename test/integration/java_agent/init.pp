class { 'dynatraceappmon::role::agents_package':
  # installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/6.5/6.5.0.1289/dynatrace-agent-6.5.0.1289-unix.jar',
}

class { 'dynatraceappmon::role::java_agent':
  env_var_file_name => '/tmp/environment',
  require           => Class['dynatraceappmon::role::agents_package']
}
