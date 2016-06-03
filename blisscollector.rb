#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
require_relative 'lib/bootstrap'
include Cmd
abort 'Requires at least 1 argument. Use \'bliss help\' for more info.' if ARGV.empty?
@args = ARGV
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
  puts 'Running locally, just use bliss with no arguments if you are an enterprise customer...'
  @args.shift
  LocalRunner.new(@args, "bliss-#{task}").execute
elsif @args[0] == 'init'
  BlissInitializer.new.execute
elsif @args[0] == 'run'
  puts 'Running Bliss CLI...'
  br = BlissRunner.new
  br.automate
elsif @args[0] == 'start'
  br = BlissRunner.new
  br.start
elsif @args[0] == 'stop'
  br = BlissRunner.new(false)
  br.stop
elsif @args[0] == 'status'
  BlissRunner.new(false)
  puts br.status
end
