module Roper
  module Mongoid
    class ClientRedirectUri
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      field :uri, type: String

      embedded_in :client
    end
  end
end
