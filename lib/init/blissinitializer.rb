class BlissInitializer
  include Gitbase
  include Configuration
  attr_reader :directory

  def initialize(git_dir = nil)
    @directory = git_dir.nil? ? Dir.pwd : git_dir
    unless git_dir? @directory
      puts 'Error: This is not a valid git directory.'.red
      exit
    end
    @analyzer = ProjectAnalyzer.new(@directory, 500_000)
    load_configuration
    configure_bliss
    @subdir = prompt_for_subdir
    @args = @subdir.nil? ? [] : ["subdir=#{@subdir}"]
    @docker_runner = DockerInitializer.new(@directory, @config, @args)
    update_repository
  end

  # Initialize state from config file or user input
  def configure_bliss
    puts 'Configuring collector...'
    get_or_save_arg('What\'s your Bliss API Key?', 'API_KEY')
    get_or_save_arg('What is the name of your organization in git?', 'ORG_NAME')
    set_host
    FileUtils.mkdir_p @conf_dir
    File.open(@conf_path, 'w') { |f| f.write @config.to_yaml } # Store
    puts 'Collector configured.'.green
  end

  def execute
    # puts @docker_runner.docker_start_cmd
    @docker_runner.run
  end

  def prompt_for_subdir(maindir = nil)
    return nil unless @analyzer.too_big?
    puts 'This repository appears to consist of multiple projects. ' \
    'Please choose a subdirectory to analyze (e.g. a node project, a rails project) or type exit.'
    puts 'Possible choices:'
    maindir = @directory if maindir.nil?
    Dir.glob("#{maindir}/*/").each do |sd|
      puts sd.gsub("#{maindir}/", '')
    end
    subdir = $stdin.gets.chomp
    subdir = subdir.strip
    exit if subdir == 'exit'
    full_subdir_path = File.join(maindir, subdir)
    if File.directory?(full_subdir_path)
      @analyzer.update_directory(full_subdir_path)
      return prompt_for_subdir(full_subdir_path) if @analyzer.too_big?
      return full_subdir_path.gsub("#{@directory}/", '')
    else
      puts 'Not a valid subdirectory.'.red
      prompt_for_subdir(maindir)
    end
  end

  def update_repository
    puts 'Updating repository to latest commit...'
    cmd = "cd #{@directory} && git pull"
    puts "\tPulling repository at #{@directory}...".blue
    checkout_commit(@directory, 'master')
    `#{cmd}`
  end
end
