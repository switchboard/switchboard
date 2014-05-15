set :repository,  "git://github.com/switchboard/switchboard.git"
set :branch, 'develop'

server "switchboard.whatcould.com", :web, :app, :db, primary: true

set :application, "switchboard"

set :user, 'deploy'
set :deploy_to, "/srv/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :default_environment, {
  'PATH' => "/usr/local/ruby/2.0.0-p353/bin:$PATH",
  'RUBY_VERSION' => 'ruby 2.0.0',
  'GEM_HOME' => '/usr/local/ruby/2.0.0-p353/lib/ruby/gems/2.0.0',
  'GEM_PATH' => '/usr/local/ruby/2.0.0-p353/lib/ruby/gems/2.0.0'
}

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

role :resque_worker, 'switchboard.whatcould.com'
role :resque_scheduler, 'switchboard.whatcould.com'
set :workers, { '*' => 1 }

after "deploy:restart", "resque:restart"


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"

    run "curl -s http://switchboard.whatcould.com > /dev/null 2>&1"
  end

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/settings-production.yml #{release_path}/config/settings/production.yml"
    run "ln -nfs #{shared_path}/config/airbrake.rb #{release_path}/config/initializers/airbrake.rb"
    run "ln -nfs #{shared_path}/config/aaa_staging_settings.rb #{release_path}/config/initializers/aaa_staging_settings.rb"
  end
  before "deploy:assets:precompile", "deploy:symlink_config"

end
