class CreateOauthJwtIssuerKeys < ActiveRecord::Migration
  def change
    create_table :oauth_jwt_issuer_keys do |t|
      t.string :algorithm, null: false
      t.string :hmac_secret
      t.string :public_key
      t.string :keyid
    end

    add_reference :oauth_jwt_issuer_keys, :jwt_issuer, index: true
  end
end
