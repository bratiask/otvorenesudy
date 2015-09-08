require 'bundler/capistrano'
require 'sidekiq'
require 'rvm/capistrano'
require 'capistrano/sidekiq'

set :stages, [:staging, :production]

require 'capistrano/ext/multistage'

set :application,    'opencourts'
set :scm,            :git
set :repository,     'git@github.com:otvorenesudy/otvorenesudy.git'
set :scm_passphrase, ''
set :user,           'deploy'

set :use_sudo, false

set :ssh_options, { forward_agent: true }
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

set :keep_releases, 1

default_run_options[:pty] = true

# Database (PostgreSQL)
namespace :db do
  desc "Migrate DB"
  task :create, roles: :db do
    run "cd #{current_path}; bundle exec rake db:create RAILS_ENV=#{rails_env}"
  end

  desc "Migrate DB during release"
  task :create_release, roles: :db do
    run "cd #{release_path}; bundle exec rake db:create RAILS_ENV=#{rails_env}"
  end

  desc "Setup DB during deployment of release for this environment"
  task :setup_release, roles: :db do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake db:setup"
  end

  desc "Setup current DB for this environment"
  task :setup_current, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:setup"
  end

  desc "Drop DB for this environment"
  task :drop, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:drop"
  end

  desc "Reset DB for this environment"
  task :reset, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:reset"
  end
end

# Probe (Elasticsearch)
namespace :probe do
  desc "Drop Probe indices"
  task :drop do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake probe:drop"
  end

  desc "Import Probe indices"
  task :import, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake probe:import"
  end

  desc "Enqueue async import of Probe indices"
  task :import_async, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake probe:import:async"
  end

  desc "Update Probe indices"
  task :update, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake probe:update"
  end

  desc "Enqueue async update of Probe indices"
  task :update_async, roles: :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake probe:update:async"
  end
end

namespace :workers do
  desc "Start workers"
  task :start do
    run 'sidekiq -C config/sidekiq.yml'
  end

  desc "Stop workers"
  task :stop do
    run 'sidekiqctl stop tmp/pids/sidekiq.pid 30'
  end
end

# General
namespace :deploy do
  [:start, :stop, :upgrade].each do |command|
    desc "#{command.to_s.capitalize} unicorn server"
    task command, roles: :app, except: { no_release: true } do
      run "/etc/init.d/unicorn-#{application}-#{rails_env} #{command}"
    end
  end

  desc 'Restart Unicorn'
  task :restart do
    run "/etc/init.d/unicorn-#{application}-#{rails_env} stop"
    run "/etc/init.d/unicorn-#{application}-#{rails_env} start"
  end

  desc "Symlink shared"
  task :symlink_shared, roles: :app do
    run "ln -nfs #{shared_path} #{release_path}/shared"
    run "ln -nfs #{shared_path}/storage #{release_path}"
  end

  desc "Move in configuration files"
  task :move_in_configuration_files, roles: :app do
    run "ln -nfs #{shared_path}/config/*.yml #{release_path}/config"
  end

  after 'deploy', 'deploy:cleanup'
  after 'deploy:update_code', 'deploy:symlink_shared', 'deploy:move_in_configuration_files', 'db:create_release', 'deploy:migrate'

  after 'deploy:update_code' do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile"
  end
end
