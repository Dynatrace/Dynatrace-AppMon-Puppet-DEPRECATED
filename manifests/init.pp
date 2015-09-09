class dynatrace (
  $agents_package_installer_prefix_dir = $dynatrace::params::agents_package_installer_prefix_dir,
  $agents_package_installer_file_name  = $dynatrace::params::agents_package_installer_file_name,
  $agents_package_installer_file_url   = $dynatrace::params::agents_package_installer_file_url,

  $apache_wsagent_apache_config_file_path     = $dynatrace::params::apache_wsagent_apache_config_file_path,
  $apache_wsagent_apache_init_script_path     = $dynatrace::params::apache_wsagent_apache_init_script_path,
  $apache_wsagent_apache_do_patch_init_script = $dynatrace::params::apache_wsagent_apache_do_patch_init_script,
  $apache_wsagent_linux_agent_path            = $dynatrace::params::apache_wsagent_linux_agent_path,

  $collector_installer_bitsize    = $dynatrace::params::collector_installer_bitsize,
  $collector_installer_prefix_dir = $dynatrace::params::collector_installer_prefix_dir,
  $collector_installer_file_name  = $dynatrace::params::collector_installer_file_name,
  $collector_installer_file_url   = $dynatrace::params::collector_installer_file_url,
  $collector_agent_port           = $dynatrace::params::collector_agent_port,
  $collector_server_hostname      = $dynatrace::params::collector_server_hostname,
  $collector_server_port          = $dynatrace::params::collector_server_port,

  $java_agent_env_var_name       = $dynatrace::params::java_agent_env_var_name,
  $java_agent_env_var_file_name  = $dynatrace::params::java_agent_env_var_file_name,
  $java_agent_name               = $dynatrace::params::java_agent_name,
  $java_agent_collector_hostname = $dynatrace::params::java_agent_collector_hostname,
  $java_agent_collector_port     = $dynatrace::params::java_agent_collector_port,
  $java_agent_linux_agent_path   = $dynatrace::params::java_agent_linux_agent_path,

  $wsagent_package_agent_name           = $dynatrace::params::wsagent_package_agent_name,
  $wsagent_package_collector_hostname   = $dynatrace::params::wsagent_package_collector_hostname,
  $wsagent_package_collector_port       = $dynatrace::params::wsagent_package_collector_port,
  $wsagent_package_installer_prefix_dir = $dynatrace::params::wsagent_package_installer_prefix_dir,
  $wsagent_package_installer_file_name  = $dynatrace::params::wsagent_package_installer_file_name,
  $wsagent_package_installer_file_url   = $dynatrace::params::wsagent_package_installer_file_url,

  $server_installer_prefix_dir = $dynatrace::params::server_installer_prefix_dir,
  $server_installer_file_name  = $dynatrace::params::server_installer_file_name,
  $server_installer_file_url   = $dynatrace::params::server_installer_file_url,
  $server_license_file_name    = $dynatrace::params::server_license_file_name,
  $server_license_file_url     = $dynatrace::params::server_license_file_url,
  $server_collector_port       = $dynatrace::params::server_collector_port,
  $server_do_pwh_connection    = $dynatrace::params::server_do_pwh_connection,

  $server_pwh_connection_hostname = $dynatrace::params::server_pwh_connection_hostname,
  $server_pwh_connection_port     = $dynatrace::params::server_pwh_connection_port,
  $server_pwh_connection_dbms     = $dynatrace::params::server_pwh_connection_dbms,
  $server_pwh_connection_database = $dynatrace::params::server_pwh_connection_database,
  $server_pwh_connection_username = $dynatrace::params::server_pwh_connection_username,
  $server_pwh_connection_password = $dynatrace::params::server_pwh_connection_password,
) inherits dynatrace::params {

}
