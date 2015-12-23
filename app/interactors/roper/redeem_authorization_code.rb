require 'interactor'

module Roper
  class RedeemAuthorizationCode
    include ::Interactor

    def call
      repository = Roper::Repository.for(:authorization_code)
      authorization_code = repository.find_by_code(context.code)
      context.fail! if !authorization_code
      context.fail! if authorization_code.redeemed
      authorization_code.redeemed = true
      if !repository.save(authorization_code)
        context.fail!
      end
    end
  end
end
