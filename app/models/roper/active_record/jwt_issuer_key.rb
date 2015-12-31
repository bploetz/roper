module Roper
  module ActiveRecord
    class JwtIssuerKey < ::ActiveRecord::Base
      self.table_name = "oauth_jwt_issuer_keys"

      HMAC_ALGORITHMS = ["HS256", "HS384", "HS512"]
      RSA_ALGORITHMS = ["RS256", "RS384", "RS512"]
      ECDSA_ALGORITHMS = ["ES256", "ES384", "ES512"]
      SUPPORTED_ALGORITHMS = HMAC_ALGORITHMS + RSA_ALGORITHMS + ECDSA_ALGORITHMS

      validates :algorithm, presence: true
      validates :algorithm, inclusion: { in: SUPPORTED_ALGORITHMS,
                 message: "%{value} is not a supported algorithm" }
      validates :hmac_secret, presence: true, if: Proc.new {|jik| HMAC_ALGORITHMS.include?(jik.algorithm)}
      validates :public_key, presence: true, if: Proc.new {|jik| RSA_ALGORITHMS.include?(algorithm) || ECDSA_ALGORITHMS.include?(algorithm)}

      validate :validate_hmac_secret, if: Proc.new {|jik| HMAC_ALGORITHMS.include?(jik.algorithm)}
      validate :validate_public_key, if: Proc.new {|jik| RSA_ALGORITHMS.include?(algorithm) || ECDSA_ALGORITHMS.include?(algorithm)}

      belongs_to :jwt_issuer

      before_save :serialize_public_key, if: :public_key_changed?


      def validate_hmac_secret
        errors.add(:hmac_secret, "must be a String for #{algorithm} algorithm") if !hmac_secret.is_a?(String)
      end

      def validate_public_key
        if RSA_ALGORITHMS.include?(algorithm)
          errors.add(:public_key, "must be an OpenSSL::PKey::RSA object for #{algorithm} algorithm") and return if !public_key.is_a?(OpenSSL::PKey::RSA)
          errors.add(:public_key, "must not be a private key") if public_key.private?
        elsif ECDSA_ALGORITHMS.include?(algorithm)
          errors.add(:public_key, "must be an OpenSSL::PKey::EC object for #{algorithm} algorithm") and return if !public_key.is_a?(OpenSSL::PKey::EC)
          errors.add(:public_key, "must not be a private key") if public_key.private_key?
        end
      end

      def serialize_public_key
        if RSA_ALGORITHMS.include?(algorithm)
          self.public_key = public_key.to_pem
        elsif ECDSA_ALGORITHMS.include?(algorithm)
          self.public_key = public_key.to_pem
        end
      end
    end
  end
end
