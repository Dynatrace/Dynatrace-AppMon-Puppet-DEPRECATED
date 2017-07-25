#!/bin/bash
#TODO: create sed to inject /opt/puppetlabs/puppet/bin path to sudoers secure path
#Make sure that puppet path is added to sudoers path

#sudo hostnamectl set-hostname puppetserver --static
#echo "preserve_hostname: true" | sudo tee -a /etc/cloud/cloud.cfg
#and make sure that hostname is changed in /etc/hosts for 127.0.1.1

DIR=${DIR:-"dynatrace"}
CONF_FILE=${CONF_FILE:-"/etc/puppetlabs/puppet/puppet.conf"}
BASEMODULE_PARAM=${BASEMODULE_PARAM:-"basemodulepath = /etc/puppetlabs/code/environments/production/modules"}
SERVICE=${SERVICE:-puppetserver}

cd /etc/puppetlabs/code/environments/production/modules/
sudo mkdir -p $DIR
sudo git clone https://github.com/Dynatrace/Dynatrace-Puppet.git $DIR
sudo puppet module install puppetlabs-stdlib
sudo puppet module install maestrodev-wget --version 1.7.3
sudo puppet module install AlexCline-dirtree --version 0.2.1
sudo puppet module install puppet-archive --version 1.3.0


if ! grep -q "$BASEMODULE_PARAM" "$CONF_FILE"; then
  echo $BASEMODULE_PARAM | sudo tee -a $CONF_FILE
fi

sudo tee <<EOF /etc/puppetlabs/code/environments/production/manifests/site.pp >/dev/null
node default {
        include dynatrace::role::server
        include dynatrace::role::collector
        include dynatrace::role::php_one_agent
}
EOF

if (( $(ps -ef | grep -v grep | grep $SERVICE | wc -l) > 0 ))
    then
      echo "Restarting puppetserver..."
      sudo systemctl restart puppetserver
    else
      echo "Starting puppetserver..."
      sudo systemctl start puppetserver
fi
