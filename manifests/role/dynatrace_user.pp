class dynatrace::role::dynatrace_user(
  $dynatrace_owner = $dynatrace::params::dynatrace_owner,
  $dynatrace_group = $dynatrace::params::dynatrace_group
) inherits dynatrace::params {

  validate_string($dynatrace_owner, $dynatrace_group)

  user { "Create system user '${dynatrace_owner}'":
    ensure => present,
    name   => $dynatrace_owner,
    system => true
  }
  ->
  group { "Create group '${dynatrace_group}'":
    ensure  => present,
    name    => $dynatrace_group,
    members => [$dynatrace_owner]
  }
}
