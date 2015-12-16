require 'interactor'

module Roper
  class GenerateRefreshToken
    include ::Interactor

    def call
      repository = Roper::Repository.for(:refresh_token)
      refresh_token = repository.new(:client_id => context.client.id, :token => UUIDTools::UUID.random_create.to_s)
      if refresh_token.save
        context.refresh_token = refresh_token
      else
        context.fail!
      end
    end
  end
end
