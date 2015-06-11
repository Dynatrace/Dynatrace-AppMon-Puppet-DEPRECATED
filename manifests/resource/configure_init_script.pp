define dynatrace::resource::configure_init_script($installer_prefix_dir = nil, $role_name = nil) {
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

  file { "Configure and copy the ${role_name}'s '${name}' init script":
    path    => "${installer_prefix_dir}/dynatrace/init.d/${name}",
    owner   => 'dynatrace',
    group   => 'dynatrace',
    mode    => '0744',
    content => template("dynatrace/init.d/${name}.erb"),
    require => Dynatrace_installation["Install the ${role_name}"]
  }

  file { "Make the '${name}' init script available in /etc/init.d":
    path    => "/etc/init.d/${name}",
    target  => "${installer_prefix_dir}/dynatrace/init.d/${name}",
    ensure  => link,
    require => File["Configure and copy the ${role_name}'s '${name}' init script"]
  }
}
