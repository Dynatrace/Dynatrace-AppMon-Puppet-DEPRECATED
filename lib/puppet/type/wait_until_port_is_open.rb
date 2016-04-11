Puppet::Type.newtype(:wait_until_port_is_open) do
  desc "Puppet type that waits until a particular port is available at a particular IP address."

  ensurable

  newparam(:port, :namevar => :true) do
  end

  newparam(:ip) do
    defaultto '127.0.0.1'
  end

  newparam(:timeout) do
    defaultto 360
  end

end