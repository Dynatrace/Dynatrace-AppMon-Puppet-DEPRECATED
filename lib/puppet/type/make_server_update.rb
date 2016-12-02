Puppet::Type.newtype(:make_server_update) do
  desc "Puppet type that makes server update from .dtf file (in zip archive) using REST call."

  ensurable

  newparam(:update_file_path, :namevar => :true) do
  end

  newparam(:rest_update_url) do
  end
  
  newparam(:user) do
  end

  newparam(:passwd) do
  end
  
end
