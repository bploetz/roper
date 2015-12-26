module Roper
  module Mongoid
    class ClientRedirectUri
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      field :uri, type: String

      embedded_in :client

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
