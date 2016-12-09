require 'json'
require 'net/http'

Puppet::Type.type(:configure_pwh_connection).provide(:ruby) do

  def exists?
    return false    #TODO it will cause running PWH connection each time, even if this is already configured 
  end

  def create
    self.class.configure_pwh_connection(
      resource[:hostname],
      resource[:port],
      resource[:dbms],
      resource[:database],
      resource[:username],
      resource[:password]
    )
  end

  private

  def self.configure_pwh_connection(hostname, port, dbms, database, username, password)
    uri = URI('https://localhost:8021/rest/management/pwhconnection/config')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new("#{uri}", {'Accept' => 'application/json', 'Content-Type' => 'application/json'})
    request.basic_auth('admin', 'admin')
    request.body = { :host => hostname, :port => port, :dbms => dbms, :dbname => database, :user => username, :password => password, :usessl => false, :useurl => false, :url => nil }.to_json

    http.request(request)
  end
end
