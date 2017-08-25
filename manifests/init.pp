#dynatraceappmon
class dynatraceappmon (
  $installer_cache_dir = $dynatraceappmon::params::installer_cache_dir,

  $agents_package_installer_bitsize    = $dynatraceappmon::params::agents_package_installer_bitsize,
  $agents_package_installer_prefix_dir = $dynatraceappmon::params::agents_package_installer_prefix_dir,
  $agents_package_installer_file_name  = $dynatraceappmon::params::agents_package_installer_file_name,
  $agents_package_installer_file_url   = $dynatraceappmon::params::agents_package_installer_file_url,

  $apache_wsagent_apache_config_file_path     = $dynatraceappmon::params::apache_wsagent_apache_config_file_path,
  $apache_wsagent_apache_init_script_path     = $dynatraceappmon::params::apache_wsagent_apache_init_script_path,
  $apache_wsagent_apache_do_patch_init_script = $dynatraceappmon::params::apache_wsagent_apache_do_patch_init_script,
  $apache_wsagent_linux_agent_path            = $dynatraceappmon::params::apache_wsagent_linux_agent_path,

  $collector_installer_bitsize    = $dynatraceappmon::params::collector_installer_bitsize,
  $collector_installer_prefix_dir = $dynatraceappmon::params::collector_installer_prefix_dir,
  $collector_installer_file_name  = $dynatraceappmon::params::collector_installer_file_name,
  $collector_installer_file_url   = $dynatraceappmon::params::collector_installer_file_url,
  $collector_agent_port           = $dynatraceappmon::params::collector_agent_port,
  $collector_server_hostname      = $dynatraceappmon::params::collector_server_hostname,
  $collector_server_port          = $dynatraceappmon::params::collector_server_port,
  $collector_jvm_xms              = $dynatraceappmon::params::collector_jvm_xms,
  $collector_jvm_xmx              = $dynatraceappmon::params::collector_jvm_xmx,
  $collector_jvm_perm_size        = $dynatraceappmon::params::collector_jvm_perm_size,
  $collector_jvm_max_perm_size    = $dynatraceappmon::params::collector_jvm_max_perm_size,

  $dynatrace_owner                = $dynatraceappmon::params::dynatrace_owner,
  $dynatrace_group                = $dynatraceappmon::params::dynatrace_group,

  $java_agent_env_var_name       = $dynatraceappmon::params::java_agent_env_var_name,
  $java_agent_env_var_file_name  = $dynatraceappmon::params::java_agent_env_var_file_name,
  $java_agent_name               = $dynatraceappmon::params::java_agent_name,
  $java_agent_collector_hostname = $dynatraceappmon::params::java_agent_collector_hostname,
  $java_agent_collector_port     = $dynatraceappmon::params::java_agent_collector_port,
  $java_agent_linux_agent_path   = $dynatraceappmon::params::java_agent_linux_agent_path,

  $memory_analysis_server_installer_bitsize    = $dynatraceappmon::params::memory_analysis_server_installer_bitsize,
  $memory_analysis_server_installer_prefix_dir = $dynatraceappmon::params::memory_analysis_server_installer_prefix_dir,
  $memory_analysis_server_installer_file_name  = $dynatraceappmon::params::memory_analysis_server_installer_file_name,
  $memory_analysis_server_installer_file_url   = $dynatraceappmon::params::memory_analysis_server_installer_file_url,
  $memory_analysis_server_server_port          = $dynatraceappmon::params::memory_analysis_server_server_port,
  $memory_analysis_server_jvm_xms              = $dynatraceappmon::params::memory_analysis_server_jvm_xms,
  $memory_analysis_server_jvm_xmx              = $dynatraceappmon::params::memory_analysis_server_jvm_xmx,
  $memory_analysis_server_jvm_perm_size        = $dynatraceappmon::params::memory_analysis_server_jvm_perm_size,
  $memory_analysis_server_jvm_max_perm_size    = $dynatraceappmon::params::memory_analysis_server_jvm_max_perm_size,

  $server_installer_bitsize       = $dynatraceappmon::params::server_installer_bitsize,
  $server_installer_prefix_dir    = $dynatraceappmon::params::server_installer_prefix_dir,
  $server_installer_file_name     = $dynatraceappmon::params::server_installer_file_name,
  $server_installer_file_url      = $dynatraceappmon::params::server_installer_file_url,
  $server_license_file_name       = $dynatraceappmon::params::server_license_file_name,
  $server_license_file_url        = $dynatraceappmon::params::server_license_file_url,
  $server_collector_port          = $dynatraceappmon::params::server_collector_port,
  $server_pwh_connection_hostname = $dynatraceappmon::params::server_pwh_connection_hostname,
  $server_pwh_connection_port     = $dynatraceappmon::params::server_pwh_connection_port,
  $server_pwh_connection_dbms     = $dynatraceappmon::params::server_pwh_connection_dbms,
  $server_pwh_connection_database = $dynatraceappmon::params::server_pwh_connection_database,
  $server_pwh_connection_username = $dynatraceappmon::params::server_pwh_connection_username,
  $server_pwh_connection_password = $dynatraceappmon::params::server_pwh_connection_password,

  $wsagent_package_agent_name           = $dynatraceappmon::params::wsagent_package_agent_name,
  $wsagent_package_collector_hostname   = $dynatraceappmon::params::wsagent_package_collector_hostname,
  $wsagent_package_collector_port       = $dynatraceappmon::params::wsagent_package_collector_port,
  $wsagent_package_installer_prefix_dir = $dynatraceappmon::params::wsagent_package_installer_prefix_dir,
  $wsagent_package_installer_file_name  = $dynatraceappmon::params::wsagent_package_installer_file_name,
  $wsagent_package_installer_file_url   = $dynatraceappmon::params::wsagent_package_installer_file_url,

  $host_agent_installer_prefix_dir = $dynatraceappmon::params::host_agent_installer_prefix_dir,
  $host_agent_installer_file_name  = $dynatraceappmon::params::host_agent_installer_file_name,
  $host_agent_installer_file_url   = $dynatraceappmon::params::host_agent_installer_file_url,
  $host_agent_name                 = $dynatraceappmon::params::host_agent_name,
  $host_agent_collector_name       = $dynatraceappmon::params::host_agent_collector_name,

  $update_file_url           = $dynatraceappmon::params::update_file_url,
  $update_rest_url           = $dynatraceappmon::params::update_rest_url,
  $update_user               = $dynatraceappmon::params::update_user,
  $update_passwd             = $dynatraceappmon::params::update_passwd,

  $dynaTraceCollector      = $dynatraceappmon::params::dynaTraceCollector,
  $dynaTraceHostagent      = $dynatraceappmon::params::dynaTraceHostagent,
  $dynaTraceAnalysis       = $dynatraceappmon::params::dynaTraceAnalysis,
  $dynaTraceServer         = $dynatraceappmon::params::dynaTraceServer,
  $dynaTraceWebServerAgent = $dynatraceappmon::params::dynaTraceWebServerAgent,
  $dynaTraceFrontendServer = $dynatraceappmon::params::dynaTraceFrontendServer,
  $dynaTraceBackendServer  = $dynatraceappmon::params::dynaTraceBackendServer,

  $services_to_manage_array = $dynatraceappmon::params::services_to_manage_array,

  $php_one_agent_php_config_file_path = $dynatraceappmon::params::php_one_agent_php_config_file_path,
  $php_one_agent_php_config_file_name = $dynatraceappmon::params::php_one_agent_php_config_file_name


) inherits dynatraceappmon::params {

}
