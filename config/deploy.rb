# $:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'bundler/capistrano'

# Server list
@linode = "106.187.91.156"
@a001 = "50.112.84.136"
@ali001 = "42.120.23.41"
@local = "192.168.1.201"

# Deploy server
@@server = [@ali001]

set :rvm_ruby_string, "2.0.0@dinosaur_game"
set :rvm_type, :user
require "rvm/capistrano"

default_run_options[:pty] = true
set :user, "gaofei"
set :runner, "gaofei"
set :ssh_options,   { :forward_agent => true }
set :application, "dinosaur"
set :deploy_to, "/var/games/servers/#{application}"
# set :deploy_via, :remote_cache
set :rails_env, :production
set :use_sudo, false
set :keep_releases, 5

set :repository,  "git@106.187.91.156:dinostyle/game-server.git"
set :scm, :git
set :branch, "ds2"
# set :branch do
#   all_tags = `git tag`.split("\n")

#   puts
#   puts format("%-20s", "***** All Tags *****")
#   all_tags.each do |tg|
#     puts format("* %-16s *", " #{tg}")
#   end
#   puts format("%-20s", "******* End ********")
#   puts

#   default_tag = `git tag`.split("\n").last

#   tag = Capistrano::CLI.ui.ask "** Choose a tag to deploy (make sure to push the tag first): [default is #{default_tag}]"
#   tag = default_tag if tag.empty?
#   tag
# end

role :web, *@@server
role :app, *@@server
role :db,  *@@server, :primary => true # This is where Rails migrations will run

# namespace :deploy do
#   %w(start stop restart).each do |action|
#     desc "unicorn:#{action}"
#     task action.to_sym do
#       find_and_execute_task("unicorn:#{action}")
#     end
#   end
# end

# 如果有rvmrc文件需要执行 trust_rvmrc
# after "deploy", "rvm:trust_rvmrc"
# after "deploy", "deploy:migrate"
# after "deploy:create_symlink", "assets:precompile"


namespace :remote_cache do
  desc "Remove the remote cache"
  task :remove do
    run "rm -rf #{deploy_to}/shared/cached_copy"
  end
end

namespace :nginx do
  desc "Copy nginx config file to aim directory"
  task :config do
    run "sudo cp #{current_path}/config/nginx/dinosaur-game.conf /etc/nginx/conf.d/ds2-game.conf"
  end

  desc "Reload nginx"
  task :reload do
    run "sudo nginx -s reload"
  end

  desc "Restart nginx by new config file"
  task :restart do
    find_and_execute_task("nginx:config")
    find_and_execute_task("nginx:reload")
  end
end

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust \#\{release_path\}"
  end
end

namespace :redis do
  desc "Starting redis in production mode"
  task :start, :roles => :app do
    run "sudo /usr/local/bin/redis-server #{deploy_to}/shared/redis-production.conf"
  end

  desc "Uploading redis conf"
  task :update, :roles => :app do
    run "cp #{current_path}/config/redis/redis-production.conf #{deploy_to}/shared/"
  end

  task :stop do
    # run "sudo kill -QUIT `cat /var/run/redis.pid`"
    run "sudo /usr/local/bin/redis-cli shutdown"
  end
end

namespace :unicorn do
  desc "Start unicorn"
  task :start, :roles => :app do
    run "cd #{current_path} && bundle exec unicorn -c #{current_path}/config/unicorn.rb -D -E production"
  end

  desc "Stop unicorn"
  task :stop, :roles => :app do
    run "kill -QUIT `cat #{current_path}/tmp/pids/unicorn.pid`"
    sleep(3)
  end

  desc "Restart unicorn"
  task :restart, :roles => :app do
    find_and_execute_task("unicorn:stop")
    find_and_execute_task("unicorn:start")
  end
end

after "unicorn:start", "background:restart"

namespace :background do
  desc "Start background job"
  task :start, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production bundle exec ruby bgd.rb start"
  end

  desc "Stop background job"
  task :stop, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production bundle exec ruby bgd.rb stop"
  end

  desc "Restart background job"
  task :restart, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production bundle exec ruby bgd.rb restart"
  end

  desc "Check background status job"
  task :status, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production bundle exec ruby bgd.rb status"
  end
end

namespace :game do
  desc "Soft shutdown"
  task :shutdown, :roles => :app do
    run "sudo /usr/local/bin/redis-cli -p 20003 del Server:status"
  end

  desc "Soft start server"
  task :start, :roles => :app do
    run "sudo /usr/local/bin/redis-cli -p 20003 set Server:status 1"
  end
end

namespace :puma do
  task :start, :roles => :app do
    run "cd #{current_path} && bundle exec puma -C #{current_path}/config/puma.rb"
  end

  task :stop, :roles => :app do
    run "kill -QUIT `cat #{deploy_to}/shared/pids/puma.pid`"
  end

  task :restart, :roles => :app do
    find_and_execute_task("puma:stop")
    find_and_execute_task("puma:start")
  end
end
after "puma:start", "background:restart"

task :deploy_all do
  find_and_execute_task("deploy:cleanup")
  find_and_execute_task("deploy")
  find_and_execute_task("unicorn:restart")
end