require 'net/http'
require 'net/https'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_credentials

  def load_credentials
    @config = YAML::load(File.open("#{::Rails.root}/config/tradestation-webapi.yml"))
    @client_id = @config['client_id']
    @client_secret = @config['client_secret']
    @environment = @config['environment']
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

    store_request_response target

    return response.body
  end

  def https_post_with_body(target, body)
    uri = URI.parse(target)

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.path) 

    # Headers
    request["Authorization"] = @access_token
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request["Content-Length"] = body.to_json().length.to_s

    request.body = body.to_json()
    
    begin
     response = https.request(request)
    rescue Exception => e
     response = {:error => e.message, :exception => e.to_s, :body => "error"}
    end

    @request = request
    @response = response

    store_request_response target

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

   store_request_response target

   return response.body
  end

  def store_request_response(url)
    # This is just to document the request and response received by the API call
    @request_hash = JSON.parse(@request.to_json)
    @response_hash = JSON.parse(@response.to_json)

    @request_hash[:url] = url
    @response_hash[:http_code] = @response.code

    # for information purposes, create an array with the errors
    if @response.code.to_i() >= 400
      @error_array = Array.new
      @error_array[0] = JSON.parse(@response.body)
    end
  end

end
