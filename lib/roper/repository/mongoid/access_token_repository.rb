module Roper
  module Mongoid
    class AccessTokenRepository
      def model_class
        Mongoid::AccessToken
      end

      def new(attributes = {})
        instance = model_class.new(attributes)
        instance
      end

      def save(object)
        return object.save
      end

      def find_by_token(token)
        begin
          model_class.find_by(:token => token)
        rescue ::Mongoid::Errors::DocumentNotFound => err
          return nil
        end
      end
    end
  end
end
