require "uuidtools"
require 'digest/sha1'

module Roper
  module ActiveRecord
    class AuthorizationCodeRepository
      def model_class
        ActiveRecord::AuthorizationCode
      end

      def new(attributes = {})
        instance = model_class.new(attributes)
        instance.code = Digest::SHA1.hexdigest(UUIDTools::UUID.random_create.to_s)
        instance
      end

      def save(object)
        return object.save
      end

      def find_by_code(code)
        model_class.find_by(:code => code)
      end
    end
  end
end
