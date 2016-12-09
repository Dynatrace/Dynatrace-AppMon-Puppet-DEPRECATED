Facter.add(:install_server__configure_and_copy_install_script) do
  setcode do
    result_string = 'not there'
    myfile = '/tmp/dynatrace_server_installation.info'
    if File.exists?(myfile)
      text=File.open(myfile).read
      text.gsub!(/\r\n?/, "\n")
      text.each_line do |line|
        line_noend = line.gsub(/\s+/, ',')
        #check if this step of manifest should be executed...
        if line_noend.include? "file_configure_and_copy_install_script"
          key = line_noend.split(/=/).first
          value = line_noend.split(/=/).last
          value = value.gsub(/,/, '')                       #'/opt/puppetlabs/puppet/cache/dynatrace/install-server.sh'
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