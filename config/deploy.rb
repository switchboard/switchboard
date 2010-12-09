set :application, "Switchboard"
set :repository,  "git@github.com:switchboard/switchboard.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :branch, "production"

role :web, "mmp.vpscustomer.com"                          # Your HTTP server, Apache/etc
role :app, "mmp.vpscustomer.com"                          # This may be the same as your `Web` server
role :db,  "mmp.vpscustomer.com", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :user, "switchboard"

set :deploy_to, "/home/switchboard/production"
set :use_sudo, false 

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end

namespace :background_task_server do

  task :setup, :roles => :app do
    run "mkdir -p /usr/local/switchboard/run" 
    run "chown #{user}:#{group} /usr/local/switchboard/tmp/run" 
  end

  # start background task server
  task :start, :roles => :app do
    run "#{current_path}/script/switchboard_server_control.rb start -- production" 
  end

  # stop background task server
  task :stop, :roles => :app do
    run "#{current_path}/script/switchboard_server_control.rb stop -- production" 
  end

  # start background task server
  task :restart, :roles => :app do
    # TODO: since restart won't cold_start, we could read call to status, if 
    # it returns:
    #    task_server.rb: no instances running
    # we could simply issue the start command
    run "#{current_path}/script/switchboard_server_control.rb stop -- production" 
    run "#{current_path}/script/switchboard_server_control.rb start -- production" 
  end

end

