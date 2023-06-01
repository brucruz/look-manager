# Load DSL and Setup Up Stages
require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/rails'
require 'capistrano/passenger'
require 'capistrano/rbenv'
require "capistrano/scm/git"
# require 'capistrano/puma'
# install_plugin Capistrano::Puma
# install_plugin Capistrano::Puma::Systemd
install_plugin Capistrano::SCM::Git

set :rbenv_type, :user
set :rbenv_ruby, '3.2.2'


# # Load DSL and Setup Up Stages
# require 'capistrano/setup'
# require 'capistrano/deploy'

# require 'capistrano/rails'
# require 'capistrano/bundler'
# require 'capistrano/rvm'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
# Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }