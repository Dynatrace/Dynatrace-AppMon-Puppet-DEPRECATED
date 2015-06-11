Puppet::Type.newtype(:dynatrace_installer) do
  desc "Puppet type that models a Dynatrace installer."

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:installed) do
      provider.install
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar => :true) do
  end

  newparam(:installer_prefix_dir) do
    defaultto '/opt'
  end

  newparam(:installer_file_name) do
  end

  newparam(:installer_file_url) do
  end

  newparam(:installer_script_name) do
  end

  newparam(:installer_owner) do
    defaultto 'dynatrace'
  end

  newparam(:installer_group) do
    defaultto 'dynatrace'
  end

  newparam(:installer_cache_dir) do
    defaultto '/tmp'
  end

end