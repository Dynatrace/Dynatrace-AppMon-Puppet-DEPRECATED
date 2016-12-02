define dynatrace::resource::stop_all_services(
  $ensure    = 'stopped'
) {
  validate_re($ensure, ['^running$', '^stopped$'])

  if $ensure == stopped {
    include dynatrace::role::stop_all_processes
  }
}
