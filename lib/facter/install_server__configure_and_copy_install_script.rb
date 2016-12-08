Facter.add(:install_server__configure_and_copy_install_script) do
  setcode do
    if File.exists?('/opt/puppetlabs/puppet/cache/dynatrace/install-server.sh')
       'there'
    else
       'not there'
    end
  end
end