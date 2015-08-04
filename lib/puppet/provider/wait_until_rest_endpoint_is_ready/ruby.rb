require 'open-uri'
require 'timeout'

Puppet::Type.type(:wait_until_rest_endpoint_is_ready).provide(:ruby) do

  class DynatraceTimeout < Timeout::Error; end

  class DynatraceNotReady < StandardError
    def initialize(endpoint, timeout)
      super <<-EOH
The Dynatrace Server at `#{endpoint}' did not become ready within #{timeout} seconds.
Possibly, Dynatrace has failed to start. Please check your Dynatrace Server log files.
EOH
    end
  end

  def exists?
    return self.class.rest_endpoint_is_available?(resource[:address])
  end

  def create
    self.class.wait_until_rest_endpoint_is_ready(resource[:timeout], resource[:address])
  end

  private

  def self.rest_endpoint_is_available?(address)
    begin
      open(address)
    rescue SocketError,
           Errno::ECONNREFUSED,
           Errno::ECONNRESET,
           Errno::ENETUNREACH,
           Timeout::Error,
           OpenURI::HTTPError => e
      return e.message !=~ /^(401|403)/
    end

    return true
  end

  def self.wait_until_rest_endpoint_is_ready(timeout, address)
    Timeout.timeout(timeout, DynatraceTimeout) do
      while !self.rest_endpoint_is_available?(address) do
        Puppet.crit "waiting for rest endpoint"
        sleep(1)
      end
    end
  rescue DynatraceTimeout
    raise DynatraceNotReady.new(address, timeout)
  end
end
