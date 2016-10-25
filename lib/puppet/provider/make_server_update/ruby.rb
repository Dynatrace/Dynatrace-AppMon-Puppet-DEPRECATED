require 'fileutils'
require 'net/https'
require 'rexml/document'
require 'net/http/post/multipart'

Puppet::Type.type(:make_server_update).provide(:ruby) do

  def exists?
    return false
  end

  def create
    self.class.make_server_update(
      resource[:update_file_path],
      resource[:rest_update_url],
      resource[:rest_update_status_url],
      resource[:user],
      resource[:passwd]
    )
  end

  class DynatraceTimeout < Timeout::Error; end

  private
  def self.make_server_update(update_file_path, rest_update_url, rest_update_status_url, user, passwd)

    puts "Making AppMon Server update process using REST URL=#{rest_update_url}"    
    jobid = nil
    
    uri = URI(rest_update_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    File.open(update_file_path) do |update_file|
      request = Net::HTTP::Post::Multipart.new uri.path, 'file' => UploadIO.new(update_file, 'application/octet-stream')
      request.basic_auth(user, passwd)
      response = http.request(request)

      raise "Server responded with error '#{response.code} #{response.message}' when trying to upload file #{update_file_path} through REST" unless response.code.to_s == '201'

      jobid = response['location'].split(%r{/})[-1]
      puts "Server update jobid=#{jobid}"    
    end
    
    begin
      loop do
        current_rest_update_status_url = "#{rest_update_status_url}/#{jobid}"
        uri = URI(current_rest_update_status_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        puts "Checking the progress of AppMon running update process using REST URL=#{current_rest_update_status_url}"
        
        request = Net::HTTP::Get.new(uri.path, 'Accept' => 'application/xml')
        request.basic_auth(user, passwd)
        response = http.request(request)

        puts "Server responded with code '#{response.code} #{response.message}' when trying to check update status..."

        if response.code == '200'
          begin
            xmldoc = REXML::Document.new(response.body)
            isfinished = REXML::XPath.first(xmldoc, '//isfinished').first == 'true'
            if isfinished
              isrestartrequired = REXML::XPath.first(xmldoc, '//isserverrestartrequired').first == 'true'
              puts "Update finished."
              break
            else
              puts "Update not finished. Waiting for server..."
              sleep 5
            end
          end
        else
          puts "Waiting for server..."    
          sleep 5
        end
      end
    end
  end
end

