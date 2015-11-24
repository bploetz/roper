class AddRedirectUriToOauthClients < ActiveRecord::Migration
  def change
    add_column :oauth_clients, :redirect_uri, :string
  end
end
