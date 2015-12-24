module Roper
  module Mongoid
    class AuthorizationCode
      include ::Mongoid::Document
      include ::Mongoid::Timestamps

      store_in collection: "oauth_auth_codes"

      field :code, type: String
      field :redirect_uri, type: String
      field :redeemed, type: Boolean, default: false
      field :expires_at, type: DateTime
      field :client_id, type: BSON::ObjectId

      index({code: 1}, {unique: true, background: true})
      index({expires_at: 1}, {background: true})
      index({client_id: 1}, {background: true})
    end
  end
end
