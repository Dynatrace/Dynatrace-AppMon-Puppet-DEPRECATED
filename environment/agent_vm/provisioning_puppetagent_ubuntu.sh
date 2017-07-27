#!/bin/sh
export DEBIAN_FRONTEND="noninteractive" #to avoid error message: dpkg-reconfigure: unable to re-open stdin: No file or directory
CONF_FILE=${CONF_FILE:-"/etc/hosts"}
SERVER_HOST="172.18.131.23   puppetserver     puppetserver.clients.dynatrace.org"
LOCAL_HOST="127.0.1.1       puppetagent    puppetagent.clients.dynatrace.org"

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install openjdk-8-jdk

#following commands require reboot after the script is done
sudo /etc/init.d/apparmor stop
sudo update-rc.d -f apparmor remove
sudo apt-get -y remove --auto-remove apparmor apparmor-utils

if ! grep -q "$SERVER_HOST" "$CONF_FILE"; then
  echo $SERVER_HOST | sudo tee -a $CONF_FILE
fi
if ! grep -q "$LOCAL_HOST" "$CONF_FILE"; then
  echo $LOCAL_HOST | sudo tee -a $CONF_FILE
fi

sudo hostnamectl set-hostname puppetagent --static
echo "preserve_hostname: true" | sudo tee -a /etc/cloud/cloud.cfg

#needs vagrant reload
