# frozen_string_literal: true

namespace :react_router do
  # For convenience, npm packages do not have to be explicitly installed.
  # Installed will be automatically initiated by other tasks.
  desc "Install npm packages for the React Router app"
  task :npm_install do
    puts "Installing npm packages ..."
    success = system("npm", "install", chdir: "#{Dir.pwd}/frontend")
    abort "❌ npm install failed" unless success
  end

  # Run bin/rails react_router:dev to start the dev server.
  #
  # If you are using the Foreman gem, you might want to run
  # this task in the Procfile.
  #
  # bin/rails react_router:dev
  desc "Start React Router Development Server with Hot Module Reloading"
  task dev: [ :npm_install ] do
    puts "Starting React Router v7 app development server..."
    Dir.chdir("#{Dir.pwd}/frontend") do
      system("npm", "run", "dev")
    end
  end

  # bin/rails react_router:typecheck
  desc "Check Typescript for the React Router App"
  task typecheck: [ :npm_install ] do
    puts "Check Typescript for React Router v7 app..."
    Dir.chdir("#{Dir.pwd}/frontend") do
      system("npm", "run", "typecheck")
    end
  end

  # Run bin/rails react_router:build to build the production app.
  # The location of the build is defined in the
  # frontend/react-router.config.ts file, and should
  # point to a location within the public folder.
  # Running bin/rails assets:precompile will also run this task.
  #
  # bin/rails react_router:build
  desc "Build React Router App and move to the public folder"
  task build: [ :npm_install ] do
    puts "Building React Router v7 app..."
    success = system("npm", "run", "build", chdir: "#{Dir.pwd}/frontend")
    abort "❌ React Router build failed" unless success

    puts "Moving build files to public/react..."
    FileUtils.rm_rf("#{Dir.pwd}/public/react")
    FileUtils.mv("#{Dir.pwd}/frontend/build/client", "#{Dir.pwd}/public/react")
    FileUtils.mv(
      "#{Dir.pwd}/public/react/index.html",
      "#{Dir.pwd}/public/react/react-router-rails-spa-index.html"
    )

    puts "✅ React app successfully built and deployed!"
  end

  # Run bin/rails react_router:preview to create a preview build.
  #
  # This is identical to running bin/rails react_router: build
  # and is provided solely to align better with intent.
  desc "Preview your React Router App from the Rails development server (typically port 3000)"
  task preview: [ :build ]

  # Run bin/rails react_router:clobber to remove the build files.
  # Running bin/rails assets:clobber will also run this task.
  task :clobber do
    puts "Clobbering React Router v7 app build files..."
    FileUtils.rm_rf("#{Dir.pwd}/public/react")
  end
end

# The following adds the above tasks to the regular
# assets:precompile and assets:clobber tasks.
#
# This means that any normal Rails deployment script which
# contains rake assets:precompile will also build the
# React Router app automatically.
Rake::Task["assets:precompile"].enhance([ "react_router:build" ])
Rake::Task["assets:clobber"].enhance([ "react_router:clobber" ])
