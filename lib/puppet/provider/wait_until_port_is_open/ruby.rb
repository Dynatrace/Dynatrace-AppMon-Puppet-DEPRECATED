require 'net/http'
require 'socket'
require 'timeout'

Puppet::Type.type(:wait_until_port_is_open).provide(:ruby) do

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
    return self.class.port_is_open?(resource[:ip], resource[:port])
  end

  def create
    self.class.wait_until_port_is_open(resource[:timeout], resource[:ip], resource[:port])
  end

  private

  def self.port_is_open?(ip, port)
    s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    sa = Socket.sockaddr_in(port, ip)

    begin
      s.connect_nonblock(sa)
      return true
    #rescue IO::WaitWritable
    rescue
      if IO.select(nil, [s], nil, 1)
        begin
          s.connect_nonblock(sa)
          return true
        rescue Errno::EISCONN
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        ensure
          s.close if !s.closed?
        end
      end
    end

    s.close if !s.closed?
    return false
  end

  def self.wait_until_port_is_open(timeout, ip, port)
    Timeout.timeout(timeout, DynatraceTimeout) do
      while !self.port_is_open?(ip, port) do
        sleep(1)
      end
    end
  rescue DynatraceTimeout
    raise DynatraceNotReady.new("#{ip}:#{port}", timeout)
  end
end
