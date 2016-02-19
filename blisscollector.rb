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

if @args.size == 3
  @config = {
    'API_KEY' => @args[0],
    'ORG_NAME' => @args[1],
    'TOP_LVL_DIR' => @args[2]
  }
else
  @config = nil
end

if auto?
  puts 'Running Bliss CLI...'
  BlissRunner.new(@config).automate
else
  puts 'Usage:'
  puts "bliss\t\t Run the CLI."
  puts "bliss help\t\t Display this help message."
end
