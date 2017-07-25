

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

| Env. variable name | Value |
| ------------------ | ------------- |
| CONF\_FILE         | /etc/puppetlabs/puppet/puppet.conf  |
| BASEMODULE\_PARAM  | basemodulepath = /etc/puppetlabs/code/environments/production/modules  |
| SERVICE            | puppetserver  |
| DIR                | dynatrace  |

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

From the `./environment/Server` location execute following commands in that order:


You should modify above properties if necessary.

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
    sudo apparmor_status
    ```
    * Hostnames are correctly added to /etc/hosts (you can remove ubuntu-xenial registry if present)
    * Server has opened 8140 port
    ```
    netstat -nap | grep 8140
    ```
    * Module is point to `/etc/puppetlabs/code/environments/production/modules/`
    ```
    sudo puppet config print modulepath --section master --environment production
    ```
3. Add puppet path to sudoers env file: 
    * `sudo visudo` and append `":/opt/puppetlabs/puppet/bin"` to `"Defaults secure_path="`
4. Execute:
    ```
    ./up_puppetserver.sh
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

| Env. variable name | Value |
| ------------- | ------------- |
| INI_FILE    | /etc/php/7.0/apache2/php.ini  |
| PHP_LOADER_PATH_PARAM | extension = /opt/dynatrace-7.0/agent/bin/linux-x86-64/liboneagentloader.so  |
| PHPAGENT_SERVER_PARAM    | phpagent.server = https://localhost:8043  |
| PHPAGENT_NAME_PARAM    | phpagent.agentname = phpOneAgent  |
| PHPAGENT_TENANT_PARAM    | phpagent.tenant = 1  |

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
    sudo apparmor_status
    ```
    * Hostnames are correctly added to /etc/hosts (you can remove ubuntu-xenial registry if present)
    * Server is reachable on port 8140 for Agent On server
    ```
    telnet puppetserver.clients.dynatrace.org 8140
    ```
    * Below properties are correctly added to `/etc/puppetlabs/puppet/puppet.conf`
    ```
    server = puppetserver.clients.dynatrace.org
    environment = production
    ```
3. Add puppet path to sudoers env file: 
    * `sudo visudo` and append `":/opt/puppetlabs/puppet/bin"` to `"Defaults secure_path="`
4. Execute:
    ```
    ./up_puppetagent.sh
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
    1. On Agent Host:
    ```
    sudo puppet resource service puppet ensure=stopped enable=false
    sudo find /etc/puppetlabs/puppet/ssl -name '*.pem' -delete
    ```
    2. On Server Host:
    ```    
    sudo systemctl stop puppetserver
    sudo find /etc/puppetlabs/puppet/ssl -name <AGENT\_HOSTNAME>.pem -delete
    sudo systemctl start puppetserver
    ```
    3. and then again on Agent Host:
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
    
#### References:
* In case of catalog issues: https://docs.puppet.com/puppet/latest/environment_isolation.html
