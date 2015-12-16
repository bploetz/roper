require 'interactor'

module Roper
  class ValidateAuthorizationCode
    include ::Interactor

    def call
      authorization_code = Roper::Repository.for(:authorization_code).find_by_code(context.code)
      client = context.client
      redirect_uri = context.redirect_uri

      context.fail!(:message => "auth code not found") if !authorization_code
      context.fail!(:message => "auth code client and request client don't match") if authorization_code.client_id != client.id 
      context.fail!(:message => "auth code already redeemed") if authorization_code.redeemed == true
      context.fail!(:message => "auth code expired") if authorization_code.expires_at.past?

      if authorization_code.redirect_uri
        context.fail!(:message => "auth code requires redirect uri and no redirect uri given") if !redirect_uri

        begin
          parsed_redirect_uri = URI::parse(redirect_uri)
          context.fail!(:message => "redirect uri not an http") if !parsed_redirect_uri.kind_of?(URI::HTTP)
          context.fail!(:message => "redirect uri not equal to auth code redirect uri") if parsed_redirect_uri != URI::parse(authorization_code.redirect_uri)
        rescue URI::InvalidURIError => err
          context.fail!(:message => "could not parse redirect uri")
        end
      end
    end
  end
end
