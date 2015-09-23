class dynatrace::role::agents_package (
  $role_name            = 'Dynatrace Agents',
  $installer_prefix_dir = $dynatrace::params::agents_package_installer_prefix_dir,
  $installer_file_name  = $dynatrace::params::agents_package_installer_file_name,
  $installer_file_url   = $dynatrace::params::agents_package_installer_file_url,
  $dynatrace_owner      = $dynatrace::params::dynatrace_owner,
  $dynatrace_group      = $dynatrace::params::dynatrace_group
) inherits dynatrace::params {

  validate_string($installer_prefix_dir, $installer_file_name)

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-agents-package.sh'
    }
    default:
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"


  class { 'dynatrace::role::dynatrace_user':
    dynatrace_owner => $dynatrace_owner,
    dynatrace_group => $dynatrace_group
  }

  file { 'Create the installer cache directory':
    ensure  => directory,
    path    => $installer_cache_dir,
    require => Class['dynatrace::role::dynatrace_user']
  }

  dynatrace::resource::copy_or_download_file { "Copy or download the ${role_name} installer":
    file_name => $installer_file_name,
    file_url  => $installer_file_url,
    path      => "${installer_cache_dir}/${installer_file_name}",
    require   => File['Create the installer cache directory'],
    notify    => [
      File["Configure and copy the ${role_name}'s install script"],
      Dynatrace_installation["Install the ${role_name}"]
    ]
  }

  file { "Configure and copy the ${role_name}'s install script":
    path    => "${installer_cache_dir}/${installer_script_name}",
    content => template("dynatrace/agents_package/${installer_script_name}"),
    mode    => '0744',
    before  => Dynatrace_installation["Install the ${role_name}"]
  }

  dynatrace_installation { "Install the ${role_name}":
    ensure                => installed,
    installer_prefix_dir  => $installer_prefix_dir,
    installer_file_name   => $installer_file_name,
    installer_file_url    => $installer_file_url,
    installer_script_name => $installer_script_name,
    installer_path_part   => 'agent',
    installer_owner       => $dynatrace_owner,
    installer_group       => $dynatrace_group,
    installer_cache_dir   => $installer_cache_dir
  }
}
