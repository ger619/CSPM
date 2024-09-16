# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, "CSPM"
set :repo_url, "https://github.com/ger619/CSPM.git"
set :branch, "dep"

# Default deploy_to directory is /home/cspm/CSPM
set :deploy_to, "/home/cspm/CSPM"

# Default value for :linked_files is []
append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('public/assets', 'node_modules')

# Set the Rails environment
set :rails_env, 'production'

# Default value for keep_releases is 5
set :keep_releases, 5

# Set the default environment path
set :default_env, { path: "/home/cspm/.rbenv/shims:/home/cspm/.rbenv/bin:$PATH" }

# Ensure assets are precompiled during deployment
namespace :deploy do
  after :updated, 'deploy:compile_assets'
end

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

# Ensure the manifest file is backed up and restored correctly
namespace :deploy do
  namespace :assets do
    desc 'Backup the assets manifest'
    task :backup_manifest do
      on roles(fetch(:assets_roles)) do
        within release_path do
          execute :cp, release_path.join('public/assets/.sprockets-manifest*'), shared_path.join('public/assets/')
        end
      end
    end

    desc 'Restore the assets manifest'
    task :restore_manifest do
      on roles(fetch(:assets_roles)) do
        within release_path do
          if test("[ -f #{shared_path.join('public/assets/.sprockets-manifest*')} ]")
            execute :cp, shared_path.join('public/assets/.sprockets-manifest*'), release_path.join('public/assets/')
          else
            warn "Rails assets manifest file not found."
          end
        end
      end
    end
  end

  before 'deploy:assets:precompile', 'deploy:assets:restore_manifest'
  after 'deploy:assets:precompile', 'deploy:assets:backup_manifest'
end

set :assets_roles, [:web, :app]
set :assets_prefix, 'packs'
set :local_precompile, true