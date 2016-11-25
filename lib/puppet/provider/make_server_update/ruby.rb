require 'fileutils'
require 'net/https'
require 'rexml/document'
require 'net/http/post/multipart'
require 'uri'
require 'find'

Puppet::Type.type(:make_server_update).provide(:ruby) do

  def exists?
    return false
  end

  def create
    self.class.make_server_update(
      resource[:update_file_path],
      resource[:rest_update_url],
      resource[:user],
      resource[:passwd]
    )
  end

  class DynatraceTimeout < Timeout::Error; end

  private
  def self.make_server_update(update_file_path, rest_update_url, user, passwd)

    full_rest_update_url = "#{rest_update_url}installjobs"
    puts "Start AppMon Server update process using REST URL=#{full_rest_update_url}"    
    jobid = nil
    uri = URI("#{full_rest_update_url}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    dtf_file_paths = []
    Find.find("#{update_file_path}/server_update/") do |path|
      dtf_file_paths << path if path =~ /.*\.dtf$/
    end
    
    dtf_file_paths.each { |dtf_file| 
      puts 'Update file: ' + dtf_file
      
      File.open(dtf_file) do |update_file|
        puts "Uploading file #{dtf_file} through REST"
        request = Net::HTTP::Post::Multipart.new uri.path, 'file' => UploadIO.new(update_file, 'application/octet-stream')
        request.basic_auth(user, passwd)
        response = http.request(request)

        raise "Server responded with error '#{response.code} #{response.message}' when trying to upload file #{update_file_path} through REST" unless response.code.to_s == '201'

        jobid = response['location'].split(%r{/})[-1]
        puts "Server update jobid=#{jobid}"    
      end
      
      begin
        loop do
          current_rest_update_status_url = "#{rest_update_url}installjobs/#{jobid}"
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
                sleep 10
              end
            end
          else
            puts "Waiting for server..."    
            sleep 10
          end
        end
      end
    }

#    #TODO Restarting agents
#    'dynaTraceAnalysis'
#    'dynaTraceWebServerAgent'
#    'dynaTraceHostagent'
    
    # Restarting collectors    
    begin
      get_collectors_url = "#{rest_update_url}collectors"
      uri = URI(get_collectors_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      puts "Getting collectors list using REST URL=#{get_collectors_url}"
      
      request = Net::HTTP::Get.new(uri.path, 'Accept' => 'text/xml')
      request.basic_auth(user, passwd)
      response = http.request(request)

      puts "Server responded with code '#{response.code} #{response.message}' when trying to get collectors list..."

      if response.code == '200'
        begin
          xmldoc = REXML::Document.new(response.body)
          xmldoc.elements.each('collectors/collectorinformation/name') do |collector_name| 
            collector_txt = collector_name.text
            url_to_collector_restart = "#{rest_update_url}collector/#{URI.encode(collector_txt)}/restart"
            puts "Restarting the collector '#{collector_txt}' using REST URL=#{url_to_collector_restart}"
            
            uri = URI(url_to_collector_restart)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
            request = Net::HTTP::Post.new(uri.path, 'Accept' => 'application/xml')
            request.basic_auth(user, passwd)
            response = http.request(request)
          end
                    
        end
      end
    end
    
    
    # Restarting server
    restart_url = "#{rest_update_url}server/restart"
    uri = URI(restart_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    puts "Restarting the server using REST URL=#{restart_url}"
    
    request = Net::HTTP::Post.new(uri.path, 'Accept' => 'application/xml')
    request.basic_auth(user, passwd)
    response = http.request(request)

    puts "Server responded with code '#{response.code} #{response.message}' when restarting..."
    puts "Waiting for server..."
    sleep 10
    puts "Server is restarting..."
    
  end
end
