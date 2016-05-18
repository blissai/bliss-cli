#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
require_relative 'lib/bootstrap'
include Cmd
@args = ARGV.size > 0 ? ARGV : nil
abort 'Requires at least 1 argument. Use \'bliss help\' for more info.' if @args.nil?
help(@args[0])
version(@args[0])
puts 'Initializing...'
# Check that docker is running properly
if Gem.win_platform?
  abort 'Docker is not running or accessible. Please ensure Docker is set up correctly.' unless system 'docker ps'
else
  script = "#{File.dirname(File.expand_path(__FILE__))}/scripts/dockercheck.sh"
  check_cmd = File.read(script)
  exit unless system check_cmd
end

if @args[0] == 'stats' || @args[0] == 'lint'
  task = @args[0]
  if task.eql?('stats') || task.eql?('lint')
    puts 'Running locally, just use bliss with no arguments if you are an enterprise customer...'
    @args.shift
    LocalRunner.new(@args, "bliss-#{task}").execute
  end
elsif @args[0] == 'init'
  BlissInitializer.new.execute
else
  br = BlissRunner.new
  if @args[0] == 'run'
    puts 'Running Bliss CLI...'
    br.automate
  elsif @args[0] == 'start'
    br.start
  elsif @args[0] == 'stop'
    br.stop
  elsif @args[0] == 'status'
    puts br.status
  else
    help(@args[0], true)
  end
end
