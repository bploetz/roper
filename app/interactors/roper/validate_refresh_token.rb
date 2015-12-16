require 'interactor'

module Roper
  class ValidateRefreshToken
    include ::Interactor

    def call
      refresh_token = Roper::Repository.for(:refresh_token).find_by_token(context.refresh_token)
      client = context.client

      context.fail! if !refresh_token
      context.fail! if refresh_token.client_id != client.id
    end
  end
end
