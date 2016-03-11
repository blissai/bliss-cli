class BlissInitializer
  attr_reader :directory

  def initialize(git_dir = nil)
    @directory = git_dir.nil? ? Dir.pwd : git_dir
    @analyzer = ProjectAnalyzer.new(@directory)
  end

  def execute
    @subdir = prompt_for_subdir if @analyzer.too_big?
  end

  def prompt_for_subdir
    puts 'This repository appears to consist of multiple projects. Please choose a subdirectory to analyze (e.g. a node project, a rails project) or type exit.'
    subdir = gets.chomp
    subdir = subdir.strip
    exit if subdir == 'exit'
    if File.directory? subdir
      return subdir
    else
      prompt_for_subdir
    end
  end
end
