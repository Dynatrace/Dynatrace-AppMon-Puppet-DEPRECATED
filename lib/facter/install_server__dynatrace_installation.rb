Facter.add(:install_server__dynatrace_installation) do
  setcode do
    result_string = 'not there'
    myfile = '/tmp/dynatrace_server_installation.info'
    if File.exists?(myfile)
      text=File.open(myfile).read
      text.gsub!(/\r\n?/, "\n")
      text.each_line do |line|
        line_noend = line.gsub(/\s+/, ',')
        #check if this step of manifest should be executed...
        if line_noend.include? "dynatrace_installation"
          key = line_noend.split(/=/).first
          value = line_noend.split(/=/).last
          value = value.gsub(/,/, '')                       #'/opt/dynatrace/server'
          #check if file from 'value' exists
          if File.exists?(value)
            result_string = 'there'
          end
#          puts "#############!!!!!! key=#{key}  value=#{value}   result_string=#{result_string}"
        end
      end
      result_string
    else
      'not there'
    end
  end
end