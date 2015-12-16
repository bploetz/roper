class CreateOauthRefreshTokens < ActiveRecord::Migration
  def change
    create_table :oauth_refresh_tokens do |t|
      t.string :token, null: false
      t.datetime :expires_at, null: true

      t.timestamps
    end

    add_reference :oauth_refresh_tokens, :client, index: true
    # work around for quirk in sqlite where you can add a not null column after the table is created.
    change_column :oauth_refresh_tokens, :client_id, :integer, :null => false
    add_index :oauth_refresh_tokens, :token, :unique => true
  end
end
