# dynatrace Module

This Puppet module installs and configures the Dynatrace Application Monitoring solution.

## Requirements

Please see `Puppetfile` and `metadata.json` for a list of module dependencies.

## Classes

### dynatrace::role::agents_package

*Installs the Dynatrace Agents package.*

This class downloads and installs the most recent version of the Dynatrace Agents package for the Linux platform from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default behavior can be overridden via the class' `$installer_file_url` parameter. Alternatively, you can place the installer artifact as `dynatrace-agent.jar` in the module's `files` directory from where it will be picked up during the installation. Please refer to `manifests/role/agents_package.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::agents_package':
  installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-agent-7.0.0.2469-unix.jar'
}
```

**Note:** this class merely makes the Dynatrace Agents available, but it does not configure your application to actually load any. See the `dynatrace::role::java_agent` class for an example that does.

### dynatrace::role::apache_wsagent

*Installs the Dynatrace WebServer Agent for the Apache HTTP Server.*

Please refer to `manifests/role/apache_wsagent.pp` and `manifests/role/wsagent_package.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-wsagent-7.0.0.2469-linux-x86-64.tar'
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path => '/etc/apache2/apache2.conf',
  require                 => Class['dynatrace::role::wsagent_package']
}
```

**Note:** you will have to restart the web server after placing the agent.

### dynatrace::role::collector

*Installs the Dynatrace Collector.*

This class downloads and installs the most recent version of the Dynatrace Collector for the Linux platform from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default behavior can be overridden via the class' `$installer_file_url` parameter. Alternatively, you can place the installer artifact as `dynatrace-collector.jar` in the module's `files` directory from where it will be picked up during the installation. Please refer to `manifests/role/collector.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::collector':
  installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-collector-7.0.0.2469-linux-x86.jar'
}
```

**Note:** make sure that attributes related to the Collector's memory configuration are set in accordance to the [Memory Configuration](https://www.dynatrace.com/support/doc/appmon/installation/set-up-system-components/set-up-collectors/) documentation.

### dynatrace::role::java_agent

*Installs the Dynatrace Java Agent.*

Please refer to `manifests/role/java_agent.pp` and `manifests/role/agents_package.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::agents_package':
  installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-agent-7.0.0.2469-unix.jar'
}

class { 'dynatrace::role::java_agent':
  env_var_name      => 'CATALINA_OPTS',
  env_var_file_name => '/opt/apache-tomcat/bin/catalina.sh',
  agent_name        => 'apache-tomcat-agent',
  require           => Class['dynatrace::role::agents_package']
}
```

