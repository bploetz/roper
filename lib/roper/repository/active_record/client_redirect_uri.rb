module Roper
  module ActiveRecord
    class ClientRedirectUri < ::ActiveRecord::Base
      self.table_name = "oauth_client_redirect_uris"

      belongs_to :client

      validate :valid_uri


      def valid_uri
        begin
          parsed_uri = URI::parse(self.uri)
          errors.add(:uri, "invalid URI") if !parsed_uri.kind_of?(URI::HTTP)
        rescue URI::InvalidURIError => err
          errors.add(:uri, "invalid URI")
        end
      end
    end
  end
end
