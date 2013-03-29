require 'bundler/capistrano'
set :stages, %w(production staging)
set :default_stage, 'staging'

require 'capistrano/ext/multistage'
require './config/boot'
require 'airbrake/capistrano'

set :application, "switchboard"
set :repository,  "git://github.com/whatcould/switchboard.git"
set :scm, :git
set :branch, "deploy"
