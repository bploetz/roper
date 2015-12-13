class AddRefreshTokens < ActiveRecord::Migration
  def change
    change_table :oauth_access_tokens do |t|
      t.string :refresh_token
      t.index :refresh_token, :unique => true
    end
  end
end
