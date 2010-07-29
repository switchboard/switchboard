set :application, "Switchboard"
set :repository,  "ssh://gitosis@durga.serve.com:2020/~/repositories/mmp-sms.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "mmp.vpscustomer.com"                          # Your HTTP server, Apache/etc
role :app, "mmp.vpscustomer.com"                          # This may be the same as your `Web` server
role :db,  "mmp.vpscustomer.com", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :user, "switchboard"

set :deploy_to, "/usr/local/switchboard"
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
