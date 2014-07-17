set :stage, :staging
set :branch, :master

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w{deploy@springfield.whatcould.com}
role :web, %w{deploy@springfield.whatcould.com}
role :db,  %w{deploy@springfield.whatcould.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a has can be used to set
# extended properties on the server.
# server 'example.com', user: 'deploy', roles: %w{web app}, my_property: :my_value

set :rails_env, :production
set :deploy_to, '/srv/switchboard'

# set :default_env, {
#   'PATH' => "/usr/local/ruby/2.0.0-p353/bin:$PATH",
#   'RUBY_VERSION' => '2.0.0-p353',
#   'GEM_HOME' => '/usr/local/ruby/2.0.0-p353/lib/ruby/gems/2.0.0',
#   'GEM_PATH' => '/usr/local/ruby/2.0.0-p353/lib/ruby/gems/2.0.0'
# }

namespace :deploy do
  desc 'Fetch page to start Passenger server'
  task :start_passenger do
    `curl --silent --show-error https://switchboard.whatcould.com/ > /dev/null 2>&1`
  end
  after :restart, 'deploy:start_passenger'
end



