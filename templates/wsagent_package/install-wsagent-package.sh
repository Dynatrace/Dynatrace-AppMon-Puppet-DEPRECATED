#!/bin/sh
cd <%= @installer_prefix_dir %>

# extract the installer
tar -xf <%= @installer_cache_dir %>/<%= @installer_file_name %> > /dev/null

# look for the actual installation path part, e.g. 'dynatrace-6.x'
install_dir=`head -n 10 dynatrace*.sh | grep mkdir | cut -d ' ' -f 2`

# run the installer and capture its exit status
sh dynatrace-*.sh > /dev/null
result=$?

# remove temporary artefacts
rm -f dynatrace*.sh

echo $install_dir
exit $result
