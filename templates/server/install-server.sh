#!/bin/sh
cd <%= @installer_prefix_dir %>

# run the installer, capture its STDOUT and exit status
installer_output=`java -jar <%= @installer_cache_dir %>/<%= @installer_file_name %> -b <%= @installer_bitsize %> -y`
result=$?

# fetch an arbitrary init script name from the installer STDOUT
init_script=`echo "$installer_output" | grep -e 'init.d' | tail -n 1`

# look for the actual installation path part, e.g. 'dynatrace-6.x'
install_dir=`echo "$init_script" | awk -F"'" '{ print $2 }' | awk -F'/' '{ print $(NF-2) }'`

echo $install_dir
exit $result
