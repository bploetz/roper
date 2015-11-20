module Roper
  module ActiveRecord
    class ClientRepository
      def model_class
        ActiveRecord::Client
      end

      def new(attributes = {})
        model_class.new(attributes)
      end

      def save(object)
        object.save
        return object
      end

      def find_by_client_id(client_id)
        model_class.find_by(:client_id => client_id)
      end
    end
  end
end
