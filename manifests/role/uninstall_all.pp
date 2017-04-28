#uninstall_all
class dynatrace::role::uninstall_all (
  $ensure                  = 'uninstalled',
  $role_name               = 'Dynatrace Server uninstall',
  $installer_bitsize       = $dynatrace::server_installer_bitsize,
  $installer_prefix_dir    = $dynatrace::server_installer_prefix_dir,
  $installer_file_name     = $dynatrace::server_installer_file_name,
  $installer_file_url      = $dynatrace::server_installer_file_url,
  $license_file_name       = $dynatrace::server_license_file_name,
  $license_file_url        = $dynatrace::server_license_file_url,
  $collector_port          = $dynatrace::server_collector_port,
  $pwh_connection_hostname = $dynatrace::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatrace::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatrace::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatrace::server_pwh_connection_database,
  $pwh_connection_username = $dynatrace::server_pwh_connection_username,
  $pwh_connection_password = $dynatrace::server_pwh_connection_password,
  $dynatrace_owner         = $dynatrace::dynatrace_owner,
  $dynatrace_group         = $dynatrace::dynatrace_group
) inherits dynatrace {

  case $::kernel {
    'Linux': {
      $services_to_manage_array = $dynatrace::services_to_manage_array
    }
    default: {}
  }

  $installation_ensure = $ensure ? {
    'absent'  => 'uninstalled',
    default   => 'installed',
  }

  $service_ensure = $ensure ? {
    'absent'  => 'stopped',
    default   => 'stopped',
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"
  $install_link = "${installer_prefix_dir}/dynatrace"
  $symlink      = "${installer_prefix_dir}/dynatrace"

  #stop all Dynatrace processes
  include dynatrace::role::stop_all_processes

  #removing folders and links
  exec {"remove directory using symlink=${symlink}":
    # remove directory using symlink (Puppet file resource does not work sometimes in this case)
    command => "rm -rf \"$(readlink ${symlink})\"; rm -rf ${symlink}",
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    onlyif  => ["test -L ${symlink}"],
  }

  -> file {"remove directory by symlink=${symlink}":
    path    => $symlink,
    recurse => true,
    purge   => true,
    force   => true,
  }

  -> tidy { 'clean /tmp folder from dynatrace files':
    path    => '/tmp',
    recurse => 1,
    matches => [ 'dt*', 'java_*', 'dynaTrace*.zip' ],
  }

  -> tidy { 'clean dynatrace temp folder':
    path    => '/tmp/hsperfdata_dynatrace',
    recurse => 1,
    matches => [ '[0-9]*' ],
  }

  -> tidy { 'clean temp folder':
    path    => '/tmp/hsperfdata_root',
    recurse => 1,
    matches => [ '[0-9]*' ],
  }

  file { $installer_cache_dir:
    ensure  => absent,
    path    => $installer_cache_dir,
    recurse => true,
    purge   => true,
    force   => true,
  }

  file {'remove tmp dynatrace directory':
    ensure  => absent,
    path    => '/tmp/hsperfdata_dynatrace',
    recurse => true,
    purge   => true,
    force   => true,
  }

  -> file {'remove tmp directory':
    ensure  => absent,
    path    => '/tmp/hsperfdata_root',
    recurse => true,
    purge   => true,
    force   => true,
  }

  $services_to_manage_array.each |$x| {
    file {"remove /etc/init.d/${x} link":
      ensure  => absent,
      path    => "/etc/init.d/${x}",
      recurse => true,
      purge   => true,
      force   => true,
    }
  }
}
