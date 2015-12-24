require 'bcrypt'

module Roper
  module Mongoid
    class Client
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      store_in collection: "oauth_clients"

      field :client_id, type: String
      field :client_secret, type: String
      field :client_name, type: String

      embeds_many :client_redirect_uris

      index({client_id: 1}, {unique: true, background: true})
    end
  end
end
