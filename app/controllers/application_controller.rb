require 'net/http'
require 'net/https'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_credentials

  def load_credentials
    @client_id = '00000000-0000-0000-0000-000000000000'
    @client_secret = '00000000-0000-0000-0000-000000000000'
    @environment = 'https://staging.api.tradestation.com/v2'
  end

  def https_post(target, form_data)
    uri = URI.parse(target)

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.path) 

    # Headers
    request["Content-Type"] = "application/x-www-form-urlencoded"

    request.set_form_data(form_data)
    
    begin
     response = https.request(request)
    rescue Exception => e
     response = {:error => e.message, :exception => e.to_s, :body => "error"}
    end

    @request = request
    @response = response

    return response.body
  end

  def https_get(target)
   uri = URI.parse(target)

   https = Net::HTTP.new(uri.host, uri.port)
   https.use_ssl = true
   https.verify_mode = OpenSSL::SSL::VERIFY_NONE

   request = Net::HTTP::Get.new(uri.request_uri)

    # Headers
   request["Authorization"] = @access_token
   request["Accept"] = "application/json"

   begin
     response = https.request(request)
   rescue Exception => e
     response = {:error => e.message, :exception => e.to_s, :body => "error"}
   end
   
   @request = request
   @response = response

   return response.body
  end

end
