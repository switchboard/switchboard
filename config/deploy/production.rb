set :application, "Switchboard"

role :web, "69.164.216.141"                          # Your HTTP server, Apache/etc
role :app, "69.164.216.141"                          # This may be the same as your `Web` server
role :db,  "69.164.216.141", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :user, "switchboard"

# set :deploy_to, "/home/switchboard/production"
set :deploy_to, '/srv/switchboard'
set :use_sudo, false


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"

    run "cd #{current_path} && bundle exec #{current_path}/script/daemon restart switchboard_server"

    run "curl -s http://switchboard.mediamobilizing.org > /dev/null 2>&1"
  end

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/settings-production.yml #{release_path}/config/settings/production.yml"
    run "ln -nfs #{shared_path}/config/airbrake.rb #{release_path}/config/initializers/airbrake.rb"
   run "ln -nfs #{shared_path}/config/aaa_production_settings.rb #{release_path}/config/initializers/aaa_production_settings.rb"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

end
