require "roper/engine"
require "roper/repository"

module Roper

  # ORM to use for persistence. Supports :active_record, :mongoid, and :mongo_mapper
  mattr_accessor :orm
  @@orm = :active_record

  # Time (in seconds) when access tokens expire.
  # Setting this to nil means access tokens do not expire
  mattr_accessor :access_token_expiration_time
  @@access_token_expiration_time = 60

  # The enclosing application's user class. Must be a string.
  mattr_accessor :user_class
  @@user_class = "User"

  # The enclosing application's current_user method to get the currently signed in user. Must be a symbol.
  mattr_accessor :current_user_method
  @@current_user_method = :current_user

  # The enclosing application's signed_in? helper method to determine if the current user is signed in. Must be a symbol.
  mattr_accessor :signed_in_method
  @@signed_in_method = :user_signed_in?

  # The enclosing application's sign_in path.
  mattr_accessor :sign_in_path
  @@sign_in_path = "sign_in_path"


  # Run rails generate roper_install to create
  # a fresh initializer with all configuration values.
  def self.configure
    yield self
    raise "Unsupported orm: #{@@orm}" if ![:active_record, :mongoid, :mongo_mapper].include?(@@orm)
  end
end
