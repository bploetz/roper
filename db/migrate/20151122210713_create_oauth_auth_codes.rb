class CreateOauthAuthCodes < ActiveRecord::Migration
  def change
    create_table :oauth_auth_codes do |t|
      t.string :code, null: false
      t.string :client_id, null: false
      t.string :redirect_uri, null: false
      t.boolean :redeemed, null: false, default: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :oauth_auth_codes, :code, :unique => true
    add_index :oauth_auth_codes, :client_id
    add_index :oauth_auth_codes, :expires_at
  end
end
