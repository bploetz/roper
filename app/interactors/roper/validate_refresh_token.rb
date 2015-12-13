require 'interactor'

module Roper
  class ValidateRefreshToken
    include ::Interactor

    def call
      access_token = Roper::Repository.for(:access_token).find_by_refresh_token(context.refresh_token)
      client = context.client

      context.fail! if !access_token
      context.fail! if access_token.client_id != client.id
    end
  end
end
