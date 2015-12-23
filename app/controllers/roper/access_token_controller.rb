require_dependency "roper/application_controller"

module Roper
  class AccessTokenController < ApplicationController
    skip_before_filter :verify_authenticity_token

    before_action :authenticate_client

    # POST /token
    # https://tools.ietf.org/html/rfc6749#section-3.2
    def token
      grant_type = params[:grant_type]
      render :json => create_error("invalid_request"), :status => 400 and return if !grant_type

      case grant_type
      when 'authorization_code'
        # https://tools.ietf.org/html/rfc6749#section-4.1.3
        process_authorization_code_grant
      when 'refresh_token'
        # https://tools.ietf.org/html/rfc6749#section-6
        process_refresh_token_grant
      when 'password'
        # https://tools.ietf.org/html/rfc6749#section-4.3
        process_resource_owner_password_credentials_grant
      when 'client_credentials'
        # https://tools.ietf.org/html/rfc6749#section-4.4
        process_client_credentials_grant
      when 'urn:ietf:params:oauth:grant-type:jwt-bearer'
        # https://tools.ietf.org/html/rfc7523
        process_jwt_bearer_grant
      else
        render :json => create_error("unsupported_grant_type"), :status => 400 and return
      end
    end


    private

    # https://tools.ietf.org/html/rfc6749#section-3.2.1
    def authenticate_client
      auth_header = request.authorization
      if !auth_header.blank? && auth_header.start_with?("Basic ")
        client_id_client_secret = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
        @client = Roper::Repository.for(:client).find_by_client_id(client_id_client_secret[0])
        # https://tools.ietf.org/html/rfc6749#section-5.2
        if !@client || BCrypt::Password.new(@client.client_secret) != client_id_client_secret[1]
          response.headers['WWW-Authenticate'] = "Basic"
          render :json => create_error("invalid_client"), :status => :unauthorized and return
        end
      elsif params[:grant_type] && params[:grant_type] == 'authorization_code' && params[:client_id]
        @client = Roper::Repository.for(:client).find_by_client_id(params[:client_id])
        render :json => create_error("invalid_client"), :status => 400 and return if !@client
      else
        head :unauthorized and return
      end
    end

    def process_authorization_code_grant
      code = params[:code]
      render :json => create_error("invalid_request"), :status => 400 and return if !code
      redirect_uri = params[:redirect_uri]

      validate_authorization_code_result = Roper::ValidateAuthorizationCode.call(:client => @client, :code => code, :redirect_uri => redirect_uri)
      if !validate_authorization_code_result.success?
        Rails.logger.debug "authorization code validation failed: #{validate_authorization_code_result.message}"
        render :json => create_error("invalid_grant"), :status => 400 and return
      end

      access_token_result = Roper::GenerateAccessToken.call(:client => @client)
      if access_token_result.success?
        redeem_authorization_code_result = Roper::RedeemAuthorizationCode.call(:code => code)
        if redeem_authorization_code_result.success?
          render :json => access_token_result.access_token_hash, :status => 200 and return
        else
          render :json => create_error("invalid_grant"), :status => 400 and return
        end
      else
        render :json => create_error("server_error"), :status => 500 and return
      end
    end

    def process_refresh_token_grant
      refresh_token = params[:refresh_token]
      render :json => create_error("invalid_request"), :status => 400 and return if !refresh_token
      scope = params[:scope]

      validate_refresh_token_result = Roper::ValidateRefreshToken.call(:client => @client, :refresh_token => refresh_token)
      if !validate_refresh_token_result.success?
        render :json => create_error("invalid_grant"), :status => 400 and return
      end

      access_token_result = Roper::GenerateAccessToken.call(:client => @client)
      if access_token_result.success?
        render :json => access_token_result.access_token_hash, :status => 200 and return
      else
        render :json => create_error("server_error"), :status => 500 and return
      end
    end

    def process_resource_owner_password_credentials_grant
      username = params[:username]
      render :json => create_error("invalid_request", "username is required"), :status => 400 and return if !username
      password = params[:password]
      render :json => create_error("invalid_request", "password is required"), :status => 400 and return if !password

      if send(Roper.authenticate_resource_owner_method, username, password)
        access_token_result = Roper::GenerateAccessToken.call(:client => @client)
        if access_token_result.success?
          render :json => access_token_result.access_token_hash, :status => 200 and return
        else
          render :json => create_error("server_error"), :status => 500 and return
        end
      else
        render :json => create_error("invalid_grant"), :status => 400 and return
      end
    end

    def process_client_credentials_grant
      access_token_result = Roper::GenerateAccessToken.call(:client => @client)
      if access_token_result.success?
        render :json => access_token_result.access_token_hash, :status => 200 and return
      else
        render :json => create_error("server_error"), :status => 500 and return
      end
    end

    def process_jwt_bearer_grant
      # TODO
    end
  end
end
