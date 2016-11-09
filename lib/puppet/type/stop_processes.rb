Puppet::Type.newtype(:stop_processes) do
  desc "Puppet type that models a stop Dynatrace services."

#  ensurable
#  
  newparam(:installer_owner, :namevar => :true) do
    defaultto 'dynatrace'
  end

  newparam(:installer_group) do
    defaultto 'dynatrace'
  end

  newparam(:services_to_stop) do
    defaultto ''
  end

end

