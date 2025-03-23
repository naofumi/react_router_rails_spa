require "rails/generators"

module ReactRouterRailsSpa
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_react_router_app
        say "Setting up React Router v7 SBA mode in Rails..."
        inside Rails.root do
          run "npx create-react-router@latest frontend --yes --no-git-init"
        end
      end

      def setup_rails_routes
        route 'get "react/*path", to: "react#show"'
      end

      def create_react_controller
        create_file "app/controllers/react_controller.rb", <<-RUBY
          class ReactController < ApplicationController
            def show
              render file: Rails.public_path.join("react/react-router-rails-spa-index.html"), layout: false
            end
          end
        RUBY
      end

      def create_public_folders
        empty_directory Rails.root.join("public/react")
      end

      def copy_rake_task
        template "react.rake", "lib/tasks/react.rake"
      end

      def copy_react_router_configs
        template "react-router.config.ts", "frontend/react-router.config.ts"
        template "vite.config.ts", "frontend/vite.config.ts"
      end

      def copy_react_app_files
        template "home.tsx", "frontend/app/routes/home.tsx"
        directory "welcome", "frontend/app/welcome"
        template "csrf.ts", "frontend/app/utilities/csrf.ts"
        template "proxy.ts", "frontend/app/utilities/proxy.ts"
      end
    end
  end
end
