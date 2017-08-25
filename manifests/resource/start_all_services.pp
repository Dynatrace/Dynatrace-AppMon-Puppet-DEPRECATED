#start_all_services
define dynatraceappmon::resource::start_all_services(
  $ensure         = 'running',
  $collector_port = $dynatraceappmon::server_collector_port
) {
  validate_re($ensure, ['^running$', '^stopped$'])

  if $ensure == running {
    include dynatraceappmon::role::start_all_processes
  }
}
