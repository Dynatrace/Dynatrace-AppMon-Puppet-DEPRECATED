class dynatrace::role::dynatrace_user {
  
  require dynatrace

  user { "Create system user 'dynatrace'":
    name    => 'dynatrace',
    comment => 'Dynatrace user',
    system  => true,
    ensure  => present
  }
  ->
  group { "Create group 'dynatrace'":
    name    => 'dynatrace',
    ensure  => present,
    members => ['dynatrace']
  }

}
