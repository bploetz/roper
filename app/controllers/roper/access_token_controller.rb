require_dependency "roper/application_controller"

module Roper
  class AccessTokenController < ApplicationController
    # POST /token
    # https://tools.ietf.org/html/rfc6749#section-3.2
    def token
      grant_type = params[:grant_type]
      render :json => create_error("invalid_request"), :status => 400 and return if !grant_type

      case grant_type
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
