Puppet::Type.newtype(:wait_until_rest_endpoint_is_ready) do
  desc "Puppet type that waits until a particular REST endpoing is available."

  ensurable

  newparam(:address, :namevar => :true) do
  end

  newparam(:timeout) do
    defaultto 360
  end

end