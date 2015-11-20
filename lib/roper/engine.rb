module Roper
  class Engine < ::Rails::Engine
    isolate_namespace Roper

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    config.after_initialize do
      Roper::Repository.init!
    end
  end
end
