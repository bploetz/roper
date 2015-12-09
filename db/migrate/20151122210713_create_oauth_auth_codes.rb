class CreateOauthAuthCodes < ActiveRecord::Migration
  def change
    create_table :oauth_auth_codes do |t|
      t.string :code, null: false
      t.string :redirect_uri, null: false
      t.boolean :redeemed, null: false, default: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_reference :oauth_auth_codes, :client, index: true
    # work around for quirk in sqlite where you can add a not null column after the table is created.
    change_column :oauth_auth_codes, :client_id, :integer, :null => false
    add_index :oauth_auth_codes, :code, :unique => true
    add_index :oauth_auth_codes, :expires_at
  end
end
