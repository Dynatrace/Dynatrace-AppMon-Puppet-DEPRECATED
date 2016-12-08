Facter.add(:install_server__dynatrace_installation) do
  setcode do
    if File.exists?('/opt/dynatrace/server')
       'there'
    else
       'not there'
    end
  end
end