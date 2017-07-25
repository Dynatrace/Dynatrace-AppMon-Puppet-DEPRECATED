#!/bin/bash -e
#TODO: create sed to inject /opt/puppetlabs/puppet/bin path to sudoers secure path

#sudo hostnamectl set-hostname puppetagent --static
#echo "preserve_hostname: true" | sudo tee -a /etc/cloud/cloud.cfg
#and make sure that hostname is changed in /etc/hosts for 127.0.1.1

CONF_FILE=${CONF_FILE:-"/etc/puppetlabs/puppet/puppet.conf"}
SERVER_PARAM=${SERVER_PARAM:-"server = puppetserver.clients.dynatrace.org"}
ENV_PARAM=${ENV_PARAM:-"environment = production"}

sudo apt-get -y install puppet-agent

if ! grep -q "$SERVER_PARAM" "$CONF_FILE"; then
  echo $SERVER_PARAM | sudo tee -a $CONF_FILE
fi

if ! grep -q "$ENV_PARAM" "$CONF_FILE"; then
  echo $ENV_PARAM | sudo tee -a $CONF_FILE
fi

./php_oneagent_init.sh

sudo puppet resource service puppet ensure=running enable=true
sudo puppet agent --test --debug --environment production
