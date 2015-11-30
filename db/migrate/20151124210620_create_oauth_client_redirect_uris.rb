class CreateOauthClientRedirectUris < ActiveRecord::Migration
  def change
    create_table :oauth_client_redirect_uris do |t|
      t.integer :client_id
      t.string :uri

      t.timestamps
    end

    add_index :oauth_client_redirect_uris, :client_id
  end
end
