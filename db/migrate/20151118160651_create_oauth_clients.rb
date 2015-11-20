class CreateOauthClients < ActiveRecord::Migration
  def change
    create_table :oauth_clients do |t|
      t.string :client_id
      t.string :client_secret
      t.string :client_name

      t.timestamps
    end

    add_index :oauth_clients, :client_id, :unique => true
  end
end
