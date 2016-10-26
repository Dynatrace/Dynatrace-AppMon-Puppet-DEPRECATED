Puppet::Type.newtype(:make_server_update) do
  desc "Puppet type that makes server update from .dtf file using REST call."

  ensurable

  newparam(:update_file_path, :namevar => :true) do
#    defaultto ''
  end

  newparam(:rest_update_url) do
#    defaultto ''
  end
  
  newparam(:rest_update_status_url) do
#    defaultto ''
  end

  newparam(:user) do
#    defaultto ''
  end

  newparam(:passwd) do
#    defaultto ''
  end
  
end
