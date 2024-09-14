# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "CSPM"
set :repo_url, "https://github.com/ger619/CSPM.git"
set :branch, "dep"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/cspm/CSPM"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []

append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage", "app/assets/images","app/assets/stylesheets", "app/assets/stylesheets/application.tailwind.css",
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

set :default_env, { path: "/home/cspm/.rbenv/shims:/home/cspm/.rbenv/bin:$PATH" }

# config/deploy.rb
namespace :deploy do
  after :updated, 'deploy:compile_assets'
end
# From Mac OS X

namespace :deploy do
  desc "Compile assets"
  task :compile_assets do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'assets:precompile'
        end
      end
    end
  end
end

set :assets_roles, [:web, :app]
set :assets_prefix, 'precompiled-assets'
set :local_precompile, true


  # Uncomment the following to require manually verifying the host key before first deploy.
  # # set :ssh_options, verify_host_key: :secure