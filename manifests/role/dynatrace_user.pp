class dynatrace::role::dynatrace_user(
  $dynatrace_owner = $dynatrace::params::dynatrace_owner,
  $dynatrace_group = $dynatrace::params::dynatrace_group
) inherits dynatrace::params {

  validate_string($dynatrace_owner, $dynatrace_group)

  user { "Create system user '${dynatrace_owner}'":
    name    => $dynatrace_owner,
    system  => true,
    ensure  => present
  }
  ->
  group { "Create group '${dynatrace_group}'":
    name    => $dynatrace_group,
    ensure  => present,
    members => [$dynatrace_owner]
  }

}
