module Roper
  module Mongoid
    class JwtIssuer
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      field :issuer, type: String

      embedded_in :client
      embeds_many :jwt_issuer_keys

      validates_uniqueness_of :issuer, :message => "issuer has already been taken"
      validate :unique_algorithms


      private

      def unique_algorithms
        algorithms = self.jwt_issuer_keys.map {|issuer_key| issuer_key.algorithm}
        errors.add(:jwt_issuer_keys, "may not contain duplicate algorithms") and return if algorithms.length != algorithms.uniq.length
      end
    end
  end
end
