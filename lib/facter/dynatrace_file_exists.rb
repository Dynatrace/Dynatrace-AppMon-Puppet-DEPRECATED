require"puppet"
  module Puppet::Parser::Functions
    newfunction(:dynatrace_file_exists, :type => :rvalue) do |args|
    file_to_check = '/opt/dynatrace'
    if File.exists?(file_to_check) || File.symlink?(file_to_check)
      puts "File #{file_to_check} exists."
      return 1
    else
      puts "File #{file_to_check} do not exists."
      return 0
    end
  end
end


require"puppet"
  module Puppet::Parser::Functions
    newfunction(:dynatrace_file_exists_param, :type => :rvalue) do |args|
    if File.exists?(args[0]) || File.symlink?(args[0])
      return 1
    else
      return 0
    end
  end
end


require"puppet"
  module Puppet::Parser::Functions
    newfunction(:stop_processes, :type => :rvalue) do |args|
      proc_pattern = args[0]
      proc_user = args[1]
      platform_family = args[2]
      timeout = args[4] 
      signal = args[5]
      pids = find_pids(proc_pattern, proc_user, platform_family)
      killed = false
      unless pids.empty?
        Process.kill signal, *pids
        # TODO! when process does not exit anymore exception is thrown Errno::ESRCH No such process
        begin
          Timeout.timeout(timeout, DynatraceTimeout) do
            loop do
              pids = find_pids(proc_pattern, proc_user, platform_family)
              if pids.empty?
                # puts("Process(es) #{pids} terminated")
                killed = true
                break
              end
              # puts("Waiting for process(es) #{pids} to finish")
              sleep 1
            end
          end
        rescue DynatraceTimeout
          raise "Process(es) #{pids} did not stop"
        end
      end
      killed
    end
end

require"puppet"
  module Puppet::Parser::Functions
    newfunction(:find_pids, :type => :rvalue) do |args|
      pattern = args[0]
      user    = args[1]
      platform_family = args[2]
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
end

require"puppet"
  module Puppet::Parser::Functions
    newfunction(:dynatrace_clean_agent, :type => :rvalue) do |args|
      puts "dynatrace_clean_agent user=#{resource[:installer_owner]}"
      
      #this should stop any dynaTraceServer process on agent node
      stop_processes('dynaTraceServer', "#{resource[:installer_owner]}", 'rhel', 5, 'TERM')
      
      #Stop any running instance of dynatrace service: dtserver
      stop_processes('dtserver', nil, 'rhel', 5, 'TERM')

      #Stop any running instance of dynatrace service: dtfrontendserver
      stop_processes('dtfrontendserver', nil, 'rhel', 5, 'TERM')
      
      #this should stop any dynatrace user process on agent node
      #stop_processes(nil, "#{resource[:installer_owner]}", 'rhel', 5, 'TERM')
    return 1
  end
end
