Facter.add(:install_server__check_service) do
  confine :kernel => 'Linux'
  setcode do
    
    pids = []
    pattern = 'dtserver'
    pgrep_pattern_opt = "-f \"#{pattern}\""
    search_processes_cmd = "pgrep #{pgrep_pattern_opt}"
#    puts "cmd :  #{search_processes_cmd}"

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
#    puts "Execute find_pids #{pidStr}"
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
    
    if pids.length > 0
       'there'
    else
       'not there'
    end
  end
end
