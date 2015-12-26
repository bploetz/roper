require 'bcrypt'

module Roper
  module Mongoid
    class Client
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      store_in collection: "oauth_clients"

      field :client_id, type: String
      field :client_secret, type: String
      field :client_name, type: String

      embeds_many :client_redirect_uris, :class_name => "Roper::Mongoid::ClientRedirectUri"

      index({client_id: 1}, {unique: true, background: true})

      validates_uniqueness_of :client_id, :message => "client_id has already been taken"
      validate :credentials_changed, :on => :update

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
