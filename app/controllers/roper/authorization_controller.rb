require_dependency "roper/application_controller"

module Roper
  class AuthorizationController < ApplicationController

    before_action :validate_logged_in
    before_action :validate_parameters

    # GET /authorize
    # https://tools.ietf.org/html/rfc6749#section-3.1
    def authorize
      @response_type = params[:response_type]
      render :json => create_error("invalid_request", "response_type is required", nil, @state), :status => 400 and return if !@response_type

      case @response_type
      when 'code'
        # https://tools.ietf.org/html/rfc6749#section-4.1
        process_authorization_code_grant
      when 'token'
        # https://tools.ietf.org/html/rfc6749#section-4.2
        process_implicit_grant
      else
        render :json => create_error("unsupported_response_type", nil, nil, @state), :status => 400 and return
      end
    end

    def approve_authorization
      authorization_code_result = Roper::GenerateAuthorizationCode.call(:client => @client, :request_redirect_uri => @request_redirect_uri)
      if authorization_code_result.success?
        augmented_redirect_uri = "#{params[:redirect_uri]}?code=#{authorization_code_result.authorization_code.code}"
        augmented_redirect_uri << "&state=#{params[:state]}" if @state && !@state.blank?
        redirect_to augmented_redirect_uri
      else
        render :json => {:message => "unexpected error"}, :status => 500 and return
      end
    end

    def deny_authorization
      # TODO
      # Should return a "access_denied" error response
      # https://tools.ietf.org/html/rfc6749#section-4.1.2.1
    end


    private

    def validate_parameters
      @state = params[:state]

      @client_id = params[:client_id]
      render :json => create_error("invalid_request", "client_id is required", nil, @state), :status => 400 and return if !@client_id

      @client = Roper::Repository.for(:client).find_by_client_id(@client_id)
      render :json => create_error("invalid_request"), :status => 400 and return if !@client

      # https://tools.ietf.org/html/rfc6749#section-3.1.2.3
      if @client.client_redirect_uris.size == 1
        if params[:redirect_uri]
          if @client.valid_redirect_uri?(params[:redirect_uri])
            @redirect_uri = @request_redirect_uri = params[:redirect_uri]
          end
        else
          @redirect_uri = @client.client_redirect_uris[0].uri
        end
      elsif @client.client_redirect_uris.size > 1
        render :json => create_error("invalid_request", "redirect_uri is required", nil, @state), :status => 400 and return if !params[:redirect_uri]
        if @client.valid_redirect_uri?(params[:redirect_uri])
          @redirect_uri = @request_redirect_uri = params[:redirect_uri]
        end
      end
      render :json => create_error("invalid_request", "invalid redirect_uri", nil, @state), :status => 400 and return if !@redirect_uri

      @scope = params[:scope]
      if @scope
        if @scope.include?(" ")
          @scopes = @scope.split(" ")
        else
          @scopes = []
        end
      else
        @scopes = []
      end
    end

    def validate_logged_in
      send(Roper.signed_in_method)
    end

    def process_authorization_code_grant
    end

    def process_implicit_grant
    end
  end
end
