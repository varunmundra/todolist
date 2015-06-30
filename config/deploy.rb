require 'mina/bundler' 
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv' 
require 'mina_sidekiq/tasks' 
require 'mina/unicorn'



set :rails_env, 'production'
set :domain, '128.199.76.6'
set :deploy_to, '/home/varun/www/todolist' 
set :repository, 'https://github.com/varunmundra/todolist.git'
set :branch, 'master'
set :user, 'varun'
set :forward_agent, true
set :port, '22'
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"
# For system-wide RVM install.
# set :rvm_path, '/usr/local/rvm/bin/rvm'
# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log', 'config/secrets.yml']
# This task is the environment that is loaded for most commands, such as # `mina deploy` or `mina rake`.
task :environment do
 queue %{
echo "-----> Loading environment"
#{echo_cmd %[source ~/.bashrc]}
}
 invoke :'rbenv:load'
# If you're using rbenv, use this to load the rbenv environment. # Be sure to commit your .rbenv-version to your repository.
end
# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between # all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]
  
  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
  
  queue! %[touch "#{deploy_to}/shared/config/secrets.yml"] 
  queue %[echo "-----> Be sure to edit 'shared/config/secrets.yml'."]
  # sidekiq needs a place to store its pid file and log file 
  queue! %[mkdir -p "#{deploy_to}/shared/pids/"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/pids"]
  
  queue! %[mkdir -p "#{deploy_to}/shared/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/sockets"] 

end
desc "Deploys the current version to the server." 
task :deploy => :environment do
  deploy do
# stop accepting new workers invoke :'sidekiq:quiet'
  invoke :'git:clone'
  invoke :'deploy:link_shared_paths' 
  invoke :'bundle:install'
  invoke :'rails:db_migrate'
  invoke :'rails:assets_precompile'

  to :launch do
    invoke :'sidekiq:restart' 
    invoke :'unicorn:restart'
  end
 end
end





