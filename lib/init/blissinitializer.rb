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
    load_configuration
    configure_bliss
    @analyzer = ProjectAnalyzer.new(@directory, 500_000)
    @docker_runner = DockerInitializer.new(@directory, @config)
    @subdir = @analyzer.prompt_for_subdir
    @args = @subdir.nil? ? [] : ["subdir=#{@subdir}"]
    @docker_runner.args = @args
    update_repository
  end

  # Initialize state from config file or user input
  def configure_bliss
    puts 'Configuring collector...'
    sync_arg('What\'s your Bliss API Key?', 'API_KEY')
    sync_arg('What is the name of your organization in git?', 'ORG_NAME')
    FileUtils.mkdir_p @conf_dir
    File.open(@conf_path, 'w') { |f| f.write @config.to_yaml } # Store
    puts 'Collector configured.'.green
  end

  def execute
    @docker_runner.run
  end

  def update_repository
    puts 'Updating repository to latest commit...'
    cmd = "cd #{@directory} && git pull"
    puts "\tPulling repository at #{@directory}...".blue
    checkout_commit(@directory, 'master')
    `#{cmd}`
  end
end
