set :application, "Switchboard"

server "switchboard.mediamobilizing.org", :web, :app, :db, primary: true
set :user, "switchboard"

# set :deploy_to, "/home/switchboard/production"
set :deploy_to, '/srv/switchboard'
set :use_sudo, false


role :resque_worker, 'switchboard.mediamobilizing.org'
role :resque_scheduler, 'switchboard.mediamobilizing.org'
set :workers, { '*' => 1 }

after "deploy:restart", "resque:restart"


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"

    run "curl -s http://switchboard.mediamobilizing.org > /dev/null 2>&1"
  end

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/settings-production.yml #{release_path}/config/settings/production.yml"
    run "ln -nfs #{shared_path}/config/airbrake.rb #{release_path}/config/initializers/airbrake.rb"
   run "ln -nfs #{shared_path}/config/aaa_production_settings.rb #{release_path}/config/initializers/aaa_production_settings.rb"
  end
  before "deploy:assets:precompile", "deploy:symlink_config"

end
