require 'interactor'

module Roper
  class RedeemAuthorizationCode
    include ::Interactor

    def call
      context.authorization_code.redeemed = true
      if !context.authorization_code.save
        context.fail!
      end
    end
  end
end
