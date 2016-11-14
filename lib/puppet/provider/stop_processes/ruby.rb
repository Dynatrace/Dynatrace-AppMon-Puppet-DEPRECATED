require 'fileutils'

Puppet::Type.type(:stop_processes).provide(:ruby) do
  def initialize(*args)
    super
    self.stop_all
  end

    
  class DynatraceTimeout < Timeout::Error; end

  def exists?
    return false
  end

  def create
    self.class.stop_processes(
      resource[:installer_owner],
      resource[:installer_group]
    )
  end

  def stop_all
    arr = resource[:services_to_stop]
    if arr.nil?
      list = nil
    else
      list = arr.split(/,/)
    end
    
    self.stop_processes(
      list,
      resource[:installer_owner],
      resource[:installer_group]
      )
  end

  
  def do_stop_processes(proc_pattern, proc_user, platform_family, timeout = 15, signal = 'TERM')
#    puts 'Execute do_stop_processes'
    pids = find_pids(proc_pattern, proc_user, platform_family)
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
  
  def find_pids(pattern, user, platform_family)
#    puts 'Execute find_pids'
    pids = []
    if %w(debian fedora rhel ubuntu).include? platform_family
      pgrep_pattern_opt = !pattern.nil? ? "-f \"#{pattern}\"" : ''
      pgrep_user_opt = !user.nil? ? "-u #{user}" : ''
      search_processes_cmd = "pgrep #{pgrep_pattern_opt} #{pgrep_user_opt}"
#      puts "cmd :  #{search_processes_cmd}"
  
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
      pgrepPid = $?.pid
#      puts "Execute find_pids #{pidStr}"
      unless pidStr.empty?
        text = []
        text << pidStr.lines.map(&:chomp)
        text.each do |x|
          x.each do |y|
            pids << y.to_i unless y.to_i == pgrepPid 
          end
        end
      end 
      #################################################################
  
    else
      raise 'ERROR: Unsupported platform'
    end
    pids
  end
  
  def stop_processes(services_to_stop, installer_owner, installer_group)
#    puts "stop_processes"
#    puts "Execute stop_processes user=#{resource[:installer_owner]}"

    services  = [
      'dtserver', 
      'dtfrontendserver',
      'dthostagent',
      'dtcollector',
      
      'dynaTraceServer',
      'dynaTraceCollector',
      'dynaTraceAnalysis',
      'dynaTraceWebServerAgent',
      'dynaTraceHostagent',
      'dynaTraceFrontendServer',
      'dynaTraceBackendServer',
      
    ]

    stop_processes_kill_type(services, installer_owner, installer_group, 'TERM')
    if not services_to_stop.nil?
      stop_processes_kill_type(services_to_stop, installer_owner, installer_group, 'TERM')
    else
      puts 'Additional services to stop are empty.'
    end

    stop_processes_kill_type(services, installer_owner, installer_group, 'KILL')
    if not services_to_stop.nil?
      stop_processes_kill_type(services_to_stop, installer_owner, installer_group, 'KILL')
    end
  end

  def stop_processes_kill_type(services, installer_owner, installer_group, kill_type)
#    puts "Execute stop_processes user=#{resource[:installer_owner]}"

    if not services.nil?
      services.each {
        |x| 
#        print x, " -- " 
        do_stop_processes(x, nil, 'rhel', 500, kill_type)
      }
    end

    do_stop_processes('dynaTraceServer', "#{resource[:installer_owner]}", 'rhel', 5, kill_type)
    do_stop_processes(nil, "#{resource[:installer_owner]}", 'rhel', 500, kill_type)
  end
end


