#!/usr/bin/env ruby
$LOAD_PATH << 'lib'
require_relative 'lib/bootstrap'
puts 'Initializing...'
@args = ARGV.size > 0 ? ARGV : nil

# Check that docker is running properly
unless Gem.win_platform?
  check_cmd = File.read("#{File.dirname($0)}/scripts/dockercheck.sh")
  exit unless system check_cmd
end
require 'pry'
if @args.nil?
  puts 'Running Bliss CLI...'
  BlissRunner.new.automate
else
  task = @args[0]
  if task.eql?('stats') || task.eql?('lint')
    puts 'Running locally, just use bliss with no arguments if you are an enterprise customer...'
    @args.shift
    LocalRunner.new(@args, "bliss-#{task}").execute
  else
    puts 'Usage:'
    puts "bliss\t\t Run the CLI."
    puts "bliss help\t\t Display this help message."
  end
end
