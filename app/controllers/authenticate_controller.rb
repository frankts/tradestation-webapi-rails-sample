class AuthenticateController < ApplicationController
	
  def authorize
    target_url = "#{@environment}/authorize?redirect_uri=#{authenticate_callback_url}&client_id=#{@client_id}&response_type=code"
    redirect_to target_url
  end

  def callback
  	code = params[:code]

   	@content = https_post("#{@environment}/security/authorize", {"grant_type"     => "authorization_code",
                                                                 "code"           => code, 
                                                                 "client_id"      => @client_id, 
                                                                 "client_secret"  => @client_secret, 
                                                                 "redirect_uri"   => authenticate_callback_url} )

    # Lets keep the information around so that we can access it whenever we want.
  	session[:webapi] = JSON(@content)
  	redirect_to root_path
  end

  def login

  end

  def logout
  	session[:webapi] = nil
  	redirect_to authenticate_login_path
  end

end
