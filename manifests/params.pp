# Class: dynatrace::params
#
# This class configures parameters for the dynatrace-dynatrace module.
#
# Parameters:
#  $agents_package_installer_prefix_dir => The Dynatrace Agents package will be installed into the directory $agents_package_installer_prefix_dir/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in $agents_package_installer_prefix_dir/dynatrace.
#  $agents_package_installer_file_name  => The file name of the Dynatrace Agents installer in the module's files directory.
#  $agents_package_installer_file_url   => A HTTP, HTTPS or FTP URL to the Dynatrace Agents installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
#
#  $apache_wsagent_apache_config_file_path     => The path to the Apache HTTP Server's config file.
#  $apache_wsagent_apache_init_script_path     => The path to the Apache HTTP Server's init script.
#  $apache_wsagent_apache_do_patch_init_script => Whether the init script shall be patched so that the Apache HTTP Server service is started only after the Dynatrace WebServer Agent service has started, or not.
#  $apache_wsagent_linux_agent_path            => The path to the Dynatrace Agent library.
#  
#  $collector_installer_bitsize    => '32' or '64'.
#  $collector_installer_prefix_dir => The Dynatrace Collector will be installed into the directory $collector_installer_prefix_dir/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in $collector_installer_prefix_dir/dynatrace.
#  $collector_installer_file_name  => The file name of the Dynatrace Collector installer in the module's files directory.
#  $collector_installer_file_url   => A HTTP, HTTPS or FTP URL to the Dynatrace Collector installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
#  $collector_agent_port           => The port where the Dynatrace Collector shall listen for Agents.
#  $collector_server_hostname      => The location of the Dynatrace Server the Collector shall connect to.
#  $collector_server_port          => The port on the Dynatrace Server the Collector shall connect to. Use either 6698 (non-SSL) or 6699 (SSL).
#  
#  $java_agent_env_var_name       => The name of the environment variable to be used for Dynatrace Agent injection.
#  $java_agent_env_var_file_name  => The name of the file to be modified.
#  $java_agent_name               => The name of the Dynatrace Agent as it appears in the Dynatrace Server.
#  $java_agent_collector_hostname => The location of the collector the Dynatrace Agent shall connect to.
#  $java_agent_collector_port     => The port on the collector the Dynatrace Agent shall connect to.
#  $java_agent_linux_agent_path   => The path to the Dynatrace Agent libary.
#  
#  $server_installer_prefix_dir    => The Dynatrace Server will be installed into the directory $server_installer_prefix_dir/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in $server_installer_prefix_dir/dynatrace.
#  $server_installer_file_name     => The file name of the Dynatrace installer in the cookbook's files directory.
#  $server_installer_file_url      => A HTTP, HTTPS or FTP URL to the Dynatrace installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
#  $server_license_file_name       => The file name of the Dynatrace License in the cookbook's files directory.
#  $server_license_file_url        => A HTTP, HTTPS or FTP URL to the Dynatrace License in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
#  $server_collector_port          => The port where the Dynatrace Server shall listen for Collectors. Use either 6698 (non-SSL) or 6699 (SSL).
#  $server_do_pwh_connection       => Whether a connection to an existing Performance Warehouse (database) shall be established, or not. Requires Dynatrace >= v6.2.
#  $server_pwh_connection_hostname =>
#  $server_pwh_connection_port     =>
#  $server_pwh_connection_dbms     => The DBMS type of the Performance Warehouse. Possible values are 'embedded' (not suitable for production systems), 'db2', 'oracle', 'postgresql', 'sqlazure', 'sqlserver'.
#  $server_pwh_connection_database =>
#  $server_pwh_connection_username =>
#  $server_pwh_connection_password =>
#  
#  $wsagent_package_agent_name           => The name the Dynatrace WebServer Agent as it appears in the Dynatrace Server.
#  $wsagent_package_collector_hostname   => The location of the Dynatrace Collector the Web Server Agent shall connect to.
#  $wsagent_package_collector_port       => The port on the Dynatrace Collector the Web Server Agent shall connect to.
#  $wsagent_package_installer_prefix_dir => The Dynatrace WebServer Agent will be installed into the directory $wsagent_package_installer_prefix_dir/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in $wsagent_package_installer_prefix_dir/dynatrace.
#  $wsagent_package_installer_file_name  => The file name of the Dynatrace WebServer Agent installer in the module's files directory.
#  $wsagent_package_installer_file_url   => A HTTP, HTTPS or FTP URL to the Dynatrace Web Server Agent installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
#  
class dynatrace::params {

  case $::kernel {
    'Linux': {
      $agents_package_installer_prefix_dir = '/opt'
      $agents_package_installer_file_name  = 'dynatrace-agents.jar'
      $agents_package_installer_file_url   = undef

      $apache_wsagent_apache_config_file_path     = '/etc/apache2/apache2.conf'
      $apache_wsagent_apache_init_script_path     = '/etc/init.d/apache2'
      $apache_wsagent_apache_do_patch_init_script = false
      $apache_wsagent_linux_agent_path            = '/opt/dynatrace/agent/lib64/libdtagent.so'

      $collector_installer_bitsize    = '64'
      $collector_installer_prefix_dir = '/opt'
      $collector_installer_file_name  = 'dynatrace-collector.jar'
      $collector_installer_file_url   = undef
      $collector_agent_port           = '9998'
      $collector_server_hostname      = 'localhost'
      $collector_server_port          = '6698'

      $java_agent_env_var_name       = 'JAVA_OPTS'
      $java_agent_env_var_file_name  = undef
      $java_agent_name               = 'java-agent'
      $java_agent_collector_hostname = 'localhost'
      $java_agent_collector_port     = '9998'
      $java_agent_linux_agent_path   = '/opt/dynatrace/agent/lib64/libdtagent.so'

      $wsagent_package_agent_name           = 'dtwsagent'
      $wsagent_package_collector_hostname   = 'localhost'
      $wsagent_package_collector_port       = '9998'
      $wsagent_package_installer_prefix_dir = '/opt'
      $wsagent_package_installer_file_name  = 'dynatrace-wsagent.tar'
      $wsagent_package_installer_file_url   = undef

      $server_installer_prefix_dir = '/opt'
      $server_installer_file_name = 'dynatrace.jar'
      $server_installer_file_url = undef
      $server_license_file_name = 'dynatrace-license.key'
      $server_license_file_url = undef
      $server_collector_port = '6698'
      $server_do_pwh_connection = false

      $server_pwh_connection_hostname = 'localhost'
      $server_pwh_connection_port     = '5432'
      $server_pwh_connection_dbms     = 'postgresql'
      $server_pwh_connection_database = 'dynatrace-pwh'
      $server_pwh_connection_username = 'dynatrace'
      $server_pwh_connection_password = 'dynatrace'
    }
    default: {
      fail("The kernel '${::kernel}' is currently not supported.")
    }
  }
}