module Roper
  module Mongoid
    class AccessToken
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      store_in collection: "oauth_access_tokens"

      field :token, type: String
      field :expires_at, type: DateTime
      field :client_id, type: BSON::ObjectId

      index({token: 1}, {unique: true, background: true})
      index({client_id: 1}, {background: true})
    end
  end
end
