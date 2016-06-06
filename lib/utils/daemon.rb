# Methods used for daemonization
module Daemon
  SHUTTING_DOWN = 'Shutting down...'.freeze
  RUNNING = 'Running...'.freeze
  STOPPED = 'Stopped.'.freeze
  PIDFILE = File.expand_path('~/.bliss/bliss.pid').freeze
  STATUSFILE = File.expand_path('~/.bliss/pstatus').freeze

  def write_pid(pid)
    File.open(PIDFILE, File::RDWR|File::CREAT, 0644) do |f|
      f.flock(File::LOCK_EX)
      f.write(pid.to_s)
      f.flush
      f.truncate(f.pos)
    end
  end

  def read_pid
    pid = nil
    FileUtils.touch(PIDFILE)
    File.open(PIDFILE, 'r') do |f|
      f.flock(File::LOCK_SH)
      pid = f.read
    end
    pid
  end

  def write_status(new_status)
    File.open(STATUSFILE, File::RDWR|File::CREAT, 0644) do |f|
      f.flock(File::LOCK_EX)
      f.write(new_status)
      f.flush
      f.truncate(f.pos)
    end
  end

  # Stop forked process
  def stop
    abort 'Not running...' if status.include?(STOPPED)
    abort 'Already shutting down...' if status.include?(SHUTTING_DOWN)
    puts 'Bliss daemon is shutting down. Please wait for linting to finish.'
    write_status(SHUTTING_DOWN)
  end

  def status
    status = nil
    FileUtils.touch(STATUSFILE)
    File.open(STATUSFILE, 'r') do |f|
      f.flock(File::LOCK_SH)
      status = f.read
    end
    "#{status} (pid: #{read_pid})"
  end

  def daemonize
    abort "Already running: pid #{read_pid}" if status.include?(RUNNING)
    puts 'Starting bliss daemon...'
    write_status(RUNNING)
    Process.daemon(true)
    write_pid(Process.pid)
    loop do
      yield
      next if status.eql?(RUNNING)
      write_status(STOPPED)
      write_pid('')
      break
    end
  end
end
