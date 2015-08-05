class dynatrace::role::server_license (
  $role_name               = 'Dynatrace Server License',
  $installer_prefix_dir    = $dynatrace::params::server_installer_prefix_dir,
  $license_file_name       = $dynatrace::params::server_license_file_name,
  $license_file_url        = $dynatrace::params::server_license_file_url,
  $dynatrace_owner         = $dynatrace::params::dynatrace_owner,
  $dynatrace_group         = $dynatrace::params::dynatrace_group
) inherits dynatrace::params {
  
  validate_string($installer_prefix_dir, $license_file_name)


  class { 'dynatrace::role::dynatrace_user':
    dynatrace_owner => $dynatrace_owner,
    dynatrace_group => $dynatrace_group
  }

  dynatrace::resource::copy_or_download_file { "Copy or download the ${role_name} file":
    file_name => $license_file_name,
    file_url  => $license_file_url,
    path      => "${installer_prefix_dir}/dynatrace/server/conf/dtlicense.key"
  }
}