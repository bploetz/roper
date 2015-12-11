require 'interactor'

module Roper
  class GenerateAccessToken
    include ::Interactor

    def call
      access_token = Roper::Repository.for(:access_token).new(:client_id => context.client.id)
      if access_token.save
        context.access_token = access_token
      else
        context.fail!
      end
    end
  end
end
