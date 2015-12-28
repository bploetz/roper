Roper.configure do |config|
  # ORM to use for persistence. Allowable values: :active_record, :mongoid, :mongo_mapper.
  # Defaults to :active_record if not specified.
  config.orm = :active_record

  # Time (in seconds) when access tokens expire.
  # Setting this to nil means access tokens do not expire.
  # Defaults to 900 if not specified.
  config.access_token_expiration_time = 900

  # Whether to enable the use of refresh tokens or not. See https://tools.ietf.org/html/rfc6749#section-1.5.
  # Defaults to false if not specified
  config.enable_refresh_tokens = false

  # The model class in the enclosing application which represents the resource owner. Must be a String.
  # Defaults to "User" if not specified.
  config.resource_owner_class = "User"

  # The helper method in the enclosing application to get the currently signed in resource owner object. Must be a symbol.
  # Defaults to :current_user if not specified.
  config.current_user_method = :current_user

  # The helper method in the enclosing application to determine if the current user is signed in. Must be a symbol.
  # Defaults to :user_signed_in? if not specified
  config.signed_in_method = :user_signed_in?

  # The path in the enclosing application where resource owners can sign in. Must be a String.
  # Defaults to "sign_in_path" if not specified
  config.sign_in_path = "sign_in_path"

  # The helper method in the enclosing application to authenticate the resource owner
  # (used in Resource Owner Password Credentials Grant flow).
  # The method should take two parameters: a username, and a password, in that order. Must be a symbol.
  # Defaults to :authenticate_resource_owner if not specified.
  config.authenticate_resource_owner_method = :authenticate_resource_owner
end