**Note:** this recipe makes the Java Agent available to a Java Virtual Machine by injecting an appropriate [-agentpath](https://community.compuwareapm.com/community/display/DOCDT60/Java+Agent+Configuration) option into an environment variable, e.g. `JAVA_OPTS`, inside a file (typically an executable script). It is assumed that this script either executes the Java process directly or is sourced by another script before the Java process gets executed. You will have to restart the application after placing the agent.

### dynatrace::role::memory_analysis_server

*Installs the Dynatrace Memory Analysis Server.*

This class downloads and installs the most recent version of the Dynatrace Memory Analysis Server for the Linux platform from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default behavior can be overridden via the class' `$installer_file_url` parameter. Alternatively, you can place the installer artifact as `dynatrace-analysisserver.jar` in the module's `files` directory from where it will be picked up during the installation. Please refer to `manifests/role/memory_analysis_server.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::memory_analysis_server':
  installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-analysisserver-7.0.0.2469-linux-x86.jar'
}
```

**Note:** make sure that attributes related to the Analysis Server's memory configuration are set in accordance to the documentation [Set up a Memory Analysis Server](https://www.dynatrace.com/support/doc/appmon/installation/set-up-system-components/set-up-a-memory-analysis-server/).

### dynatrace::role::php_one_agent

*Installs the PHP OneAgent.*

This class downloads and installs the most recent version of the PHP OneAgent for the Linux platform from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default behavior can be overridden via the class' `$installer_file_url` parameter. Alternatively, you can place the installer artifact as `dynatrace-one-agent-php.tar` in the module's `files` directory from where it will be picked up during the installation. Please refer to `manifests/role/php_one_agent.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::php_one_agent':
  installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-one-agent-php-7.0.0.2469-linux-x86.tgz'
}
```

**Note:** make sure that attributes related to the One Agent configuration are set in accordance to the documentation [PHP Agent configuration](https://www.dynatrace.com/support/doc/appmon/installation/set-up-system-components/set-up-agents/php-agent-configuration/) and [OneAgent configuration](https://www.dynatrace.com/support/doc/appmon/installation/set-up-system-components/set-up-agents/oneagent-configuration//).

### dynatrace::role::server

*Installs the Dynatrace Server.*

This class downloads and installs the most recent version of the Dynatrace Memory Analysis Server for the Linux platform from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default behavior can be overridden via the class' `$installer_file_url` parameter. Alternatively, you can place the installer artifact as `dynatrace.jar` in the module's `files` directory from where it will be picked up during the installation. Please refer to `manifests/role/server.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::server':
  installer_file_url => 'http://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-server-7.0.0.2469-linux-x86.jar'
}
```

### dynatrace::role::server_license

*Installs the Dynatrace Server License.*

Place the Dynatrace Server License as `dynatrace-license.key` in the module's `files` directory. Alternatively, you can make the license available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$license_file_url` parameter. Please refer to `manifests/role/server_license.pp` for a list of supported attributes, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::server':
  license_file_url => 'http://my-license-server/dynatrace/dynatrace-license.key'
}
```

### dynatrace::role::wsagent_package

*Installs the Dynatrace WebServer Agent package.*

This class downloads and installs the most recent version of the Dynatrace WebServer Agent installer for the Linux platform from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default behavior can be overridden via the class' `$installer_file_url` parameter. Alternatively, you can place the installer artifact as `dynatrace-wsagent.tar` in the module's `files` directory from where it will be picked up during the installation. Please refer to `manifests/role/wsagent_package.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, you may execute the class as follows:

```
class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'https://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-wsagent-7.0.0.2469-linux-x86-64.tar'
}
```

**Note:** this recipe merely makes the Dynatrace WebServer Agent available, but it does not configure your web server to actually load it. See the `dynatrace::role::apache_wsagent` class for an example that does.

## Testing

We use [Test Kitchen](http://kitchen.ci) to automatically test our automated deployments with [Serverspec](http://serverspec.org) and [RSpec](http://rspec.info/):

1) Install Test Kitchen and its dependencies from within the project's directory:

```
gem install bundler
bundle install
```

2) Run all tests

```
kitchen test
```

By default, we run our tests inside [Docker](https://www.docker.com/) containers as this considerably speeds up testing time (see `.kitchen.yml`, requires Ruby 2.2+). Alternatively, you may as well run these tests in virtual machines based on [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) (see `.kitchen.vagrant.yml`).

## Additional Resources

- [Slide Deck: Test-Driven Infrastructure with Test Kitchen, Serverspec and RSpec](http://www.slideshare.net/MartinEtmajer/testdriven-infrastructure-with-puppet-test-kitchen-serverspec-and-rspec)

## Questions?

Feel free to post your questions on the Dynatrace Community's [Continuous Delivery Forum](https://answers.dynatrace.com/spaces/148/open-q-a_2.html?topics=continuous%20delivery).

## License

Licensed under the MIT License. See the LICENSE file for details.
[![analytics](https://www.google-analytics.com/collect?v=1&t=pageview&_s=1&dl=https%3A%2F%2Fgithub.com%2FdynaTrace&dp=%2FDynatrace-Puppet&dt=Dynatrace-Puppet&_u=Dynatrace~&cid=github.com%2FdynaTrace&tid=UA-54510554-5&aip=1)]()