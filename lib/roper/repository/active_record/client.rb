require 'bcrypt'

module Roper
  module ActiveRecord
    class Client < ::ActiveRecord::Base
      self.table_name = "oauth_clients"

      validates_uniqueness_of :client_id, :message => "client_id has already been taken"
      validate :credentials_changed, :on => :update

      has_many :client_redirect_uris

      before_save :hash_client_secret, if: :client_secret_changed?


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


      private

      def credentials_changed
        errors.add(:client_id, "cannot update client_id") if self.client_id_changed?
        errors.add(:client_secret, "cannot update client_secret") if self.client_secret_changed?
      end

      def hash_client_secret
        self.client_secret = BCrypt::Password.create(self.client_secret, :cost => 10).to_s
      end
    end
  end
end
