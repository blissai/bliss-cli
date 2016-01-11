#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
require_relative 'lib/bootstrap'
puts 'Initializing...'
include CliTasks
@args = ARGV

# Check that docker is running properly
unless Gem.win_platform?
  check_cmd = File.read("#{File.dirname($0)}/scripts/dockercheck.sh")
  exit unless system check_cmd
end

if auto?
  puts 'Running Bliss CLI...'
  BlissRunner.new(true).automate
# elsif loop?
  # The main program loop to accept commands for various tasks
  # BlissRunner.new.choose_command
  # puts 'Goodbye'
else
  puts 'Usage:'
  puts "collector\t\t Run the CLI tool normally and choose from a list of commands"
  puts "collector auto\t\t Run Collector, Stats and Linter all in one"
end
