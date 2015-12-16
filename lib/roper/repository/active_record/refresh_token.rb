module Roper
  module ActiveRecord
    class RefreshToken < ::ActiveRecord::Base
      self.table_name = "oauth_refresh_tokens"

      belongs_to :client
    end
  end
end
