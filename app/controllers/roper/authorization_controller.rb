require_dependency "roper/application_controller"

module Roper
  class AuthorizationController < ApplicationController
    # GET /authorize
    # https://tools.ietf.org/html/rfc6749#section-3.1
    def authorize
      @response_type = params[:response_type]
      @client_id = params[:client_id]
      render :json => create_error("invalid_request"), :status => 400 and return if !@response_type
      render :json => create_error("invalid_request"), :status => 400 and return if !@client_id

      @client = Roper::Repository.for(:client).find_by_client_id(@client_id)
      render :json => create_error("invalid_request"), :status => 400 and return if !@client_id

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


    private

    def process_authorization_code_grant
      # TODO

    end

    def process_implicit_grant
      # TODO
    end
  end
end
