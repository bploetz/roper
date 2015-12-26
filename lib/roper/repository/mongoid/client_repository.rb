require "uuidtools"
require 'digest/sha1'

module Roper
  module Mongoid
    class ClientRepository
      def model_class
        Mongoid::Client
      end

      def new(attributes = {})
        instance = model_class.new(attributes)
        instance.client_id = UUIDTools::UUID.random_create.to_s
        instance.client_secret = UUIDTools::UUID.random_create.to_s
        instance
      end

      def save(object)
        object.save
        return object
      end

      def find_by_client_id(client_id)
        begin
          model_class.find_by(:client_id => client_id)
        rescue ::Mongoid::Errors::DocumentNotFound => err
          return nil
        end
      end
    end
  end
end
