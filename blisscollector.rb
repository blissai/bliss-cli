#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
require_relative 'lib/bootstrap'
puts 'Initializing...'
include CliTasks
@args = ARGV

exit unless DockerRunner.check_docker_settings

if `docker images`.include? 'Cannot connect to the Docker daemon.'
  puts 'Docker is not running. Please start docker.'
  exit
end

if auto?
  puts 'Running scheduled Bliss job...'
  BlissRunner.new(true).automate
elsif loop?
  # The main program loop to accept commands for various tasks
  BlissRunner.new.choose_command
  puts 'Goodbye'
else
  puts 'Usage:'
  puts "collector\t\t Run the CLI tool normally and choose from a list of commands"
  puts "collector auto\t\t Run Collector, Stats and Linter all in one"
end
