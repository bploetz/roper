class MakeRedirectUriOptional < ActiveRecord::Migration
  def change
    change_column_null(:oauth_auth_codes, :redirect_uri, true)
  end
end
