require_dependency "roper/application_controller"

module Roper
  class AuthorizationController < ApplicationController

    before_action :check_logged_in

    # GET /authorize
    # https://tools.ietf.org/html/rfc6749#section-3.1
    def authorize
      @response_type = params[:response_type]
      render :json => create_error("invalid_request"), :status => 400 and return if !@response_type
      @client_id = params[:client_id]
      render :json => create_error("invalid_request"), :status => 400 and return if !@client_id
      @client = Roper::Repository.for(:client).find_by_client_id(@client_id)
      render :json => create_error("invalid_request"), :status => 400 and return if !@client

      case @response_type
      when 'code'
        # https://tools.ietf.org/html/rfc6749#section-4.1
        process_authorization_code_grant
      when 'token'
        # https://tools.ietf.org/html/rfc6749#section-4.2
        process_implicit_grant
      else
        render :json => create_error("unsupported_response_type"), :status => 400 and return
      end
    end

    def approve_authorization
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
      @state = params[:state]
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
