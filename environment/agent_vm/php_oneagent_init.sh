#!/bin/bash -e

INI_FILE=${INI_FILE:-"/etc/php/7.0/apache2/php.ini"}
PHP_LOADER_PATH_PARAM=${PHP_LOADER_PATH_PARAM:-"extension = /opt/dynatrace-7.0/agent/bin/linux-x86-64/liboneagentloader.so"}
PHPAGENT_SERVER_PARAM=${PHPAGENT_SERVER_PARAM:-"phpagent.server = https://localhost:8043"}
PHPAGENT_NAME_PARAM=${PHPAGENT_NAME_PARAM:-"phpagent.agentname = phpOneAgent"}
PHPAGENT_TENANT_PARAM=${PHPAGENT_TENANT_PARAM:-"phpagent.tenant = 1"}

sudo apt-get -y install apache2
sudo apt-get -y install php libapache2-mod-php

if ! grep -q "$PHP_LOADER_PATH_PARAM" "$INI_FILE"; then
  echo $PHP_LOADER_PATH_PARAM | sudo tee -a $INI_FILE
fi

if ! grep -q "$PHPAGENT_SERVER_PARAM" "$INI_FILE"; then
  echo $PHPAGENT_SERVER_PARAM | sudo tee -a $INI_FILE
fi

if ! grep -q "$PHPAGENT_NAME_PARAM" "$INI_FILE"; then
  echo $PHPAGENT_NAME_PARAM | sudo tee -a $INI_FILE
fi

if ! grep -q "$PHPAGENT_TENANT_PARAM" "$INI_FILE"; then
  echo $PHPAGENT_TENANT_PARAM | sudo tee -a $INI_FILE
fi

sudo systemctl restart apache2
