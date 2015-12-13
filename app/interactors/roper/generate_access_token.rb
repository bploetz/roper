require 'interactor'

module Roper
  class GenerateAccessToken
    include ::Interactor

    def call
      access_token = Roper::Repository.for(:access_token).new(:client_id => context.client.id, :token => UUIDTools::UUID.random_create.to_s)
      if Roper.access_token_expiration_time
        access_token.expires_at = Roper.access_token_expiration_time.send(:seconds).from_now
      end
      if Roper.enable_refresh_tokens
        access_token.refresh_token = UUIDTools::UUID.random_create.to_s
      end
      if access_token.save
        access_token_hash = {:access_token => access_token.token, :token_type => "Bearer"}
        if Roper.enable_refresh_tokens
          access_token_hash[:refresh_token] = access_token.refresh_token
        end
        if Roper.access_token_expiration_time
          access_token_hash[:expires_in] = Roper.access_token_expiration_time
        end
        context.access_token_hash = access_token_hash
      else
        context.fail!
      end
    end
  end
end
