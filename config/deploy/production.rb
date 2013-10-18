set :application, "Switchboard"

role :web, "69.164.216.141"                          # Your HTTP server, Apache/etc
role :app, "69.164.216.141"                          # This may be the same as your `Web` server
role :db,  "69.164.216.141", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :user, "switchboard"

# set :deploy_to, "/home/switchboard/production"
set :deploy_to, '/srv/switchboard'
set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
      run "cd #{File.join(current_path)}; git submodule init"
      run "cd #{File.join(current_path)}; git submodule update"
     #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end

namespace :switchboard_server do
  desc "Setup the switchboard server directory"
  task :setup, :roles => :app do
    run "mkdir -p /home/switchboard/production/run"
    run "chown #{user}:#{user} /home/switchboard/production/run"
  end

  # start background server
  desc "Start the switchboard background server"
  task :start, :roles => :app do
    run "ruby #{current_path}/script/switchboard_server_control.rb start -- production"
  end

  # stop background server
  desc "Stop the switchboard background server"
  task :stop, :roles => :app do
    run "ruby #{current_path}/script/switchboard_server_control.rb stop -- production"
  end

  # restart the background server
  desc "Restart the switchboard background server"
  task :restart, :roles => :app do
    # TODO: since restart won't cold_start, we could read call to status, if
    # it returns:
    #    task_server.rb: no instances running
    # we could simply issue the start command
#    run "ruby #{current_path}/script/switchboard_server_control.rb stop -- production"
#    run "ruby #{current_path}/script/switchboard_server_control.rb start -- production"
  end

end

