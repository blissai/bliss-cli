# A class to handle config and instantiation of tasks
class BlissRunner
  include Configuration
  include Gitbase
  def initialize
    # Load configuration File if it exists
    load_configuration
    configure_bliss
    @docker_runner = DockerRunner.new(@config, @config['TOP_LVL_DIR'])
    update_repositories
  end

  # Initialize state from config file or user input
  def configure_bliss
    puts 'Configuring collector...'
    get_or_save_arg('What\'s your Bliss API Key?', 'API_KEY')
    get_or_save_arg('Which directory are your repositories located in?', 'TOP_LVL_DIR')
    get_or_save_arg('What is the name of your organization in git?', 'ORG_NAME')
    set_host
    FileUtils.mkdir_p @conf_dir
    File.open(@conf_path, 'w') { |f| f.write @config.to_yaml } # Store
    puts 'Collector configured.'.green
  end

  # A function that automates the above three functions for a scheduled job
  def automate
    if configured?
      @docker_runner.run
    else
      puts 'Collector has not been configured. Cannot run auto-task.'.red
    end
  end

  private

  def update_repositories
    puts 'Updating repositories to latest commit...'
    repos = Dir.glob(File.expand_path("#{@config['TOP_LVL_DIR']}/*"))
            .select { |fn| File.directory?(fn) && git_dir?(fn) }
    repos.each do |dir|
      cmd = "cd #{dir} && git pull"
      puts "\tPulling repository at #{dir}...".blue
      checkout_commit(dir, 'master')
      `#{cmd}`
    end
  end
end
