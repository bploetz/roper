require 'interactor'

module Roper
  class ValidateAuthorizationCode
    include ::Interactor

    def call
      authorization_code = Roper::Repository.for(:authorization_code).find_by_code(context.code)
      client = context.client
      redirect_uri = context.redirect_uri

      context.fail! if !authorization_code
      context.fail! if authorization_code.client_id != client.id 
      context.fail! if authorization_code.redeemed == true
      context.fail! if authorization_code.expires_at.past?

      if authorization_code.redirect_uri
        context.fail! if !redirect_uri

        begin
          parsed_redirect_uri = URI::parse(redirect_uri)
          context.fail! if !parsed_redirect_uri.kind_of?(URI::HTTP)
          context.fail! if parsed_redirect_uri != URI::parse(authorization_code.redirect_uri)
        rescue URI::InvalidURIError => err
          context.fail!
        end
      end
    end
  end
end
