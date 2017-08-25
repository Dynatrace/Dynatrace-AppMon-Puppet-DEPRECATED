#server_license
class dynatraceappmon::role::server_license (
  $ensure               = 'present',
  $role_name            = 'Dynatrace Server License',
  $installer_prefix_dir = $dynatraceappmon::server_installer_prefix_dir,
  $license_file_name    = $dynatraceappmon::server_license_file_name,
  $license_file_url     = $dynatraceappmon::server_license_file_url,
  $dynatrace_owner      = $dynatraceappmon::dynatrace_owner,
  $dynatrace_group      = $dynatraceappmon::dynatrace_group
) inherits dynatraceappmon {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($installer_prefix_dir, $license_file_name)

  include dynatraceappmon::role::dynatrace_user

  dynatraceappmon::resource::copy_or_download_file { "Copy or download the ${role_name} file":
    ensure    => $ensure,
    file_name => $license_file_name,
    file_url  => $license_file_url,
    path      => "${installer_prefix_dir}/dynatrace/server/conf/dtlicense.lic"
  }
}
