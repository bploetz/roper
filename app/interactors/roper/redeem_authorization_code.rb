require 'interactor'

module Roper
  class RedeemAuthorizationCode
    include ::Interactor

    def call
      authorization_code = Roper::Repository.for(:authorization_code).find_by_code(context.code)
      context.fail! if !authorization_code
      authorization_code.redeemed = true
      if !authorization_code.save
        context.fail!
      end
    end
  end
end
