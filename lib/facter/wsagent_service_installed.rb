require 'facter'

Facter.add(:wsagent_service_installed) do
  confine :kernel => 'Linux'
  setcode do
    return ::File.exist?('/etc/init.d/dynaTraceWebServerAgent')
  end
end
