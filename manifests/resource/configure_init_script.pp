define dynatrace::resource::configure_init_script(
  $ensure               = 'present',
  $role_name            = undef,
  $installer_prefix_dir = undef,
  $owner                = undef,
  $group                = undef,
  $init_scripts_params  = {}
) {
  case $::kernel {
    'Linux': {
      case $::osfamily {
        'Debian': {
          $linux_service_start_runlevels = '2 3 4 5'
          $linux_service_stop_runlevels = '0 1 6'
        }
        default: {
          $linux_service_start_runlevels = '3 5'
          $linux_service_stop_runlevels = '0 1 2 6'
        }
      }
    }
  }

  $params = delete_undef_values(merge($init_scripts_params, {
    'linux_service_start_runlevels' => $linux_service_start_runlevels,
    'linux_service_stop_runlevels'  => $linux_service_stop_runlevels
  }))

  $link_ensure = $ensure ? {
    'present' => 'link',
    'absent'  => 'absent',
    default   => 'link'
  }

  file { "Configure and copy the ${role_name}'s '${name}' init script":
    ensure  => $ensure,
    selinux_ignore_defaults => true,
    path    => "${installer_prefix_dir}/dynatrace/init.d/${name}",
    owner   => $owner,
    group   => $group,
    mode    => '0755',
    content => template("dynatrace/init.d/${name}.erb"),
    require => Dynatrace_installation["Install the ${role_name}"]
  }
  file { "Make the '${name}' init script available in /etc/init.d":
    ensure  => $link_ensure,
    selinux_ignore_defaults => true,
    path    => "/etc/init.d/${name}",
    target  => "${installer_prefix_dir}/dynatrace/init.d/${name}",
    require => File["Configure and copy the ${role_name}'s '${name}' init script"]
  }
}
