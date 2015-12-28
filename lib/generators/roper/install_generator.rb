require 'rails/generators/base'

module Roper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a roper initializer file."

      def copy_initializer
        template "roper.rb", "config/initializers/roper.rb"
      end

      def copy_locales
        template "roper.en.yml", "config/locales/roper.en.yml"
      end
    end
  end
end
