require 'fileutils'
require 'net/http'
require 'uri'

require 'puppet'
require 'puppet/provider'

class Puppet::Provider::DynatraceInstaller < Puppet::Provider

  def exists?
    return ::File.exist?("#{resource[:installer_cache_dir]}/#{resource[:installer_file_name]}")
  end

  def create
    if !::File.exist?("#{resource[:installer_cache_dir]}")
      FileUtils.mkdir_p("#{resource[:installer_cache_dir]}")
    end

    installer_path = "#{resource[:installer_cache_dir]}/#{resource[:installer_file_name]}"

    if !::File.exist?(installer_path)
      if !resource[:installer_file_url].nil?
        uri = resource[:installer_file_url]

        if !self.class.download(uri, installer_path)
          Puppet.crit("Download of '#{uri}' failed.")
        end
      end
    end
  end

  def install
    self.create

    if !::File.exist?(resource[:installer_prefix_dir])
      FileUtils.mkdir_p(resource[:installer_prefix_dir])
      FileUtils.chown(resource[:installer_owner], resource[:installer_group], resource[:installer_prefix_dir])
    end

    install_path = "#{resource[:installer_prefix_dir]}/"
    install_path << execute("#{resource[:installer_cache_dir]}/#{resource[:installer_script_name]}").strip

    FileUtils.chown_R(resource[:installer_owner], resource[:installer_group], install_path)
    FileUtils.ln_s(install_path, "#{resource[:installer_prefix_dir]}/dynatrace", :force => true)
  end

  def destroy
    ::File.delete("#{resource[:installer_cache_dir]}/#{resource[:installer_file_name]}")
  end

  private

  def self.fetch(source, target, user = nil, pass = nil, use_ssl = false, limit = 10)
    raise ArgumentError, 'Too many HTTP redirects' if limit == 0
    uri = URI(source)
    http = Net::HTTP.new(uri.host, uri.port)
    begin
      if use_ssl or source.start_with? 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new uri.request_uri
      if nil != user and nil != pass
        request.basic_auth(user, pass)
      end
      http.request request do |response|
        case response
        when Net::HTTPRedirection then
          location = response['location']
          Puppet.notice("redirected to #{location}")
          fetch(location, limit - 1)
        when Net::HTTPForbidden then
          raise SecurityError, 'Access denied'
        when Net::HTTPNotFound then
          raise ArgumentError, 'Not found'
        when Net::HTTPSuccess then
          open target, 'wb' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        else
          raise "Unexpected state => #{response.code} - #{response.message}"
        end
      end
    rescue Net::HTTPError => e
      if nil != http and http.started?
        http.finish()
      end
      raise e
    end
  end

  def self.download(source, target)
    success = false
    for retries in 1..3
      begin
        fetch(source, target)
        success = true
        break
      rescue SecurityError => s
        Puppet.crit("SecurityError -> \n#{s.inspect}")
        break
      rescue ArgumentError => a
        Puppet.crit("ArgumentError -> \n#{a.inspect}")
        break
      rescue IOError => eio
        Puppet.crit("IO Exception during http download -> \n#{eio.inspect}")
      rescue Net::HTTPError => ehttp
        Puppet.crit("HTTP Exception during http download -> \n#{ehttp.inspect}")
      rescue StandardError => e
        Puppet.crit("Exception during http download -> \n#{e.inspect}")
      end
      sleep(5)
    end
    return success
  end

  def get_install_dir(installer_path); end
end