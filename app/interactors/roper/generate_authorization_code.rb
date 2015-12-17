require 'interactor'

module Roper
  class GenerateAuthorizationCode
    include ::Interactor

    def call
      repository = Roper::Repository.for(:authorization_code)
      authorization_code = repository.new(:client_id => context.client.id,
                                          :code => Digest::SHA1.hexdigest(UUIDTools::UUID.random_create.to_s),
                                          :redirect_uri => context.request_redirect_uri,
                                          :expires_at => 5.minutes.from_now)
      if repository.save(authorization_code)
        context.authorization_code = authorization_code
      else
        context.fail!
      end
    end
  end
end
