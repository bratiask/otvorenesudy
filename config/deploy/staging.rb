set :domain, '195.146.144.210'

server fetch(:domain), user: 'deploy', roles: %w{app db web}

set :stage,    :staging
set :branch,   'staging'
set :app_path, "#{fetch(:application)}_#{fetch(:stage)}"
set :rails_env, :staging
set :deploy_to, "/home/deploy/projects/#{fetch(:app_path)}"
