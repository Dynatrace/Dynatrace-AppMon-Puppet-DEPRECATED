Facter.add(:install_server__copy_or_download) do
  setcode do
    if File.exists?('/opt/puppetlabs/puppet/cache/dynatrace/dynatrace.jar')
       'there'
    else
       'not there'
    end
  end
end