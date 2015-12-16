module Roper
  module ActiveRecord
    class RefreshTokenRepository
      def model_class
        ActiveRecord::RefreshToken
      end

      def new(attributes = {})
        instance = model_class.new(attributes)
        instance
      end

      def save(object)
        return object.save
      end

      def find_by_token(token)
        model_class.find_by(:token => token)
      end
    end
  end
end
