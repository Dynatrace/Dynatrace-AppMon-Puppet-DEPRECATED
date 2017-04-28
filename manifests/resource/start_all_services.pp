#start_all_services
define dynatrace::resource::start_all_services(
  $ensure         = 'running',
  $collector_port = $dynatrace::server_collector_port
) {
  validate_re($ensure, ['^running$', '^stopped$'])

  if $ensure == running {
    include dynatrace::role::start_all_processes
  }
}
