

# Local Puppet environment with Vagrant setup
## Puppet Server provisioning
This guideline will help you with installing Puppet Server on Ubuntu 16.04 VM


### Configuration

Default values for given parameters: 

* `provisioning_puppetserver_ubuntu.sh`:

| Env. variable name  | Value |
| ------------------- | ------------- |
| AGENT\_HOST         | 172.18.131.21   puppetagent     puppetagent.clients.dynatrace.org  |
| LOCAL\_HOST         | 127.0.1.1       puppetserver    puppetserver.clients.dynatrace.org  |


* `up_puppetserver.sh`:

| Env. variable name | Value | Description |
| ------------------ | ------------- |------------- |
| CONF\_FILE         | /etc/puppetlabs/puppet/puppet.conf  | Puppet configuration file path |
| BASEMODULE\_PARAM  | basemodulepath = /etc/puppetlabs/code/environments/production/modules  | Default modulet path |
| SERVICE            | puppetserver  | Puppet Server service name |
| DIR                | dynatrace  | Dynatrace Appmon installation folder  |
| BRANCH             | master  | Branch of Dynatrace-Puppet repository |

**Note** By default `./up_puppetserver.sh` script inserts following roles to `site.pp` file
  
  ```
  node default {
            include dynatrace::role::server
            include dynatrace::role::server_license
            include dynatrace::role::collector
            include dynatrace::role::agents_package
            include dynatrace::role::wsagent_package
            include dynatrace::role::apache_wsagent
            include dynatrace::role::java_agent
            include dynatrace::role::host_agent
            include dynatrace::role::memory_analysis_server
            include dynatrace::role::php_one_agent
    }
  ```

### Installation

From the `./environment/server_vm` location execute following commands in that order:


You should modify above properties if necessary.

1. Execute:
    ```
    vagrant up
    vagrant reload
    vagrant ssh
    ```
    `vagrant reload` is required to apply hostname and apparmor changes/removal.

2. Add puppet path to sudoers env file: 
    * `sudo visudo` and append `":/opt/puppetlabs/puppet/bin"` to `"Defaults secure_path="`
    
3. Verify that:
    * Apparmor is disabled and removed:
    ```
    which apparmor_status
    ```
    * Hostnames are correctly added to /etc/hosts (you can remove ubuntu-xenial registry if present)

4. Execute:
    ```
    ./up_puppetserver.sh
    ```
    
5. Verify that:
    * ServerPuppet is listening on port 8140:
    ```
    sudo netstat -nap | grep 8140
    ```    
    
    * Module is point to `/etc/puppetlabs/code/environments/production/modules/`
    ```
    sudo puppet config print modulepath --section master --environment production
    ```
    
**Result**: It should start puppetserver service successfully.

## Puppet Agent provisioning
This guideline will help you with installing Puppet Agent on Ubuntu 16.04 VM

### Configuration

Default values for given parameters: 

* `provisioning_puppetagent_ubuntu.sh`:

| Env. variable name  | Value |
| ------------------- | ------------- |
| SERVER\_HOST        | 172.18.131.23   puppetserver     puppetserver.clients.dynatrace.org  |
| LOCAL\_HOST         | 127.0.1.1       puppetagent    puppetagent.clients.dynatrace.org  |


* `up_puppetagent.sh`:

| Env. variable name | Value |
| ------------- | ------------- |
| CONF\_FILE    | /etc/puppetlabs/puppet/puppet.conf  |
| SERVER\_PARAM | server = puppetserver.clients.dynatrace.org  |
| ENV\_PARAM    | environment = production  |


* `php_oneagent_init.sh`:

| Env. variable name | Value | Description |
| ------------- | ------------- |------------- |
| INI_FILE    | /etc/php/7.0/apache2/php.ini  | Php.ini path |
| PHP_LOADER_PATH_PARAM | extension = /opt/dynatrace-7.0/agent/bin/linux-x86-64/liboneagentloader.so  | Path to OneAgent bootstrap library |
| PHPAGENT_SERVER_PARAM    | phpagent.server = https://localhost:8043 | Puppet server \<address\>:\<port\> location |
| PHPAGENT_NAME_PARAM    | phpagent.agentname = phpOneAgent  | Php OneAgent name |
| PHPAGENT\_TENANT\_PARAM    | phpagent.tenant = 1  | Php OneAgent tenant parameter |

**Note: to make PHP OneAgent running successfully, you need to configure Agent pattern recognition in Dynatrace Appmon as ${PHPAGENT_NAME_PARAM}. Please also refer main README file for PHP OneAgent information. 

### Installation

From the `./environment/agent_vm/` location execute following commands in that order:

1. Execute:
    ```
    vagrant up
    vagrant reload
    vagrant ssh
    ```
    `vagrant reload` is required to apply hostname and apparmor changes/removal.

2. Verify that:
    * Apparmor is disabled and removed:
    ```
    which apparmor_status
    ```
    
    * Hostnames are correctly added to /etc/hosts (you can remove ubuntu-xenial registry if present)
    ```
    sudo vi /etc/hosts
    ```
    
3. Add puppet path to sudoers env file: 
    * `sudo visudo` and append `":/opt/puppetlabs/puppet/bin"` to `"Defaults secure_path="`
    
4. Execute:
    ```
    ./up_puppetagent.sh
    ```
    
5. Verify that:
    * Server is reachable on port 8140 for Agent On server
    ```
    telnet puppetserver.clients.dynatrace.org 8140
    ```
    
    * Below properties are correctly added to `/etc/puppetlabs/puppet/puppet.conf`
    ```
    server = puppetserver.clients.dynatrace.org
    environment = production
    ```

**Result**: It should fail and ask for accepting certificate by the Server Host. 

1. Execute following procedure on Server Host:
```
sudo puppet cert list
sudo puppet cert sign <CERT_NAME_WITHOUT_QUOTES>
```
2. Execute following command on Agent Host:
```
sudo puppet agent --test --debug --environment production
```

## In case of issues...
* Check correctness of Vagrant provisioning including port forwarding
* Restart puppetserver
    ```
    sudo systemctl restart puppetserver
    ```
* Restart Agent
    ```
    sudo puppet resource service puppet ensure=stopped enable=false
    sudo puppet resource service puppet ensure=running enable=true
    ```
* Remove certifications (**remember of stopping puppet services!**):
    1. On Agent Host
    ```
    sudo puppet resource service puppet ensure=stopped enable=false
    sudo find /etc/puppetlabs/puppet/ssl -name '*.pem' -delete
    ```
    2. On Server Host
    ```    
    sudo systemctl stop puppetserver
    sudo find /etc/puppetlabs/puppet/ssl -name <AGENT\_HOSTNAME>.pem -delete
    sudo systemctl start puppetserver
    ```
    3. One Agent Host
    ```
    sudo puppet resource service puppet ensure=running enable=true
    sudo puppet agent -t --waitforcert=60
    ```
    or/then
    ```
    sudo puppet agent --test --debug --environment production
    ```
* Check logs:
    ```
    sudo less /var/log/puppetlabs/puppetserver/puppetserver.log
    ```
* Remove Server Cache:
    ```
    sudo rm -rf /opt/puppetlabs/server/data/puppetserver/*
    ```
    ```
    sudo rm -rf /opt/puppetlabs/puppet/cache
    ```
* Remove Agent's lock:
    ```
    sudo rm -rf /opt/puppetlabs/puppet/cache/state/agent_catalog_run.lock
    ```
    
#### References:
* In case of catalog issues: https://docs.puppet.com/puppet/latest/environment_isolation.html