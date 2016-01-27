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
  BlissRunner.new.automate
else
  puts 'Usage:'
  puts "bliss\t\t Run the CLI."
  puts "bliss help\t\t Display this help message."
end
