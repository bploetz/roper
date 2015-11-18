require_dependency "roper/application_controller"

module Roper
  class AuthorizationController < ApplicationController
    # POST /token
    def token
      grant_type = params[:grant_type]
      puts "got grant_type: #{grant_type}"
    end

    # # Only allow a trusted parameter "white list" through.
    # def client_params
    #   params.require(:client).permit(:client_id, :client_secret)
    # end
  end
end
