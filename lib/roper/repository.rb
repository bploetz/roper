# hat tip: http://blog.8thlight.com/mike-ebert/2013/03/23/the-repository-pattern.html
module Roper
  class Repository
    def self.register(type, repo)
      repositories[type] = repo
    end

    def self.repositories
      @repositories ||= {}
    end

    def self.for(type)      
      repositories[type]
    end

    def self.init!
      case Roper.orm
      when :active_record
        require 'roper/repository/active_record'
        Repository.register(:client, ActiveRecord::ClientRepository.new)
        Repository.register(:authorization_code, ActiveRecord::AuthorizationCodeRepository.new)
        Repository.register(:access_token, ActiveRecord::AccessTokenRepository.new)
      end
    end
  end
end
