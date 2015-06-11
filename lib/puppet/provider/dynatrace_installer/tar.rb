require 'puppet/provider/dynatrace_installer'

Puppet::Type.type(:dynatrace_installer).provide(:tar, :parent => Puppet::Provider::DynatraceInstaller) do
  desc "Puppet type that models a Dynatrace .tar file installer."

  def get_install_dir(installer_path)
    # extract the dynatrace.x.y.z directory name from the contained installer shell script
    install_dir = execute("tar -xf #{installer_path} && head -n 10 dynatrace*.sh | grep mkdir | cut -d ' ' -f 2").strip
    execute("rm -rf dynatrace-*.sh")
    return install_dir
  end
end
