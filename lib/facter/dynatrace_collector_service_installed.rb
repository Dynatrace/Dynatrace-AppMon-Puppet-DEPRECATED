require 'facter'

Facter.add(:dynatrace_collector_service_installed) do
  confine :kernel => "Linux"
  setcode do
    ::File.exist?('/etc/init.d/dynaTraceCollector')
  end
end
