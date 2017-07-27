#!/bin/sh
export DEBIAN_FRONTEND="noninteractive" #to avoid error message: dpkg-reconfigure: unable to re-open stdin: No file or directory
CONF_FILE="/etc/hosts"
AGENT_HOST="172.18.131.21   puppetagent     puppetagent.clients.dynatrace.org"
LOCAL_HOST="127.0.1.1       puppetserver    puppetserver.clients.dynatrace.org"

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install git

#following commands require vagrant reload after the script is done and VM is up
sudo /etc/init.d/apparmor stop
sudo update-rc.d -f apparmor remove
sudo apt-get -y remove --auto-remove apparmor apparmor-utils

if ! grep -q "$AGENT_HOST" "$CONF_FILE"; then
  echo $AGENT_HOST | sudo tee -a $CONF_FILE
fi
if ! grep -q "$LOCAL_HOST" "$CONF_FILE"; then
  echo $LOCAL_HOST | sudo tee -a $CONF_FILE
fi

sudo hostnamectl set-hostname puppetserver --static
echo "preserve_hostname: true" | sudo tee -a /etc/cloud/cloud.cfg

sudo apt-get -y install puppetserver

#manually run vagrant reload
