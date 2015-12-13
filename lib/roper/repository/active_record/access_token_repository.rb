module Roper
  module ActiveRecord
    class AccessTokenRepository
      def model_class
        ActiveRecord::AccessToken
      end

      def new(attributes = {})
        instance = model_class.new(attributes)
        instance
      end

      def save(object)
        object.save
        return object
      end

      def find_by_token(token)
        model_class.find_by(:token => token)
      end

      def find_by_refresh_token(refresh_token)
        model_class.find_by(:refresh_token => refresh_token)
      end
    end
  end
end
