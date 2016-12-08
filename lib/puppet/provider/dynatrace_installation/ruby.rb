require 'fileutils'
#require 'stop_processes'

Puppet::Type.type(:dynatrace_installation).provide(:ruby) do
  def initialize(*args)
    super
    @requires_installation = nil
  end

  class DynatraceTimeout < Timeout::Error; end

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
  
    puts 'Execute uninstall'
    
    #TODO    
    stop_processes::stop_all
        
    execute("rm -f /etc/init.d/dynaTrace*");
  
    puts "Cache directory=#{resource[:installer_cache_dir]}"
    if ::File.directory?("#{resource[:installer_cache_dir]}")
      puts "Delete cache directory=#{resource[:installer_cache_dir]}"
      FileUtils.rm_rf("#{resource[:installer_cache_dir]}")
    end
  
    symlink = "#{resource[:installer_prefix_dir]}/dynatrace"
    if ::File.symlink?(symlink)
      puts "Symlink=#{symlink}"
      target = ::File.readlink(symlink)
      puts "Target directory=#{target}"

#      puts "Delete symlink=#{symlink}"
#      ::File.delete(symlink)
#      
#      if target
#        puts "Delete target directory=#{target}"
#        ::File.delete(target)
#        puts "Deleted target directory=#{target}"
#      end
    else
      puts "Symlink=#{symlink} not found."
      installer_install_dir = @installer.get_install_dir("#{resource[:installer_cache_dir]}/#{resource[:installer_file_name]}")
      @installer.destroy if @installer.exists?
  
      target = "#{resource[:installer_prefix_dir]}/#{installer_install_dir}"
      puts "Target directory=#{target}"
#      if ::File.directory?(target)
#        puts "Delete target directory=#{target}"
#        FileUtils.rm_rf(target)
#        puts "Deleted target directory=#{target}"
#      end
    end
  end

  def uninstalled
    self.uninstall
  end

  protected

  def requires_installation?
    return @requires_installation if !@requires_installation.nil?
  
    self.initialize_installer
    @installer.create if !@installer.exists?
  
    alter_path = "#{resource[:installer_path_detailed]}"
    
    if alter_path.to_s.strip.length > 0
      #for installer_path_part=agent there have to be extension because when there is already 'agent' folder then reqires_installation is false
      installer_path_to_check = alter_path
    else
      installer_install_dir = @installer.get_install_dir("#{resource[:installer_cache_dir]}/#{resource[:installer_file_name]}")
      installer_path_to_check = "#{resource[:installer_prefix_dir]}/#{installer_install_dir}/#{resource[:installer_path_part]}"
    end
  
    @requires_installation = !::File.exist?(installer_path_to_check)
  
    puts "Checking if requires installation for path: #{installer_path_to_check}. Result: #{@requires_installation}, ensure= #{resource[:ensure]}"
  
    return @requires_installation
  end

end


