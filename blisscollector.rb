#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
require_relative 'lib/bootstrap'
puts 'Initializing...'
@args = ARGV.size > 0 ? ARGV : nil

# Check that docker is running properly
if Gem.win_platform?
  unless system 'docker ps'
    abort 'Docker is not running or accessible. Please ensure Docker is set up correctly.'
  end
else
  script_path = "#{File.dirname(File.expand_path(__FILE__))}/scripts/dockercheck.sh"
  check_cmd = File.read(script_path)
  exit unless system check_cmd
end
if @args.nil?
  puts 'Running Bliss CLI...'
  BlissRunner.new.automate
elsif @args[0] == 'init'
  BlissInitializer.new.execute
else
  task = @args[0]
  if task.eql?('stats') || task.eql?('lint')
    puts 'Running locally, just use bliss with no arguments if you are an enterprise customer...'
    @args.shift
    LocalRunner.new(@args, "bliss-#{task}").execute
  else
    puts 'Usage:'
    puts "bliss\t\t Run the CLI."
    puts "bliss init \t\t Send preliminary repository data to Bliss."
    puts "bliss help\t\t Display this help message."
  end
end
