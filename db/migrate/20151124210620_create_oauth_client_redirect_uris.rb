class CreateOauthClientRedirectUris < ActiveRecord::Migration
  def change
    create_table :oauth_client_redirect_uris do |t|
      t.string :uri

      t.timestamps
    end

    add_reference :oauth_client_redirect_uris, :client, index: true
  end
end
