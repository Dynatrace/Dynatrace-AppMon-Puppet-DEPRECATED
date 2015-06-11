require 'facter'

Facter.add(:collector_service_installed) do
  confine :kernel => 'Linux'
  setcode do
    return ::File.exist?('/etc/init.d/dynaTraceCollector')
  end
end
