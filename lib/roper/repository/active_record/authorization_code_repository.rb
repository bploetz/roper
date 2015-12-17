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
