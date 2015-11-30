module Roper
  module ActiveRecord
    class Client < ::ActiveRecord::Base
      self.table_name = "oauth_clients"

      has_many :client_redirect_uris

      def valid_redirect_uri?(uri)
        begin
          parsed_uri = URI::parse(uri)
          return false if !parsed_uri.kind_of?(URI::HTTP)
          self.client_redirect_uris.each do |redirect_uri|
            # https://tools.ietf.org/html/rfc6749#section-3.1.2.3
            return true if parsed_uri == URI::parse(redirect_uri.uri)
          end
        rescue URI::InvalidURIError => err
          return false
        end

        false
      end
    end
  end
end
