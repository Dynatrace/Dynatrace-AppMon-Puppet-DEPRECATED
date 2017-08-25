#dynatrace_user
class dynatraceappmon::role::dynatrace_user(
  $dynatrace_owner = $dynatraceappmon::dynatrace_owner,
  $dynatrace_group = $dynatraceappmon::dynatrace_group
) inherits dynatraceappmon {

  validate_string($dynatrace_owner, $dynatrace_group)

  ensure_resource(user, "Create system user '${dynatrace_owner}'", {
    ensure => present,
    name   => $dynatrace_owner,
    system => true
  })

  ensure_resource(group, "Create group '${dynatrace_group}'", {
    ensure  => present,
    name    => $dynatrace_group,
    members => [$dynatrace_owner],
    require => User["Create system user '${dynatrace_owner}'"]
  })
}
