require "roper/engine"
require "roper/repository"

module Roper

  # ORM to use for persistence. Supports :active_record, :mongoid, and :mongo_mapper
  mattr_accessor :orm
  @@orm = :active_record

  # Time (in seconds) when access tokens expire.
  # Setting this to nil means access tokens do not expire
  mattr_accessor :access_token_expiration_time
  @@access_token_expiration_time = 900

  # Whether to enable the use of refresh tokens or not
  mattr_accessor :enable_refresh_tokens
  @@enable_refresh_tokens = false

  # The enclosing application's resource owner class. Must be a string.
  mattr_accessor :resource_owner_class
  @@resource_owner_class = "User"

  # The enclosing application's current_user method to get the currently signed in user. Must be a symbol.
  mattr_accessor :current_user_method
  @@current_user_method = :current_user

  # The method to get the id of the current_user. Must be a symbol.
  mattr_accessor :current_user_id_method
  @@current_user_id_method = :id

  # The enclosing application's signed_in? helper method to determine if the current user is signed in. Must be a symbol.
  mattr_accessor :signed_in_method
  @@signed_in_method = :user_signed_in?

  # The enclosing application's sign_in path.
  mattr_accessor :sign_in_path
  @@sign_in_path = "sign_in_path"

  # The enclosing application's authenticate_resource_owner method to authenticate the resource owner
  # (used in Resource Owner Password Credentials Grant flow). Must be a symbol.
  mattr_accessor :authenticate_resource_owner_method
  @@authenticate_resource_owner_method = :authenticate_resource_owner


  # Run rails generate roper_install to create
  # a fresh initializer with all configuration values.
  def self.configure
    yield self
    raise "Unsupported orm: #{@@orm}" if ![:active_record, :mongoid, :mongo_mapper].include?(@@orm)
  end
end
