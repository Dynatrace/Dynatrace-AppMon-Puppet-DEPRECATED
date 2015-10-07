Puppet::Type.newtype(:configure_pwh_connection) do
  desc "Puppet type that configure's the Dynatrace Server's connection with a Performance Warehouse Database."

  ensurable

  newparam(:dbms, :namevar => :true) do
  end

  newparam(:hostname) do
  end

  newparam(:port) do
  end

  newparam(:database) do
  end

  newparam(:username) do
  end

  newparam(:password) do
  end

end
