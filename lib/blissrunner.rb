# A class to handle config and instantiation of tasks
class BlissRunner
  include Configuration
  include Gitbase
  include Daemon
  def initialize(run = true)
    # Load configuration File if it exists
    load_configuration
    configure_bliss
    @repos_dir = @config['TOP_LVL_DIR']
    docker_params = @config.reject { |k, _v| k == 'TOP_LVL_DIR' }
    @docker_runner = DockerRunner.new(docker_params, @repos_dir,
                                      'blissai/collector:latest', run)
  end

  # Initialize state from config file or user input
  def configure_bliss
    puts 'Configuring collector...'
    sync_arg('What\'s your Bliss API Key?', 'API_KEY')
    sync_arg('Which directory are your repositories located in?', 'TOP_LVL_DIR')
    sync_arg('What is the name of your organization in git?', 'ORG_NAME')
    FileUtils.mkdir_p @conf_dir
    File.open(@conf_path, 'w') { |f| f.write @config.to_yaml } # Store
    puts 'Collector configured.'.green
  end

  # A function that automates the above three functions for a scheduled job
  def automate
    abort 'Collector has not been configured. Cannot run auto-task.' unless configured?
    abort 'No repositories found.'.yellow if repos.empty?
    update_repositories if @run
    @docker_runner.run
  end

  # Start forked process
  def start
    abort 'Collector has not been configured. Cannot loop.' unless configured?
    abort 'No repositories found.'.yellow if repos.empty?
    daemonize do
      update_repositories
      @docker_runner.run(STATUSFILE)
      sleep 2
    end
  end

  private

  def repos
    @repos ||= Dir.glob(File.expand_path("#{@repos_dir}/*"))
                  .select { |fn| File.directory?(fn) && git_dir?(fn) }
  end

  def update_repositories
    puts 'Updating repositories to latest commit...'
    repos.each do |dir|
      cmd = "cd #{dir} && git fetch --all && git reset --hard origin/master"
      puts "\tPulling repository at #{dir}...".blue
      checkout_commit(dir, 'master')
      `#{cmd}`
    end
  end
end
