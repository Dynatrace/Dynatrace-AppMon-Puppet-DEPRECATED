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
  apache_init_script_path     => '/etc/init.d/apache2',
  apache_do_patch_init_script => true,
  require                     => Class['dynatrace::role::wsagent_package']
}
```

**Note:** you will have to restart the web server after placing the agent. You should also make sure that the Apache HTTP service is started only after the Dynatrace WebServer Agent service to maintain a correct startup order whenever the machine under management gets rebooted. Currently, this can be automated for systems that start the Apache HTTP server via an [LSB init script](http://refspecs.linuxbase.org/LSB_3.0.0/LSB-generic/LSB-generic/iniscrptact.html) in `/etc/init.d` via the `$do_patch_init_script` and related parameters in `manifests/role/apache_wsagent.pp`.

### dynatrace::role::collector

*Installs the Dynatrace Collector.*

Download the Dynatrace Collector installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-collector.jar` in the module's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_url` parameter. Please refer to `manifests/role/collector.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::agents_package':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace-agents.jar'
}
```

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

### dynatrace::role::server

*Installs the Dynatrace Server.*

Download the Dynatrace Server installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace.jar` in the modules's `files` directory. Alternatively, you can make the installer available as an *HTTP*, *HTTPS* or *FTP* resource and point the class to the right location via the `$installer_file_url` parameter. Please refer to `manifests/role/server.pp` for a list of supported parameters, whose default values can be overridden in `manifests/params.pp`. In order to install, execute the class as follows:

```
class { 'dynatrace::role::server':
  installer_file_url => 'http://10.0.2.2/dynatrace/dynatrace.jar'
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

By default, we run our tests inside [Docker](https://www.docker.com/) containers as this considerably speeds up testing time (see `.kitchen.yml`. Alternatively, you may as well run these tests in virtual machines based on [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) (see `.kitchen.vagrant.yml`).

## Questions?

Feel free to post your questions on the Dynatrace Community's [Continuous Delivery Forum](https://community.dynatrace.com/community/pages/viewpage.action?pageId=46628921).

## License

Licensed under the MIT License. See the LICENSE file for details.
[![analytics](https://www.google-analytics.com/collect?v=1&t=pageview&_s=1&dl=https%3A%2F%2Fgithub.com%2FdynaTrace&dp=%2FDynatrace-Puppet&dt=Dynatrace-Puppet&_u=Dynatrace~&cid=github.com%2FdynaTrace&tid=UA-54510554-5&aip=1)]()