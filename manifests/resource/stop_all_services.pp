#stop_all_services
define dynatraceappmon::resource::stop_all_services(
  $ensure    = 'stopped'
) {
  validate_re($ensure, ['^running$', '^stopped$'])

  if $ensure == stopped {
    include dynatraceappmon::role::stop_all_processes
  }
}
