module Roper
  module ActiveRecord
    class AuthorizationCode < ::ActiveRecord::Base
      self.table_name = "oauth_auth_codes"

      belongs_to :client
    end
  end
end
