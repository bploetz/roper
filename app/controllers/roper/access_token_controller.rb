require_dependency "roper/application_controller"

module Roper
  class AccessTokenController < ApplicationController
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
      if !auth_header.blank? && auth_header.start_with?("Basic: ")
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

      authorization_code = Roper::Repository.for(:authorization_code).find_by_code(code)
      render :json => create_error("invalid_grant"), :status => 400 and return if !authorization_code
      render :json => create_error("invalid_grant"), :status => 400 and return if authorization_code.client_id != @client.id

      if authorization_code.redirect_uri
        redirect_uri = params[:redirect_uri]
        render :json => create_error("invalid_grant"), :status => 400 and return if !redirect_uri

        begin
          parsed_redirect_uri = URI::parse(redirect_uri)
          render :json => create_error("invalid_request"), :status => 400 and return if !parsed_redirect_uri.kind_of?(URI::HTTP)
          render :json => create_error("invalid_grant"), :status => 400 and return if parsed_redirect_uri != URI::parse(authorization_code.redirect_uri)
        rescue URI::InvalidURIError => err
          render :json => create_error("invalid_request"), :status => 400 and return
        end
      end

      access_token = Roper::Repository.for(:access_token).new(:client_id => @client.id)
      if access_token.save
        authorization_code.redeemed = true
        if authorization_code.save
          render :json => {:access_token => access_token.token, :token_type => "Bearer"}, :status => 200 and return
        else
          render :json => {:message => "unexpected error"}, :status => 500 and return
        end
      else
        render :json => {:message => "unexpected error"}, :status => 500 and return
      end
    end

    def process_resource_owner_password_credentials_grant
      # TODO
    end

    def process_client_credentials_grant
      # TODO
    end

    def process_jwt_bearer_grant
      # TODO
    end
  end
end
