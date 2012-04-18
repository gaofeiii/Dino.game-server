$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
require 'bundler/capistrano'

# Server list
@test = "vm-192-168-14-216.shengyun.grandcloud.cn"

# Deploy server
@@server = :test

set :rvm_ruby_string, "1.9.3@rails323"
set :rvm_type, :user

set :bundle_dir, '$HOME/.rvm/gems/ruby-1.9.3-p125@rails323'

default_run_options[:pty] = true
set :user, "gaofei"
set :runner, "gaofei"
set :ssh_options,   { :forward_agent => true }
set :application, "dinosaur"
set :deploy_to, "/var/games/servers/#{application}"
set :deploy_via, :remote_cache
set :rails_env, :production
set :use_sudo, false
set :keep_releases, 5

set :repository,  "git@vm-192-168-14-216.shengyun.grandcloud.cn:/git/dinosaur-game.git"
set :scm, :git
set :branch, "master"
set :scm_passphrase, "123"

role :web, eval("@#{@@server}")
role :app, eval("@#{@@server}")
role :db,  eval("@#{@@server}"), :primary => true # This is where Rails migrations will run

namespace :deploy do
  %w(start stop restart).each do |action|
    desc "unicorn:#{action}"
    task action.to_sym do
      find_and_execute_task("unicorn:#{action}")
    end
  end
 
end

namespace :assets do
  desc "assets:precompile"
  task :precompile, :role => :app do
    run "cd #{current_path} && bundle exec rake assets:precompile"
  end
end

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust \#\{release_path\}"
  end
end

# 如果有rvmrc文件需要执行 trust_rvmrc
# after "deploy", "rvm:trust_rvmrc"
# after "deploy", "deploy:migrate"
# after "deploy:create_symlink", "assets:precompile"

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