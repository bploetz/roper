module Roper
  module ActiveRecord
    class AccessToken < ::ActiveRecord::Base
      self.table_name = "oauth_access_tokens"
    end
  end
end
