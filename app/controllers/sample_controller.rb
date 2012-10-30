class SampleController < ApplicationController
  before_filter :authenticate

  def index
  end

  def symbol_lookup
  end

  def symbol_lookup_request
    if params[:category] != 'FU'
      @target_url = "#{@environment}/data/symbols/search/n=#{params[:symbol]}&c=#{params[:category]}"
    else
      @target_url = "#{@environment}/data/symbols/search/r=#{params[:symbol]}&c=#{params[:category]}"
    end
    
    https_get(@target_url)

    if @response.code.to_i() < 400
      @result_array = JSON.parse(@response.body).to_a 
    else
      @result_array = @error_array
    end   

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { 'Name' => "error", 'response' => @response.body }
    end

    @tab_name = 'Name'    

    respond_to do |format|
      format.js
    end
  end

  def account_list
    @target_url = "#{@environment}/users/#{@userid}/accounts"

    https_get(@target_url)

    if @response.code.to_i() < 400
      @result_array = JSON.parse(@response.body).to_a 
    else
      @result_array = @error_array
    end   

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { 'Name' => "error", 'response' => @response.body }
    end

    @tab_name = 'Key'
  end

  def account_balances
    @target_url = "#{@environment}/accounts/#{params[:account_key]}/balances"

    https_get(@target_url)

    if @response.code.to_i() < 400
      @result_array = JSON.parse(@response.body).to_a 
    else
      @result_array = @error_array
    end   

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { 'Key' => "error", 'response' => @response.body }
    end

    @tab_name = 'Key'  
  end

  def account_positions
    @target_url = "#{@environment}/accounts/#{params[:account_key]}/positions"

    https_get(@target_url)

    if @response.code.to_i() < 400
      @result_array = JSON.parse(@response.body).to_a 
    else
      @result_array = @error_array
    end   

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { 'Key' => "error", 'response' => @response.body }
    end

    @tab_name = 'Key'  
  end

  def account_orders
    @target_url = "#{@environment}/accounts/#{params[:account_key]}/orders"

    https_get(@target_url)

    if @response.code.to_i() < 400
      @result_array = JSON.parse(@response.body).to_a 
    else
      @result_array = @error_array
    end   

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { 'OrderID' => "error", 'response' => @response.body }
    end

    @tab_name = 'OrderID'    
  end

  def auth_info
    @result_hash = session[:webapi]
  end

  def quote
  end

  def quote_request

    target_url = "#{@environment}/data/quote/#{params[:symbols]}"
    
    https_get(target_url)

    if @response.code.to_i() < 400
      @result_array = JSON.parse(@response.body).to_a 
    else
      @result_array = @error_array
    end   

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { :Symbol => "error", :response => @response.body }.to_json
    end

    @tab_name = 'Symbol'

    respond_to do |format|
      format.js
    end
  end

  def order
  end

  def order_send

    target_url = "#{@environment}/orders"
    
    https_post_with_body(target_url, {:Symbol => params[:Symbol], 
                                      :AccountKey => params[:AccountKey], 
                                      :AssetType => params[:AssetType], 
                                      :Duration => params[:Duration], 
                                      :LimitPrice => params[:LimitPrice], 
                                      :OrderType => params[:OrderType], 
                                      :Quantity => params[:Quantity], 
                                      :TradeAction => params[:TradeAction]})

    if @response.code.to_i() < 400
      @result_array = JSON.parse(@response.body).to_a 
    else
      @result_array = @error_array
    end   

    # Display an error if there are no results returned
    if @result_array.size == 0
      @result_array = Array.new
      @result_array[0] = { :Symbol => "error", :response => @response.body }.to_json
    end

    @tab_name = 'Symbol'

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

