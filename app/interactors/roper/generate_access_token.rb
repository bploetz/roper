require 'interactor'

module Roper
  class GenerateAccessToken
    include ::Interactor

    def call
      access_token = Roper::Repository.for(:access_token).new(:client_id => context.client.id)
      if Roper.access_token_expiration_time
        access_token.expires_at = Roper.access_token_expiration_time.send(:seconds).from_now
      end
      if access_token.save
        context.access_token = access_token
      else
        context.fail!
      end
    end
  end
end
