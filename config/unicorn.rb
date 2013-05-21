require 'ohm'
require 'redis/connection/hiredis'

application = "dinosaur"

working_directory "/var/games/servers/#{application}/current"

current_path = "/var/games/servers/#{application}/current"

require "#{current_path}/config/server_info.rb"

proc_count = case RbConfig::CONFIG['host_os']
  when /darwin9/
    `hwprefs cpu_count`.to_i
  when /darwin/
    ((`which hwprefs` != '') ? `hwprefs thread_count` : `sysctl -n hw.ncpu`).to_i
  when /linux/
    `cat /proc/cpuinfo | grep processor | wc -l`.to_i
  when /freebsd/
    `sysctl -n hw.ncpu`.to_i
  when /mswin|mingw/
    require 'win32ole'
    wmi = WIN32OLE.connect("winmgmts://")
    cpu = wmi.ExecQuery("select NumberOfCores from Win32_Processor") # TODO count hyper-threaded in this
    cpu.to_enum.first.NumberOfCores
  else
    1
  end
end

puts "--- Unicorn: the worker_processes is #{proc_count} ==="

worker_processes proc_count

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
  # Ohm.redis.quit
  Redis.current.quit
end

after_fork do |server, worker|
  # Ohm.connect :host => "127.0.0.7", :port => 6379, :driver => :hiredis
  # Redis.connect :host => "127.0.0.7", :port => 6379, :driver => :hiredis
  Redis.new(ServerInfo.current.redis.merge(:driver => :hiredis, :db => 0))
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