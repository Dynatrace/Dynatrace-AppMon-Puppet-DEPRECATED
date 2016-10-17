#require_relative '../dynatrace_installer'
require File.join(File.dirname(__FILE__), '../dynatrace_installer')


Puppet::Type.type(:dynatrace_installer).provide(:tar, :parent => Puppet::Provider::DynatraceInstaller) do
  desc "Puppet type that models a Dynatrace .tar file installer."

  def get_install_dir(installer_path)
    # extract the dynatrace.x.y.z directory name from the contained installer shell script
    install_dir = execute("tar -xf #{installer_path} && head -n 10 dynatrace*.sh | grep mkdir | cut -d ' ' -f 2").strip
    execute("rm -rf dynatrace-*.sh")
    
    #head: cannot open 'dynatrace*.sh' for reading: No such file or directory !!!!!
    if install_dir.start_with?( 'head: cannot open ')
      install_dir = '/opt/dynatrace/'
      puts "WARNING (get_install_dir): #{installer_path} tar file do not contain dynatrace*.sh script! Changed returned result to #{install_dir} !!!!!"
    end
    
    return install_dir
  end
end
