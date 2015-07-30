require 'facter'

Facter.add(:dynatrace_server_service_installed) do
  confine :kernel => "Linux"
  setcode do
    ::File.exist?('/etc/init.d/dynaTraceServer')
  end
end
