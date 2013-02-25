require 'ohm'
require 'redis/connection/hiredis'


application = "dinosaur"

working_directory "/var/games/servers/#{application}/current"

current_path = "/var/games/servers/#{application}/current"

require "#{current_path}/current/config/server_info.rb"

if ServerInfo.info[:env] == "dev"
  worker_processes 1
else
  worker_processes 4
end

listen "/tmp/#{application}.sock", :backlog => 128

preload_app true
timeout 30
pid "/var/games/servers/#{application}/shared/pids/unicorn.pid"
stderr_path "/var/games/servers/#{application}/shared/log/unicorn.stderr.log"
stdout_path "/var/games/servers/#{application}/shared/log/unicorn.stdout.log"

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  # if defined?(ActiveRecord::Base)
  #   ActiveRecord::Base.connection.disconnect!
  # end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "/var/games/servers/#{application}/shared/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  Ohm.redis.quit
end

after_fork do |server, worker|
  Ohm.connect :host => "127.0.0.7", :port => 6379, :driver => :hiredis
  # the following is *required* for Rails + "preload_app true",
  # if defined?(ActiveRecord::Base)
  #   ActiveRecord::Base.establish_connection
  # end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end