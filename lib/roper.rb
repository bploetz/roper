require "roper/engine"
require "roper/repository"

module Roper

  # ORM to use for persistence. Supports :active_record, :mongoid, and :mongomapper
  mattr_accessor :orm
  @@orm = :active_record

  # Time (in seconds) when access tokens expire.
  # Setting this to nil means access tokens do not expire
  mattr_accessor :access_token_expiration_time
  @@access_token_expiration_time = 60

  # Run rails generate roper_install to create
  # a fresh initializer with all configuration values.
  def self.configure
    yield self
    raise "Unsupported orm: #{@@orm}" if ![:active_record, :mongoid, :mongomapper].include?(@@orm)
  end
end
