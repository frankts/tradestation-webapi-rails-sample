class SampleController < ApplicationController
  before_filter :authenticate

  def index
  end

  def account_list
    @target_url = "#{@environment}/users/#{@userid}/accounts"
    https_get(@target_url)

    @request_hash = JSON.parse(@request.to_json)
    @response_hash = JSON.parse(@response.to_json)
    @result_array = JSON.parse(@response.body).to_a

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { 'Name' => "error", 'response' => @response.body }
    end
  end

  def account_balances
    @target_url = "#{@environment}/accounts/#{params[:account_key]}/balances"
    https_get(@target_url)

    @request_hash = JSON.parse(@request.to_json)
    @response_hash = JSON.parse(@response.to_json)
    @result_hash = JSON.parse(@response.body).to_a[0]

    debugger

    # Display an error if there are no results returned
    if @result_hash.size == 0
      @result_hash = { 'Name' => "error", 'response' => @response.body }
    end
  end

  def account_positions

  end

  def account_orders
    @target_url = "#{@environment}/accounts/#{params[:account_key]}/orders"
    https_get(@target_url)

    @request_hash = JSON.parse(@request.to_json)
    @response_hash = JSON.parse(@response.to_json)
    @result_hash = JSON.parse(@response.body).to_a[0]

    if @result_hash == nil
      @result_hash = Hash.new
      @result_hash = { 'response' => "empty" }
    end

    # Display an error if there are no results returned
    if @result_hash.size == 0
      @result_hash = { 'Name' => "error", 'response' => @response.body }
    end
  end

  def auth_info
    @result_hash = session[:webapi]
  end

  def symbol_snapshot
    
  end

  def symbol_snapshot_request

    target_url = "#{@environment}/stream/quote/snapshots/#{params[:symbols]}"
    
    https_get(target_url)

    @request_hash = JSON.parse(@request.to_json)
    @response_hash = JSON.parse(@response.to_json)

    @result_array = @response.body.split("\r\n")
    @result_array.pop() if @result_array[@result_array.size - 1] == "END"

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { :Symbol => "error", :response => @response.body }.to_json
    end

    respond_to do |format|
      format.js
    end
  end

  def authenticate
    # Lets store some useful variables from our webapi session
    if session[:webapi] != nil
      @access_token = session[:webapi]["access_token"]
      @userid = session[:webapi]["userid"]
    end

    if @access_token == nil
      redirect_to authenticate_login_path
    end
  end
end

