require 'facter'

Facter.add(:server_service_installed) do
  confine :kernel => 'Linux'
  setcode do
    return ::File.exist?('/etc/init.d/dynaTraceServer')
  end
end
