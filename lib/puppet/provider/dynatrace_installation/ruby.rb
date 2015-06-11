Puppet::Type.type(:dynatrace_installation).provide(:ruby) do
  def initialize(*args)
    super
    @requires_installation = nil
  end

  def initialize_installer
    return if !@installer.nil?

    if resource[:installer_file_name].end_with?('.jar')
      provider = 'jar'
    elsif resource[:installer_file_name].end_with?('.tar')
      provider = 'tar'
    end

    parameters = Hash[resource.parameters.keys.map{ |name|
      [name, self.resource[name]]
    }]
    parameters[:provider] = provider

    @installer = Puppet::Type.type(:dynatrace_installer).provider(provider).new(parameters)
    @installer.resource = parameters
  end

  def exists?
    return requires_installation?
  end

  def install
    self.initialize_installer
    @installer.create if !@installer.exists?

    if self.requires_installation?
      @installer.install
    end
  end

  def uninstall
    self.initialize_installer
    @installer.destroy if @installer.exists?

    symlink = "#{resource[:installer_prefix_dir]}/dynatrace"
    if ::File.symlink?(symlink)
      target = ::File.readlink(symlink)
      if target
        ::File.delete(symlink)
        ::File.delete(target)
      end
    end
  end

  protected

  def requires_installation?
    return @requires_installation if !@requires_installation.nil?

    self.initialize_installer
    @installer.create if !@installer.exists?

    installer_install_dir = @installer.get_install_dir("#{resource[:installer_cache_dir]}/#{resource[:installer_file_name]}")
    installer_path_to_check = "#{resource[:installer_prefix_dir]}/#{installer_install_dir}/#{resource[:installer_path_part]}"
    
    @requires_installation = !::File.exist?(installer_path_to_check)
    return @requires_installation
  end
end
