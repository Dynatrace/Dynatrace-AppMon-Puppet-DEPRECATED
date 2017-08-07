#dynatrace
class dynatrace (
  $installer_cache_dir = $dynatrace::params::installer_cache_dir,

  $pid_file_directory = $dynatrace::params::pid_file_directory,

  $agents_package_installer_bitsize    = $dynatrace::params::agents_package_installer_bitsize,
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
  $collector_jvm_xms              = $dynatrace::params::collector_jvm_xms,
  $collector_jvm_xmx              = $dynatrace::params::collector_jvm_xmx,
  $collector_jvm_perm_size        = $dynatrace::params::collector_jvm_perm_size,
  $collector_jvm_max_perm_size    = $dynatrace::params::collector_jvm_max_perm_size,

  $dynatrace_owner                = $dynatrace::params::dynatrace_owner,
  $dynatrace_group                = $dynatrace::params::dynatrace_group,

  $java_agent_env_var_name       = $dynatrace::params::java_agent_env_var_name,
  $java_agent_env_var_file_name  = $dynatrace::params::java_agent_env_var_file_name,
  $java_agent_name               = $dynatrace::params::java_agent_name,
  $java_agent_collector_hostname = $dynatrace::params::java_agent_collector_hostname,
  $java_agent_collector_port     = $dynatrace::params::java_agent_collector_port,
  $java_agent_linux_agent_path   = $dynatrace::params::java_agent_linux_agent_path,

  $memory_analysis_server_installer_bitsize    = $dynatrace::params::memory_analysis_server_installer_bitsize,
  $memory_analysis_server_installer_prefix_dir = $dynatrace::params::memory_analysis_server_installer_prefix_dir,
  $memory_analysis_server_installer_file_name  = $dynatrace::params::memory_analysis_server_installer_file_name,
  $memory_analysis_server_installer_file_url   = $dynatrace::params::memory_analysis_server_installer_file_url,
  $memory_analysis_server_server_port          = $dynatrace::params::memory_analysis_server_server_port,
  $memory_analysis_server_jvm_xms              = $dynatrace::params::memory_analysis_server_jvm_xms,
  $memory_analysis_server_jvm_xmx              = $dynatrace::params::memory_analysis_server_jvm_xmx,
  $memory_analysis_server_jvm_perm_size        = $dynatrace::params::memory_analysis_server_jvm_perm_size,
  $memory_analysis_server_jvm_max_perm_size    = $dynatrace::params::memory_analysis_server_jvm_max_perm_size,

  $server_installer_bitsize       = $dynatrace::params::server_installer_bitsize,
  $server_installer_prefix_dir    = $dynatrace::params::server_installer_prefix_dir,
  $server_installer_file_name     = $dynatrace::params::server_installer_file_name,
  $server_installer_file_url      = $dynatrace::params::server_installer_file_url,
  $server_license_file_name       = $dynatrace::params::server_license_file_name,
  $server_license_file_url        = $dynatrace::params::server_license_file_url,
  $server_collector_port          = $dynatrace::params::server_collector_port,
  $server_pwh_connection_hostname = $dynatrace::params::server_pwh_connection_hostname,
  $server_pwh_connection_port     = $dynatrace::params::server_pwh_connection_port,
  $server_pwh_connection_dbms     = $dynatrace::params::server_pwh_connection_dbms,
  $server_pwh_connection_database = $dynatrace::params::server_pwh_connection_database,
  $server_pwh_connection_username = $dynatrace::params::server_pwh_connection_username,
  $server_pwh_connection_password = $dynatrace::params::server_pwh_connection_password,

  $wsagent_package_agent_name           = $dynatrace::params::wsagent_package_agent_name,
  $wsagent_package_collector_hostname   = $dynatrace::params::wsagent_package_collector_hostname,
  $wsagent_package_collector_port       = $dynatrace::params::wsagent_package_collector_port,
  $wsagent_package_installer_prefix_dir = $dynatrace::params::wsagent_package_installer_prefix_dir,
  $wsagent_package_installer_file_name  = $dynatrace::params::wsagent_package_installer_file_name,
  $wsagent_package_installer_file_url   = $dynatrace::params::wsagent_package_installer_file_url,

  $host_agent_installer_prefix_dir = $dynatrace::params::host_agent_installer_prefix_dir,
  $host_agent_installer_file_name  = $dynatrace::params::host_agent_installer_file_name,
  $host_agent_installer_file_url   = $dynatrace::params::host_agent_installer_file_url,
  $host_agent_name                 = $dynatrace::params::host_agent_name,
  $host_agent_collector_name       = $dynatrace::params::host_agent_collector_name,

  $update_file_url           = $dynatrace::params::update_file_url,
  $update_rest_url           = $dynatrace::params::update_rest_url,
  $update_user               = $dynatrace::params::update_user,
  $update_passwd             = $dynatrace::params::update_passwd,

  $dynaTraceCollector      = $dynatrace::params::dynaTraceCollector,
  $dynaTraceHostagent      = $dynatrace::params::dynaTraceHostagent,
  $dynaTraceAnalysis       = $dynatrace::params::dynaTraceAnalysis,
  $dynaTraceServer         = $dynatrace::params::dynaTraceServer,
  $dynaTraceWebServerAgent = $dynatrace::params::dynaTraceWebServerAgent,
  $dynaTraceFrontendServer = $dynatrace::params::dynaTraceFrontendServer,
  $dynaTraceBackendServer  = $dynatrace::params::dynaTraceBackendServer,

  $services_to_manage_array = $dynatrace::params::services_to_manage_array,

  $php_one_agent_php_config_file_path = $dynatrace::params::php_one_agent_php_config_file_path,
  $php_one_agent_php_config_file_name = $dynatrace::params::php_one_agent_php_config_file_name


) inherits dynatrace::params {

  if $pid_file_directory != '/tmp' {
    file { $pid_file_directory :
      ensure => 'directory',
    }
  }

}
