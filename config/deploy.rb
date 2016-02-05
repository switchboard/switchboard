set :application, 'switchboard'
set :repo_url, "git://github.com/switchboard/switchboard.git"

set :log_level, :info

set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/app_environment_variables.rb config/settings/production.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5
set :ssh_options, :compression => false, :keepalive => true


namespace :resque do
  desc "Restart resque"
  task :restart do
    on roles :web do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :touch, "tmp/resque-restart.txt"
        end
      end
    end
  end
end

namespace :deploy do
  desc 'Restart Rails application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
  after :finishing, 'deploy:cleanup'
  after :restart, 'resque:restart'

  after :finished, :set_current_version do
    on roles(:app) do
      # dump current git version
      within release_path do
        execute :echo, "https://github.com/switchboard/switchboard/commit/#{capture("cd #{repo_path} && git rev-parse --short HEAD")} >> public/version.txt"
      end
    end
  end

end
