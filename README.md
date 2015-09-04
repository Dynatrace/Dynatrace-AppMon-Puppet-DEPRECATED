# dynatrace Module

This Puppet module installs and configures the Dynatrace Application Monitoring solution.

## Requirements

Please see `Puppetfile` and `metadata.json` for a list of module dependencies.

## Classes

### dynatrace::role::agents_package

*Installs the Dynatrace Agents package.*

Download the Dynatrace Agents package from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-agents.jar` in the module's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_url` parameter. Please refer to `manifests/role/agents_package.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-agents.jar'
}
```

**Note:** this recipe merely makes the Dynatrace Agents available, but it does not configure your application to actually load any. See the `dynatrace::role::java_agent` class for an example that does.

### dynatrace::role::apache_wsagent

*Installs the Dynatrace WebServer Agent for the Apache HTTP Server.*

Download the Dynatrace WebServer Agent installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-wsagent.tar` in the module's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_url` parameter. Please refer to `manifests/role/apache_wsagent.pp` and `manifests/role/wsagent_package.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-wsagent.tar'
}

class { 'dynatrace::role::apache_wsagent':
  apache_config_file_path     => '/etc/apache2/apache2.conf',
  require                     => Class['dynatrace::role::wsagent_package']
}
```

**Note:** you will have to restart the web server after placing the agent.

### dynatrace::role::collector

*Installs the Dynatrace Collector.*

Download the Dynatrace Collector installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-collector.jar` in the module's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_url` parameter. Please refer to `manifests/role/collector.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-agents.jar'
}
```

**Note:** make sure that attributes related to the Collector's memory configuration are set in accordance to the [Memory Configuration](https://community.dynatrace.com/community/display/DOCDT60/Collector+Configuration#CollectorConfiguration-MemoryConfiguration) section of the [Collector Configuration](https://community.dynatrace.com/community/display/DOCDT60/Collector+Configuration) documentation.

### dynatrace::role::java_agent

*Installs the Dynatrace Agent Java Agent.*

Download the Dynatrace Agent package from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-agents.jar` in the module's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_url` attribute. Please refer to `manifests/role/java_agent.pp` and `manifests/role/agents_package.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-agents.jar'
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

Download the Dynatrace Memory Analysis Server installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-analysisserver.jar` in the modules's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_url` parameter. Please refer to `manifests/role/memory_analysis_server.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::memory_analysis_server':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-analysisserver.jar'
}
```

**Note:** make sure that attributes related to the Analysis Server's memory configuration are set in accordance to the [Memory Configuration](https://community.dynatrace.com/community/display/DOCDT62/Memory+Analysis+Server+Configuration#MemoryAnalysisServerConfiguration-MemoryConfiguration) section of the [Memory Analysis Server Configuration](https://community.dynatrace.com/community/display/DOCDT62/Memory+Analysis+Server+Configuration) documentation.

### dynatrace::role::server

*Installs the Dynatrace Server.*

Download the Dynatrace Server installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace.jar` in the modules's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_url` parameter. Please refer to `manifests/role/server.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::server':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace.jar'
}
```

### dynatrace::role::server_license

*Installs the Dynatrace Server License.*

Place the Dynatrace Server License as `dynatrace-license.key` in the module's `files` directory. Alternatively, you can make the license available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$license_file_url` parameter. Please refer to `manifests/role/server_license.pp` for a list of supported attributes, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::server':
  license_file_url => 'http://10.0.2.2/dynatrace/dynatrace-license.key'
}
```

### dynatrace::role::wsagent_package

*Installs the Dynatrace WebServer Agent package.*

Download the Dynatrace WebServer Agent package from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-wsagent.jar` in the module's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_name` attribute. Please refer to `manifests/role/wsagent_package.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::wsagent_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-wsagent.tar'
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