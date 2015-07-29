require 'facter'

Facter.add(:dynatrace_wsagent_service_installed) do
  confine :kernel => "Linux"
  setcode do
    ::File.exist?('/etc/init.d/dynaTraceWebServerAgent')
  end
end
