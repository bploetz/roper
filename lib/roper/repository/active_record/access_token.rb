module Roper
  module ActiveRecord
    class AccessToken < ::ActiveRecord::Base
      self.table_name = "oauth_access_tokens"

      belongs_to :client
    end
  end
end
