module Roper
  module ActiveRecord
    class Client < ::ActiveRecord::Base
      self.table_name = "oauth_clients"
    end
  end
end
