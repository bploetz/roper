module Roper
  module Mongoid
    class AuthorizationCodeRepository
      def model_class
        Mongoid::AuthorizationCode
      end

      def new(attributes = {})
        instance = model_class.new(attributes)
        instance
      end

      def save(object)
        return object.save
      end

      def find_by_code(code)
        begin
          model_class.find_by(:code => code)
        rescue ::Mongoid::Errors::DocumentNotFound => err
          return nil
        end
      end
    end
  end
end
