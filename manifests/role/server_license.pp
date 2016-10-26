class dynatrace::role::server_license (
  $ensure               = 'present',
  $role_name            = 'Dynatrace Server License',
  $installer_prefix_dir = $dynatrace::server_installer_prefix_dir,
  $license_file_name    = $dynatrace::server_license_file_name,
  $license_file_url     = $dynatrace::server_license_file_url,
  $dynatrace_owner      = $dynatrace::dynatrace_owner,
  $dynatrace_group      = $dynatrace::dynatrace_group
) inherits dynatrace {
  
  notify{"server_license": message => "executing dynatrace::role::server_license"; }
    
  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($installer_prefix_dir, $license_file_name)

  include dynatrace::role::dynatrace_user

  dynatrace::resource::copy_or_download_file { "Copy or download the ${role_name} file":
    ensure    => $ensure,
    file_name => $license_file_name,
    file_url  => $license_file_url,
    path      => "${installer_prefix_dir}/dynatrace/server/conf/dtlicense.key"
  }
}
