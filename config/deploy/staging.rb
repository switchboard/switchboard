set :repository,  "git://github.com/switchboard/switchboard.git"
set :branch, 'develop'

server "switchboard.whatcould.com", :web, :app, :db, primary: true

set :application, "switchboard"

set :user, 'deploy'
set :deploy_to, "/srv/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    # run "cd #{current_path} && bundle exec rake asset:packager:build_all RAILS_ENV=production"
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"

    run "cd #{current_path} && bundle exec #{current_path}/script/daemon restart switchboard_server"

    run "curl -s http://switchboard.whatcould.com > /dev/null 2>&1"
  end

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/settings-production.yml #{release_path}/config/settings/production.yml"
    run "ln -nfs #{shared_path}/config/airbrake.rb #{release_path}/config/initializers/airbrake.rb"
    run "ln -nfs #{shared_path}/config/aaa_staging_settings.rb #{release_path}/config/initializers/aaa_staging_settings.rb"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
  
end
