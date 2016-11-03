require 'fileutils'

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
  
  def stop_processes(proc_pattern, proc_user, platform_family, timeout = 15, signal = 'TERM')
    pids = find_pids(proc_pattern, proc_user, platform_family)
    # puts "Process(es) to kill: #{pids}"
    killed = false
    unless pids.empty?
      until pids.empty?
        begin
          Process.kill signal, *pids
          break
        rescue Errno::ESRCH
          # The process could have terminated by itself. Retry to find processes matching search pattern.
          # puts "No such process(es): #{pids}. Retrying search pattern..."
          pids = find_pids(proc_pattern, proc_user, platform_family)
        end
      end
      begin
        Timeout.timeout(timeout, DynatraceTimeout) do
          loop do
            pids = find_pids(proc_pattern, proc_user, platform_family)
            if pids.empty?
              # puts "Terminated process(es)"
              killed = true
              break
            end
            # puts "Waiting for process(es) #{pids} to finish"
            sleep 1
          end
        end
      rescue DynatraceTimeout
        raise "Process(es) #{pids} did not stop"
      end
    end
    killed
  end
  
  # private_class_method
  def find_pids(pattern, user, platform_family)
    pids = []
    if %w(debian fedora rhel).include? platform_family
      pgrep_pattern_opt = !pattern.nil? ? "-f \"#{pattern}\"" : ''
      pgrep_user_opt = !user.nil? ? "-u #{user}" : ''
      search_processes_cmd = "pgrep #{pgrep_pattern_opt} #{pgrep_user_opt}"
  
      #################################################################
      # code below doesn't work if workstation is on windows
      #        %x[#{search_processes_cmd}].each_line do |pidStr|
      #          if !pidStr.empty?
      #            puts 'pid:' + pidStr
      #            pids << pidStr.to_i
      #          end
      #          return pids
      #        end
      # this part working and fixes code above
      pidStr = `#{search_processes_cmd}`
      unless pidStr.empty?
        text = []
        text << pidStr.lines.map(&:chomp)
        text.each do |x|
          x.each do |y|
            pids << y.to_i
          end
        end
      end
      #################################################################
  
    else
      raise 'ERROR: Unsupported platform'
    end
    pids
  end
  
  def uninstall
    self.initialize_installer
  
    puts 'Execute uninstall'
    puts "dynatrace_clean_agent user=#{resource[:installer_owner]}"

#    $service = 'dynaTraceServer'
#    $collectorService = 'dynaTraceCollector'
#    $dynaTraceAnalysis = 'dynaTraceAnalysis'
#    $dynaTraceWebServerAgent = 'dynaTraceWebServerAgent'
#    $dynaTraceHostagent = 'dynaTraceHostagent'
    
      
    #this should stop any dynaTraceServer process on agent node
    stop_processes('dynaTraceServer', "#{resource[:installer_owner]}", 'rhel', 5, 'TERM')
  
    #Stop any running instance of dynatrace service: dtserver
    stop_processes('dtserver', nil, 'rhel', 5, 'TERM')
  
    #Stop any running instance of dynatrace service: dtfrontendserver
    stop_processes('dtfrontendserver', nil, 'rhel', 5, 'TERM')
  
    #this should stop any dynatrace user process on agent node
    stop_processes(nil, "#{resource[:installer_owner]}", 'rhel', 5, 'TERM')
  
    stop_processes('dynaTraceServer', nil, 'rhel', 5, 'TERM')
    stop_processes('dynaTraceCollector', nil, 'rhel', 5, 'TERM')
    stop_processes('dynaTraceAnalysis', nil, 'rhel', 5, 'TERM')
    stop_processes('dynaTraceWebServerAgent', nil, 'rhel', 5, 'TERM')
    stop_processes('dynaTraceHostagent', nil, 'rhel', 5, 'TERM')
    
  
    #this should stop any dynaTraceServer process on agent node
    stop_processes('dynaTraceServer', "#{resource[:installer_owner]}", 'rhel', 5, 'KILL')
  
    #Stop any running instance of dynatrace service: dtserver
    stop_processes('dtserver', nil, 'rhel', 5, 'KILL')
  
    #Stop any running instance of dynatrace service: dtfrontendserver
    stop_processes('dtfrontendserver', nil, 'rhel', 5, 'KILL')

    stop_processes('dynaTraceServer', nil, 'rhel', 5, 'KILL')
    stop_processes('dynaTraceCollector', nil, 'rhel', 5, 'KILL')
    stop_processes('dynaTraceAnalysis', nil, 'rhel', 5, 'KILL')
    stop_processes('dynaTraceWebServerAgent', nil, 'rhel', 5, 'KILL')
    stop_processes('dynaTraceHostagent', nil, 'rhel', 5, 'KILL')
    
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
  
    installer_install_dir = @installer.get_install_dir("#{resource[:installer_cache_dir]}/#{resource[:installer_file_name]}")
    installer_path_to_check = "#{resource[:installer_prefix_dir]}/#{installer_install_dir}/#{resource[:installer_path_part]}"
    alter_path = "#{resource[:installer_path_detailed]}"
    if alter_path.to_s.strip.length > 0
      #for installer_path_part=agent there have to be extension because when there is already 'agent' folder then reqires_installation is false
      installer_path_to_check = alter_path
    end
  
    @requires_installation = !::File.exist?(installer_path_to_check)
  
    puts "Checking if requires installation: #{@requires_installation}, for path: #{installer_path_to_check}."
  
    return @requires_installation
  end

end


