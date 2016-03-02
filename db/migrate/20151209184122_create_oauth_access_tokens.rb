class CreateOauthAccessTokens < ActiveRecord::Migration
  def change
    create_table :oauth_access_tokens do |t|
      t.string :token, null: false
      t.string :principal, null: false
      t.datetime :expires_at, null: true

      t.timestamps
    end

    add_reference :oauth_access_tokens, :client, index: true
    # work around for quirk in sqlite where you can add a not null column after the table is created.
    change_column :oauth_access_tokens, :client_id, :integer, :null => false
    add_index :oauth_access_tokens, :token, :unique => true
  end
end
