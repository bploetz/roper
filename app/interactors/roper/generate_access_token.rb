require 'interactor'

module Roper
  class GenerateAccessToken
    include ::Interactor

    def call
      repository = Roper::Repository.for(:access_token)
      access_token = repository.new(:client_id => context.client.id, :token => UUIDTools::UUID.random_create.to_s)
      if Roper.access_token_expiration_time
        access_token.expires_at = Roper.access_token_expiration_time.send(:seconds).from_now
      end

      if repository.save(access_token)
        access_token_hash = {:access_token => access_token.token, :token_type => "Bearer"}
        if Roper.enable_refresh_tokens
          refresh_token_result = Roper::GenerateRefreshToken.call(:client => context.client)
          if refresh_token_result.success?
            access_token_hash[:refresh_token] = refresh_token_result.refresh_token.token
          else
            context.fail!
          end
        end
        if Roper.access_token_expiration_time
          access_token_hash[:expires_in] = Roper.access_token_expiration_time
        end

        # TODO: Add support for echoing back state
        # state
        #  REQUIRED if the "state" parameter was present in the client
        #  authorization request.  The exact value received from the
        #  client.
        context.access_token_hash = access_token_hash
      else
        context.fail!
      end
    end
  end
end
