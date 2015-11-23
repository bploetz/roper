require_dependency "roper/application_controller"

module Roper
  class AuthorizationController < ApplicationController

    before_action :check_logged_in

    # GET /authorize
    # https://tools.ietf.org/html/rfc6749#section-3.1
    def authorize
      @state = params[:state]
      @response_type = params[:response_type]
      render :json => create_error("invalid_request", "response_type is required", nil, @state), :status => 400 and return if !@response_type
      @client_id = params[:client_id]
      render :json => create_error("invalid_request", "client_id is required", nil, @state), :status => 400 and return if !@client_id
      @client = Roper::Repository.for(:client).find_by_client_id(@client_id)
      render :json => create_error("invalid_request"), :status => 400 and return if !@client
      # TODO: Add support for configuring the redirect_uri on the client so it doesn't have
      # to be passed as a parameter. For now, treat it as required in the request.
      @redirect_uri = params[:redirect_uri]
      render :json => create_error("invalid_request", "redirect_uri is required", nil, @state), :status => 400 and return if !@redirect_uri

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
      @state = params[:state]
      @client_id = params[:client_id]
      render :json => create_error("invalid_request", "client_id is required", nil, @state), :status => 400 and return if !@client_id
      @client = Roper::Repository.for(:client).find_by_client_id(@client_id)
      render :json => create_error("invalid_request"), :status => 400 and return if !@client
      # TODO: Add support for configuring the redirect_uri on the client so it doesn't have
      # to be passed as a parameter. For now, treat it as required in the request.
      @redirect_uri = params[:redirect_uri]
      render :json => create_error("invalid_request", "redirect_uri is required", nil, @state), :status => 400 and return if !@redirect_uri

      @authorization_code = Roper::Repository.for(:authorization_code).new(:client_id => @client_id,
                                                                           :redirect_uri => @redirect_uri,
                                                                           :expires_at => (DateTime.now + 5.minutes))
      Roper::Repository.for(:authorization_code).save(@authorization_code)
      augmented_redirect_uri = "#{params[:redirect_uri]}?code=#{@authorization_code.code}"
      augmented_redirect_uri << "&state=#{params[:state]}" if @state && !@state.blank?
      redirect_to augmented_redirect_uri
    end

    def deny_authorization
    end


    private

    def check_logged_in
      send(Roper.signed_in_method)
    end

    def process_authorization_code_grant
      @redirect_uri = params[:redirect_uri]
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

    def process_implicit_grant
      # TODO
    end
  end
end
