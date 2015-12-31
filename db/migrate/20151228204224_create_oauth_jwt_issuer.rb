class CreateOauthJwtIssuer < ActiveRecord::Migration
  def change
    create_table :oauth_jwt_issuers do |t|
      t.string :issuer, null: false

      t.timestamps
    end

    add_index :oauth_jwt_issuers, :issuer, :unique => true
    add_reference :oauth_jwt_issuers, :client, index: true
  end
end
