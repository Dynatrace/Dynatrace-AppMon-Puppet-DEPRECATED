#agents_package
class dynatraceappmon::role::agents_package (
  $ensure               = 'present',
  $role_name            = 'Dynatrace Agents',
  $installer_bitsize    = $dynatraceappmon::agents_package_installer_bitsize,
  $installer_prefix_dir = $dynatraceappmon::agents_package_installer_prefix_dir,
  $installer_file_name  = $dynatraceappmon::agents_package_installer_file_name,
  $installer_file_url   = $dynatraceappmon::agents_package_installer_file_url,
  $dynatrace_owner      = $dynatraceappmon::dynatrace_owner,
  $dynatrace_group      = $dynatraceappmon::dynatrace_group
) inherits dynatraceappmon {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_re($installer_bitsize, ['^32', '64'])
  validate_string($installer_prefix_dir, $installer_file_name)

  case $::kernel {
    'Linux': {
      $installer_script_name = 'install-agents-package.sh'
    }
    default: {}
  }

  $directory_ensure = $ensure ? {
    'present' => 'directory',
    'absent'  => 'absent',
    default   => 'directory',
  }

  $installation_ensure = $ensure ? {
    'present' => 'installed',
    'absent'  => 'uninstalled',
    default   => 'installed',
  }

  $installer_cache_dir = "${settings::vardir}/dynatrace"
  $installer_cache_dir_tree = dirtree($installer_cache_dir)


  include dynatraceappmon::role::dynatrace_user

  ensure_resource(file, $installer_cache_dir_tree, {
    ensure  => $directory_ensure,
    require => Class['dynatraceappmon::role::dynatrace_user']
  })

  dynatraceappmon::resource::copy_or_download_file { "Copy or download the ${role_name} installer":
    ensure    => $ensure,

    file_name => $installer_file_name,
    file_url  => $installer_file_url,
    path      => "${installer_cache_dir}/${installer_file_name}",
    require   => File[$installer_cache_dir_tree],
    notify    => [
      File["Configure and copy the ${role_name}'s install script"],
      Dynatrace_installation["Install the ${role_name}"]
    ]
  }

  file { "Configure and copy the ${role_name}'s install script":
    ensure  => $ensure,
    path    => "${installer_cache_dir}/${installer_script_name}",
    content => template("dynatraceappmon/agents_package/${installer_script_name}"),
    mode    => '0744',
    before  => Dynatrace_installation["Install the ${role_name}"]
  }

  dynatrace_installation { "Install the ${role_name}":
    ensure                  => $installation_ensure,
    installer_prefix_dir    => $installer_prefix_dir,
    installer_file_name     => $installer_file_name,
    installer_file_url      => $installer_file_url,
    installer_script_name   => $installer_script_name,
    installer_path_part     => 'agent',
    installer_path_detailed => '',
    installer_owner         => $dynatrace_owner,
    installer_group         => $dynatrace_group,
    installer_cache_dir     => $installer_cache_dir
  }
}
